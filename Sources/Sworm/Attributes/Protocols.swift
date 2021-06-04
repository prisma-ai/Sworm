public protocol PrimitiveAttribute {}

public protocol SupportedAttributeType {
    associatedtype PrimitiveAttributeType: PrimitiveAttribute

    func encodePrimitiveValue() -> PrimitiveAttributeType

    static func decode(primitiveValue: PrimitiveAttributeType) throws -> Self
}
