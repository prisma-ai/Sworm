import CoreData
import Foundation
import Sworm
import SwormTools
import XCTest

@available(OSX 10.15, *)
final class MigrationsTests: XCTestCase {
    func testProgressiveMigrations() {
        let bundle = Bundle.module

        let storeInfo = DataModels.migrations

        // all together

        do {
            try TestTool.Migrations.test(
                store: storeInfo,
                bundle: bundle,
                preAction: {
                    print("FIRST STEP")
                    let db = PersistentContainer(managedObjectContext: $0.newBackgroundContext)
                    do {
                        try db.perform { context in
                            try context.insert(MigratableModels.A(id: 1, name: "foo"))
                            try context.insert(MigratableModels.A(id: 2, name: "bar"))
                        }
                    } catch {
                        XCTFail(error.localizedDescription)
                        return
                    }
                },
                postAction: {
                    print("LAST STEP")
                    let db = PersistentContainer(managedObjectContext: $0.newBackgroundContext)
                    do {
                        let bs = try db.perform { context in
                            try context.fetch(MigratableModels.B.all)
                                .map { try $0.decode() }
                                .sorted()
                        }

                        XCTAssert(bs.count == 2)
                        XCTAssert(bs[0] == .init(identifier: 10, text: "foo"))
                        XCTAssert(bs[1] == .init(identifier: 20, text: "bar"))
                    } catch {
                        XCTFail(error.localizedDescription)
                        return
                    }

                    do {
                        try db.perform { context in
                            try context.insert(MigratableModels.C(foo: "foo"))
                            try context.insert(MigratableModels.C(foo: "bar"))
                        }
                    } catch {
                        XCTFail(error.localizedDescription)
                        return
                    }

                    do {
                        let cs = try db.perform { context in
                            try context.fetch(MigratableModels.C.all)
                                .map { try $0.decode() }
                                .sorted()
                        }

                        XCTAssert(cs.count == 2)
                        XCTAssert(cs[0] == .init(foo: "bar"))
                        XCTAssert(cs[1] == .init(foo: "foo"))
                    } catch {
                        XCTFail(error.localizedDescription)
                        return
                    }
                }
            )
        } catch {
            XCTFail(error.localizedDescription)
        }

        // step by step

        do {
            try TestTool.Migrations.testStepByStep(
                store: storeInfo,
                bundle: bundle,
                actions: [
                    0: {
                        print("STEP 0")

                        let db = PersistentContainer(managedObjectContext: $0.newBackgroundContext)
                        do {
                            try db.perform { context in
                                try context.insert(MigratableModels.A(id: 1, name: "foo"))
                                try context.insert(MigratableModels.A(id: 2, name: "bar"))
                            }
                        } catch {
                            XCTFail(error.localizedDescription)
                            return
                        }
                    },
                    1: {
                        print("STEP 1")

                        let db = PersistentContainer(managedObjectContext: $0.newBackgroundContext)
                        do {
                            let bs = try db.perform { context in
                                try context.fetch(MigratableModels.B.all)
                                    .map { try $0.decode() }
                                    .sorted()
                            }

                            XCTAssert(bs.count == 2)
                            XCTAssert(bs[0] == .init(identifier: 1, text: "foo"))
                            XCTAssert(bs[1] == .init(identifier: 2, text: "bar"))
                        } catch {
                            XCTFail(error.localizedDescription)
                            return
                        }
                    },
                    2: {
                        print("STEP 2")

                        let db = PersistentContainer(managedObjectContext: $0.newBackgroundContext)
                        do {
                            let bs = try db.perform { context in
                                try context.fetch(MigratableModels.B.all)
                                    .map { try $0.decode() }
                                    .sorted()
                            }

                            XCTAssert(bs.count == 2)
                            XCTAssert(bs[0] == .init(identifier: 10, text: "foo"))
                            XCTAssert(bs[1] == .init(identifier: 20, text: "bar"))
                        } catch {
                            XCTFail(error.localizedDescription)
                            return
                        }
                    },
                    3: {
                        print("STEP 3")

                        let db = PersistentContainer(managedObjectContext: $0.newBackgroundContext)
                        do {
                            try db.perform { context in
                                try context.insert(MigratableModels.C(foo: "foo"))
                                try context.insert(MigratableModels.C(foo: "bar"))
                            }
                        } catch {
                            XCTFail(error.localizedDescription)
                            return
                        }

                        do {
                            let cs = try db.perform { context in
                                try context.fetch(MigratableModels.C.all)
                                    .map { try $0.decode() }
                                    .sorted()
                            }

                            XCTAssert(cs.count == 2)
                            XCTAssert(cs[0] == .init(foo: "bar"))
                            XCTAssert(cs[1] == .init(foo: "foo"))
                        } catch {
                            XCTFail(error.localizedDescription)
                            return
                        }
                    },
                ]
            )
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testBlobsMigration() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        let file = dir.appendingPathComponent("store.sqlite", isDirectory: false)

        let storeInfo = DataModels.blob.with(url: file)

        try autoreleasepool {
            let nspc = try NSPersistentContainer(
                store: storeInfo.with(maxVersion: 0),
                bundle: .module
            )

            try nspc.loadPersistentStore()

            let pc = PersistentContainer(managedObjectContext: nspc.newBackgroundContext)

            try pc.perform { context in
                try (0 ..< 100).forEach { _ in
                    try context.insert(Blob(data: .init(repeating: 1, count: 10 * 1024 * 1024)))
                }
            }
        }

        do {
            guard let migration = try SQLiteProgressiveMigration(
                store: storeInfo,
                bundle: .module,
                defaultEntityMigrationPolicyClassName: NSStringFromClass(ExternalBinaryDataEntityMigrationPolicy.self),
                writableSourceStores: true
            ) else {
                throw SQLiteProgressiveMigration.Error.storeCompatibleModelNotFound
            }

            try migration.performMigration(progress: nil)
        }

        try autoreleasepool {
            let nspc = try NSPersistentContainer(
                store: storeInfo,
                bundle: .module
            )

            try nspc.loadPersistentStore()

            let pc = PersistentContainer(managedObjectContext: nspc.newBackgroundContext)

            try pc.perform { context in
                let blobs = try context.fetch(Blob.all).map { try $0.decode() }

                blobs.forEach {
                    XCTAssert($0.data == .init(repeating: 1, count: 10 * 1024 * 1024))
                }
            }
        }

        try FileManager.default.removeItem(at: dir)
    }
}
