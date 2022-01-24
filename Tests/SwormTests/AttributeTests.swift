import Foundation
import Sworm
import SwormTools
import XCTest

@available(OSX 10.15, *)
final class AttributeTests: XCTestCase {
    func testPrimitiveAttributeFullSetReadWrite() {
        TestDB.perform(with: DataModels.attributes) { pc in
            let sourceInstance = PrimitiveAttributeFullSet(
                x1: .random(),
                x2: .random(in: .min ... .max),
                x3: .random(in: .min ... .max),
                x4: .random(in: .min ... .max),
                x5: .random(in: .min ... .max),
                x6: 100,
                x7: 100,
                x8: 100,
                x9: Bool.random() ? Date() : nil,
                x10: Bool.random() ? "\(Int.random(in: .min ... .max))" : nil,
                x11: Bool.random() ? Data(repeating: .random(in: .min ... .max), count: 16) : nil,
                x12: Bool.random() ? .init() : nil,
                x13: Bool.random() ? URL(string: "https://stackoverflow.com") : nil
            )

            try pc.perform { ctx in
                try ctx.insert(sourceInstance)
            }

            let destinationInstance = try pc.perform { ctx in
                try ctx.fetchOne(PrimitiveAttributeFullSet.all)?.decode()
            }

            XCTAssert(sourceInstance == destinationInstance)
        }
    }

    func testCustomAttributeSetReadWrite() {
        TestDB.perform(with: DataModels.attributes) { pc in
            let sourceInstances = [
                CustomAttributeSet(
                    x1: .init(.init(x: 1, y: 2)),
                    x2: .init(.init(x: 3, y: 4)),
                    x3: .init(x: 5, y: 6),
                    x4: nil,
                    x5: .y,
                    x6: .z
                ),
                CustomAttributeSet(
                    x1: .init(.init(x: 6, y: 5)),
                    x2: .init(.init(x: 4, y: 3)),
                    x3: nil,
                    x4: .init(x: 2, y: 1),
                    x5: .z,
                    x6: .y
                ),
            ]

            try pc.perform { ctx in
                try sourceInstances.forEach {
                    try ctx.insert($0)
                }
            }

            let destinationInstances = try pc.perform { ctx in
                try ctx.fetch(CustomAttributeSet.all.sort(\.x5))
                    .map { try $0.decode() }
            }

            XCTAssert(sourceInstances == destinationInstances)
        }
    }

    func testDemoAttributeSetRefReadWrite() {
        TestDB.perform(with: DataModels.attributes) { pc in
            let sourceInstance1 = DemoAttributeSetRef()
            sourceInstance1.x1 = 10

            let sourceInstance2 = DemoAttributeSetRef()
            sourceInstance2.x2 = 10

            try pc.perform { ctx in
                try ctx.insert(sourceInstance1)
                try ctx.insert(sourceInstance2)
            }

            let destinationInstances = try pc.perform { ctx in
                try ctx.fetch(DemoAttributeSetRef.all.sort(\.x1, ascending: false))
                    .map { try $0.decode() }
            }

            XCTAssert([sourceInstance1, sourceInstance2] == destinationInstances)
        }
    }

    func _testPrimitiveAttributeFullSetReadWriteMeasure() {
        let N = 10000

        TestDB.perform(with: DataModels.attributes) { pc in
            self.measure {
                do {
                    try self.writeRandomPrimitiveAttributeFullSets(n: N, pc: pc)

                    _ = try pc.perform { ctx in
                        try ctx.fetch(PrimitiveAttributeFullSet.all).map { try $0.decode() }
                    }
                } catch {}
            }
        }
    }

    func _testPrimitiveAttributeFullSetWriteMeasure() {
        let N = 10000

        TestDB.perform(with: DataModels.attributes) { pc in
            self.measure {
                do {
                    try self.writeRandomPrimitiveAttributeFullSets(n: N, pc: pc)
                } catch {}
            }
        }
    }

    func _testPrimitiveAttributeFullSetReadMeasure() {
        let N = 10000

        TestDB.perform(with: DataModels.attributes) { pc in
            try self.writeRandomPrimitiveAttributeFullSets(n: N, pc: pc)

            self.measure {
                do {
                    _ = try pc.perform { ctx in
                        try ctx.fetch(PrimitiveAttributeFullSet.all).map { try $0.decode() }
                    }
                } catch {}
            }
        }
    }

    private func writeRandomPrimitiveAttributeFullSets(n: Int, pc: PersistentContainer) throws {
        try pc.perform { ctx in
            try ctx.batchDelete(PrimitiveAttributeFullSet.all)

            try (0 ..< n).forEach { x in
                try ctx.insert(PrimitiveAttributeFullSet(
                    x1: .random(),
                    x2: .random(in: .min ... .max),
                    x3: .random(in: .min ... .max),
                    x4: .random(in: .min ... .max),
                    x5: .random(in: .min ... .max),
                    x6: Float(x),
                    x7: Double(x),
                    x8: .init(x),
                    x9: Date(),
                    x10: "\(Int.random(in: .min ... .max))",
                    x11: Data(repeating: .random(in: .min ... .max), count: 16),
                    x12: .init(),
                    x13: URL(string: "https://stackoverflow.com")
                ))
            }
        }
    }
}
