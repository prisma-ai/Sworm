public struct ToOneRelation<Destination: ManagedObjectConvertible> {
    public init(_ name: String) {
        self.name = name
    }

    let name: String
}

public struct ToManyRelation<Destination: ManagedObjectConvertible> {
    public init(_ name: String) {
        self.name = name
    }

    let name: String
}

public struct ToManyOrderedRelation<Destination: ManagedObjectConvertible> {
    public init(_ name: String) {
        self.name = name
    }

    let name: String
}
