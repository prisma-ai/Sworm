import CoreData

public enum TestTool {
    public enum Migrations {
        // MARK: Public

        public enum Error: Swift.Error {
            case invalidMigrationStepCount(Int?, expected: Int?, store: SQLiteStoreDescription)
        }

        public typealias TestAction = (NSPersistentContainer) -> Void

        public static func testStepByStep(store: SQLiteStoreDescription, bundle: Bundle, actions: [Int: TestAction]) throws {
            try TestTool.withTemporaryPersistentStore(store) { testStore in
                try store.modelVersions.indices.forEach { index in
                    try self.performTestAction(store: testStore.with(maxVersion: index), bundle: bundle, expectedStepCount: index > 0 ? 1 : nil) { persistentContainer in
                        actions[index]?(persistentContainer)
                    }
                }
            }
        }

        public static func test(store: SQLiteStoreDescription, bundle: Bundle, preAction: TestAction?, postAction: TestAction?) throws {
            try TestTool.withTemporaryPersistentStore(store) { testStore in
                try self.performTestAction(store: testStore.with(maxVersion: 0), bundle: bundle, expectedStepCount: nil) { persistentContainer in
                    preAction?(persistentContainer)
                }

                try self.performTestAction(store: testStore, bundle: bundle, expectedStepCount: testStore.modelVersions.count - 1) { persistentContainer in
                    postAction?(persistentContainer)
                }
            }
        }

        // MARK: Private

        private static func performTestAction(
            store: SQLiteStoreDescription,
            bundle: Bundle,
            expectedStepCount: Int?,
            testAction: (NSPersistentContainer) -> Void
        ) throws {
            try autoreleasepool {
                let persistentContainer = try NSPersistentContainer(store: store, bundle: bundle)
                let migration = try SQLiteProgressiveMigration(store: store, bundle: bundle)
                if expectedStepCount != migration?.stepCount {
                    throw Error.invalidMigrationStepCount(migration?.stepCount, expected: expectedStepCount, store: store)
                }
                try migration?.performMigration(progress: nil)
                try persistentContainer.loadPersistentStore()
                testAction(persistentContainer)
                try persistentContainer.removePersistentStores()
            }
        }
    }

    public static func withTemporaryPersistentStore(_ store: SQLiteStoreDescription, action: (SQLiteStoreDescription) throws -> Void) throws {
        let fileManager = FileManager.default

        let url = try fileManager.createUniqueTemporaryDirectory()
            .appendingPathComponent("db", isDirectory: false)
            .appendingPathExtension("sqlite")

        do {
            try action(store.with(url: url))
        } catch {
            try fileManager.removeItem(at: url)

            throw error
        }

        try fileManager.removeItem(at: url)
    }
}
