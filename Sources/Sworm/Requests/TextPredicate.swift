enum TextOperator: String {
    case contains = "CONTAINS"
    case beginsWith = "BEGINSWITH"
    case endsWith = "ENDSWITH"
}

struct TextPredicate<PlainObject: ManagedObjectConvertible>: Predicate {
    let keyPath: PartialKeyPath<PlainObject>
    let value: String
    let `operator`: TextOperator
    let caseInsensitive: Bool

    var predicateDescriptor: PredicateDescriptor {
        .init(
            query: "\(PlainObject.attribute(self.keyPath).name) \(self.operator.rawValue)\(self.caseInsensitive ? "[cd]" : "") %@",
            args: [self.value]
        )
    }
}
