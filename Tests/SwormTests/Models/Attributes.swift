import Foundation
import Sworm

struct JSON<T: Codable>: SupportedAttributeType {
    var value: T

    init(_ value: T) {
        self.value = value
    }

    func encodePrimitiveValue() -> Data {
        try! JSONEncoder().encode(self.value)
    }

    static func decode(primitiveValue: Data) throws -> JSON<T> {
        .init(try JSONDecoder().decode(T.self, from: primitiveValue))
    }
}

extension JSON: Equatable where T: Equatable {}
extension JSON: Hashable where T: Hashable {}

struct LSC<T: LosslessStringConvertible>: SupportedAttributeType {
    var value: T

    init(_ value: T) {
        self.value = value
    }

    func encodePrimitiveValue() -> String {
        self.value.description
    }

    static func decode(primitiveValue: String) throws -> LSC<T> {
        guard let value = T(primitiveValue) else {
            throw AttributeError.badInput(primitiveValue)
        }
        return .init(value)
    }
}

extension LSC: Equatable where T: Equatable {}
extension LSC: Hashable where T: Hashable {}
