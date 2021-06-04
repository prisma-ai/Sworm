public enum Query {}

public extension Query {
    static func not(
        _ original: Predicate
    ) -> Predicate {
        InversePredicate(
            original: original
        )
    }
}

public extension Query {
    static func and(
        _ left: Predicate,
        _ right: Predicate
    ) -> Predicate {
        CompoundPredicate(
            left: left,
            right: right,
            operator: .and
        )
    }

    static func or(
        _ left: Predicate,
        _ right: Predicate
    ) -> Predicate {
        CompoundPredicate(
            left: left,
            right: right,
            operator: .or
        )
    }
}

public extension Query {
    static func equalTo<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute>,
        _ value: Attribute
    ) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value.encodePrimitiveValue(),
            operator: .equalTo
        )
    }

    static func notEqualTo<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute>,
        _ value: Attribute
    ) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value.encodePrimitiveValue(),
            operator: .notEqualTo
        )
    }

    static func greaterThan<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute>,
        _ value: Attribute
    ) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value.encodePrimitiveValue(),
            operator: .greaterThan
        )
    }

    static func lessThan<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute>,
        _ value: Attribute
    ) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value.encodePrimitiveValue(),
            operator: .lessThan
        )
    }

    static func greaterThanOrEqualTo<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute>,
        _ value: Attribute
    ) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value.encodePrimitiveValue(),
            operator: .greaterThanOrEqualTo
        )
    }

    static func lessThanOrEqualTo<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute>,
        _ value: Attribute
    ) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value.encodePrimitiveValue(),
            operator: .lessThanOrEqualTo
        )
    }

    static func `in`<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute>,
        _ values: [Attribute]
    ) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: values.map { $0.encodePrimitiveValue() },
            operator: .in
        )
    }
}

public extension Query {
    static func equalTo<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute?>,
        _ value: Attribute?
    ) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value?.encodePrimitiveValue(),
            operator: .equalTo
        )
    }

    static func notEqualTo<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute?>,
        _ value: Attribute?
    ) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value?.encodePrimitiveValue(),
            operator: .notEqualTo
        )
    }

    static func greaterThan<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute?>,
        _ value: Attribute?
    ) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value?.encodePrimitiveValue(),
            operator: .greaterThan
        )
    }

    static func lessThan<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute?>,
        _ value: Attribute?
    ) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value?.encodePrimitiveValue(),
            operator: .lessThan
        )
    }

    static func greaterThanOrEqualTo<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute?>,
        _ value: Attribute?
    ) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value?.encodePrimitiveValue(),
            operator: .greaterThanOrEqualTo
        )
    }

    static func lessThanOrEqualTo<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute?>,
        _ value: Attribute?
    ) -> Predicate where Attribute.PrimitiveAttributeType: Comparable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: value?.encodePrimitiveValue(),
            operator: .lessThanOrEqualTo
        )
    }

    static func `in`<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute?>,
        _ values: [Attribute?]
    ) -> Predicate where Attribute.PrimitiveAttributeType: Equatable {
        ComparisonPredicate<PlainObject>(
            keyPath: keyPath,
            value: values.map { $0?.encodePrimitiveValue() },
            operator: .in
        )
    }
}

public extension Query {
    static func contains<PlainObject: ManagedObjectConvertible>(
        _ keyPath: KeyPath<PlainObject, String>,
        _ value: String,
        caseInsensitive: Bool = true
    ) -> Predicate {
        TextPredicate<PlainObject>(
            keyPath: keyPath,
            value: value,
            operator: .contains,
            caseInsensitive: caseInsensitive
        )
    }

    static func contains<PlainObject: ManagedObjectConvertible>(
        _ keyPath: KeyPath<PlainObject, String?>,
        _ value: String,
        caseInsensitive: Bool = true
    ) -> Predicate {
        TextPredicate<PlainObject>(
            keyPath: keyPath,
            value: value,
            operator: .contains,
            caseInsensitive: caseInsensitive
        )
    }

    static func beginsWith<PlainObject: ManagedObjectConvertible>(
        _ keyPath: KeyPath<PlainObject, String>,
        _ value: String,
        caseInsensitive: Bool = true
    ) -> Predicate {
        TextPredicate<PlainObject>(
            keyPath: keyPath,
            value: value,
            operator: .beginsWith,
            caseInsensitive: caseInsensitive
        )
    }

    static func beginsWith<PlainObject: ManagedObjectConvertible>(
        _ keyPath: KeyPath<PlainObject, String?>,
        _ value: String,
        caseInsensitive: Bool = true
    ) -> Predicate {
        TextPredicate<PlainObject>(
            keyPath: keyPath,
            value: value,
            operator: .beginsWith,
            caseInsensitive: caseInsensitive
        )
    }

    static func endsWith<PlainObject: ManagedObjectConvertible>(
        _ keyPath: KeyPath<PlainObject, String>,
        _ value: String,
        caseInsensitive: Bool = true
    ) -> Predicate {
        TextPredicate<PlainObject>(
            keyPath: keyPath,
            value: value,
            operator: .endsWith,
            caseInsensitive: caseInsensitive
        )
    }

    static func endsWith<PlainObject: ManagedObjectConvertible>(
        _ keyPath: KeyPath<PlainObject, String?>,
        _ value: String,
        caseInsensitive: Bool = true
    ) -> Predicate {
        TextPredicate<PlainObject>(
            keyPath: keyPath,
            value: value,
            operator: .endsWith,
            caseInsensitive: caseInsensitive
        )
    }
}
