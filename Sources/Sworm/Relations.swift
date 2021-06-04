public struct ToOneRelation<Destination: ManagedObjectConvertible> {
    let name: String

    public init(_ name: String) {
        self.name = name
    }
}

public struct ToManyRelation<Destination: ManagedObjectConvertible> {
    let name: String

    public init(_ name: String) {
        self.name = name
    }
}

public struct ToManyOrderedRelation<Destination: ManagedObjectConvertible> {
    let name: String

    public init(_ name: String) {
        self.name = name
    }
}
