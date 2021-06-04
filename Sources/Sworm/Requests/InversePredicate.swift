struct InversePredicate: Predicate {
    let original: Predicate

    var predicateDescriptor: PredicateDescriptor {
        let originalDescriptor = self.original.predicateDescriptor

        return .init(
            query: "NOT (\(originalDescriptor.query))",
            args: originalDescriptor.args
        )
    }
}
