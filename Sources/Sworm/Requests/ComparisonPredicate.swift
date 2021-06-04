enum ComparisonOperator: String {
    case equalTo = "=="
    case notEqualTo = "!="
    case lessThan = "<"
    case lessThanOrEqualTo = "<="
    case greaterThan = ">"
    case greaterThanOrEqualTo = ">="

    case `in` = "IN"
}

struct ComparisonPredicate<PlainObject: ManagedObjectConvertible>: Predicate {
    let keyPath: PartialKeyPath<PlainObject>
    let value: Any?
    let `operator`: ComparisonOperator

    var predicateDescriptor: PredicateDescriptor {
        .init(
            query: "\(PlainObject.attribute(self.keyPath).name) \(self.operator.rawValue) %@",
            args: [self.value as Any]
        )
    }
}
