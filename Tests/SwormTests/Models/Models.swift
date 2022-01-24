import Foundation
import Sworm

enum MigratableModels {
    struct A {
        var id: Int = 0
        var name: String = ""
    }

    struct B: Comparable {
        var identifier: Double = 0
        var text: String = ""

        static func < (lhs: MigratableModels.B, rhs: MigratableModels.B) -> Bool {
            lhs.identifier < rhs.identifier
        }
    }

    struct C: Comparable {
        var foo: String = ""

        static func < (lhs: MigratableModels.C, rhs: MigratableModels.C) -> Bool {
            lhs.foo < rhs.foo
        }
    }
}

struct PrimitiveAttributeFullSet: Equatable {
    var x1: Bool = false

    var x2: Int = .zero
    var x3: Int16 = .zero
    var x4: Int32 = .zero
    var x5: Int64 = .zero

    var x6: Float = .zero
    var x7: Double = .zero
    var x8: Decimal = .zero

    var x9: Date?
    var x10: String?
    var x11: Data?
    var x12: UUID?
    var x13: URL?
}

struct CustomAttributeSet: Equatable {
    struct CustomType: Equatable, Codable, LosslessStringConvertible {
        internal init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }

        init?(_ description: String) {
            let parts = description.split(separator: "-")

            guard parts.count == 2,
                  let x = Int(parts[0]),
                  let y = Int(parts[1])
            else {
                return nil
            }

            self.x = x
            self.y = y
        }

        let x: Int
        let y: Int

        var description: String {
            "\(self.x)-\(self.y)"
        }
    }

    enum CustomEnumeration: Int {
        case x
        case y
        case z
    }

    var x1: JSON<CustomType> = .init(.init(x: 0, y: 0))
    var x2: LSC<CustomType> = .init(.init(x: 0, y: 0))
    var x3: CustomType?
    var x4: CustomType?
    var x5: CustomEnumeration = .x
    var x6: CustomEnumeration = .x
}

final class DemoAttributeSetRef: Equatable {
    var x1: Int = .zero
    var x2: Int?

    static func == (lhs: DemoAttributeSetRef, rhs: DemoAttributeSetRef) -> Bool {
        lhs.x1 == rhs.x1 && lhs.x2 == rhs.x2
    }
}

struct PredicateABCD: Equatable {
    enum SomeEnum: String {
        case foo
        case bar
    }

    var a: Int = 0
    var b: Int = 0
    var c: String?
    var d: SomeEnum?
}

struct PredicateIDURL: Equatable {
    var id: UUID?
    var url: URL?
}

enum BookLibrary {
    struct Author: Equatable {
        var id: UUID = .init()
        var name: String = ""
        var age: Int = 0
    }

    struct Book: Equatable {
        struct Review: Equatable {
            var id: UUID = .init()
            var text: String = ""
            var mark: Int = 0
        }

        struct Cover: Equatable {
            var url: URL?
        }

        var id: UUID = .init()
        var name: String = ""
        var year: Int = 0
    }
}
