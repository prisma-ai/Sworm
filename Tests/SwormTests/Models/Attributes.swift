import Foundation
import Sworm

struct JSON<T: Codable>: SupportedAttributeType {
    // MARK: Lifecycle

    init(_ value: T) {
        self.value = value
    }

    // MARK: Internal

    var value: T

    static func decode(primitiveValue: Data) throws -> JSON<T> {
        .init(try JSONDecoder().decode(T.self, from: primitiveValue))
    }

    func encodePrimitiveValue() -> Data {
        try! JSONEncoder().encode(self.value)
    }
}

extension JSON: Equatable where T: Equatable {}
extension JSON: Hashable where T: Hashable {}

struct LSC<T: LosslessStringConvertible>: SupportedAttributeType {
    // MARK: Lifecycle

    init(_ value: T) {
        self.value = value
    }

    // MARK: Internal

    var value: T

    static func decode(primitiveValue: String) throws -> LSC<T> {
        guard let value = T(primitiveValue) else {
            throw AttributeError.badInput(primitiveValue)
        }
        return .init(value)
    }

    func encodePrimitiveValue() -> String {
        self.value.description
    }
}

extension LSC: Equatable where T: Equatable {}
extension LSC: Hashable where T: Hashable {}
