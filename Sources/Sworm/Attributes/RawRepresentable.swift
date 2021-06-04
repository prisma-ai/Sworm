public extension RawRepresentable where RawValue: SupportedAttributeType {
    func encodePrimitiveValue() -> RawValue.PrimitiveAttributeType {
        self.rawValue.encodePrimitiveValue()
    }

    static func decode(primitiveValue: RawValue.PrimitiveAttributeType) throws -> Self {
        let rawValue = try RawValue.decode(primitiveValue: primitiveValue)
        guard let value = Self(rawValue: rawValue) else {
            throw AttributeError.badInput(rawValue)
        }
        return value
    }
}
