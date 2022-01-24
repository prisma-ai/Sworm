public prefix func ! (
    original: Predicate
) -> Predicate {
    Query.not(original)
}

public func && (
    left: Predicate,
    right: Predicate
) -> Predicate {
    Query.and(left, right)
}

public func || (
    left: Predicate,
    right: Predicate
) -> Predicate {
    Query.or(left, right)
}

public func == <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute>,
    value: Attribute
) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
    Query.equalTo(keyPath, value)
}

public func != <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute>,
    value: Attribute
) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
    Query.notEqualTo(keyPath, value)
}

public func > <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute>,
    value: Attribute
) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
    Query.greaterThan(keyPath, value)
}

public func < <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute>,
    value: Attribute
) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
    Query.lessThan(keyPath, value)
}

public func >= <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute>,
    value: Attribute
) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
    Query.greaterThanOrEqualTo(keyPath, value)
}

public func <= <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute>,
    value: Attribute
) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
    Query.lessThanOrEqualTo(keyPath, value)
}

public func === <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute>,
    values: [Attribute]
) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
    Query.in(keyPath, values)
}

public func == <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute?>,
    value: Attribute?
) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
    Query.equalTo(keyPath, value)
}

public func != <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute?>,
    value: Attribute?
) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
    Query.notEqualTo(keyPath, value)
}

public func > <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute?>,
    value: Attribute?
) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
    Query.greaterThan(keyPath, value)
}

public func < <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute?>,
    value: Attribute?
) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
    Query.lessThan(keyPath, value)
}

public func >= <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute?>,
    value: Attribute?
) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
    Query.greaterThanOrEqualTo(keyPath, value)
}

public func <= <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute?>,
    value: Attribute?
) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
    Query.lessThanOrEqualTo(keyPath, value)
}

public func === <PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
    keyPath: KeyPath<PlainObject, Attribute?>,
    values: [Attribute?]
) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
    Query.in(keyPath, values)
}
