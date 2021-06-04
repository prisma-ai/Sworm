enum LogicalOperator: String {
    case and = "AND"
    case or = "OR"
}

struct CompoundPredicate: Predicate {
    let left: Predicate
    let right: Predicate
    let `operator`: LogicalOperator

    var predicateDescriptor: PredicateDescriptor {
        let leftDescriptor = self.left.predicateDescriptor
        let rightDescriptor = self.right.predicateDescriptor

        return .init(
            query: "(\(leftDescriptor.query)) \(self.operator.rawValue) (\(rightDescriptor.query))",
            args: leftDescriptor.args + rightDescriptor.args
        )
    }
}
