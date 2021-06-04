public struct PredicateDescriptor {
    let query: String
    let args: [Any]
}

public protocol Predicate {
    var predicateDescriptor: PredicateDescriptor { get }
}

extension String: Predicate {
    public var predicateDescriptor: PredicateDescriptor {
        .init(query: self, args: [])
    }
}
