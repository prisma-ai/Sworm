public struct ToOneRelation<Destination: ManagedObjectConvertible> {
    // MARK: Lifecycle

    public init(_ name: String) {
        self.name = name
    }

    // MARK: Internal

    let name: String
}

public struct ToManyRelation<Destination: ManagedObjectConvertible> {
    // MARK: Lifecycle

    public init(_ name: String) {
        self.name = name
    }

    // MARK: Internal

    let name: String
}

public struct ToManyOrderedRelation<Destination: ManagedObjectConvertible> {
    // MARK: Lifecycle

    public init(_ name: String) {
        self.name = name
    }

    // MARK: Internal

    let name: String
}
