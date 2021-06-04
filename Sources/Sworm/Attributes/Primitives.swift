import Foundation

public extension PrimitiveAttribute {
    func encodePrimitiveValue() -> Self { self }

    static func decode(primitiveValue: Self) throws -> Self { primitiveValue }
}

extension Bool: PrimitiveAttribute, SupportedAttributeType {}

extension Int: PrimitiveAttribute, SupportedAttributeType {}
extension Int16: PrimitiveAttribute, SupportedAttributeType {}
extension Int32: PrimitiveAttribute, SupportedAttributeType {}
extension Int64: PrimitiveAttribute, SupportedAttributeType {}

extension Float: PrimitiveAttribute, SupportedAttributeType {}
extension Double: PrimitiveAttribute, SupportedAttributeType {}
extension Decimal: PrimitiveAttribute, SupportedAttributeType {}

extension Date: PrimitiveAttribute, SupportedAttributeType {}
extension String: PrimitiveAttribute, SupportedAttributeType {}
extension Data: PrimitiveAttribute, SupportedAttributeType {}
extension UUID: PrimitiveAttribute, SupportedAttributeType {}
extension URL: PrimitiveAttribute, SupportedAttributeType {}
