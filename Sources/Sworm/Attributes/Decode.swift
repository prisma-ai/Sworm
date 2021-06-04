extension SupportedAttributeType {
    static func decode(_ anyValue: Any?) throws -> Self {
        guard let value = anyValue as? Self.PrimitiveAttributeType else {
            throw AttributeError.badInput(anyValue)
        }
        return try Self.decode(primitiveValue: value)
    }
}

extension Optional where Wrapped: SupportedAttributeType {
    static func decode(_ anyValue: Any?) throws -> Wrapped? {
        try anyValue.flatMap {
            try Wrapped.decode($0)
        }
    }
}
