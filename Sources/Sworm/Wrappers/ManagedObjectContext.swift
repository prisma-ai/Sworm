import CoreData

public final class ManagedObjectContext {
    // MARK: Lifecycle

    internal init(_ instance: NSManagedObjectContext) {
        self.instance = instance
    }

    // MARK: Public

    @discardableResult
    public func insert<PlainObject: ManagedObjectConvertible>(_ value: PlainObject) throws -> ManagedObject<PlainObject> {
        let managedObject = try DataHelper.insert(entity: PlainObject.entityName, into: self.instance)

        return ManagedObject(instance: managedObject).encode(value)
    }

    public func delete<PlainObject: ManagedObjectConvertible>(
        _ managedObject: ManagedObject<PlainObject>
    ) {
        self.instance.delete(managedObject.instance)
    }

    public func delete<PlainObject: ManagedObjectConvertible>(
        _ request: Request<PlainObject>
    ) throws {
        let fetchRequest = request.makeFetchRequest(
            ofType: (NSManagedObject.self, .managedObjectResultType),
            attributesToFetch: []
        )

        try self.instance.fetch(fetchRequest).forEach {
            self.instance.delete($0)
        }
    }

    @discardableResult
    public func batchDelete<PlainObject: ManagedObjectConvertible>(
        _ request: Request<PlainObject>
    ) throws -> Int {
        let fetchRequest = request.makeFetchRequest(
            ofType: (NSFetchRequestResult.self, .managedObjectIDResultType),
            attributesToFetch: []
        )

        let batchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchRequest.resultType = .resultTypeCount

        let batchResult = try self.instance.execute(batchRequest) as! NSBatchDeleteResult
        return (batchResult.result as! NSNumber).intValue
    }

    @discardableResult
    public func count<PlainObject: ManagedObjectConvertible>(
        of request: Request<PlainObject>
    ) throws -> Int {
        let fetchRequest = request.makeFetchRequest(
            ofType: (NSNumber.self, .countResultType),
            attributesToFetch: []
        )

        return try self.instance.count(for: fetchRequest)
    }

    @discardableResult
    public func fetch<PlainObject: ManagedObjectConvertible>(
        _ request: Request<PlainObject>
    ) throws -> [ManagedObject<PlainObject>] {
        let fetchRequest = request.makeFetchRequest(
            ofType: (NSManagedObject.self, .managedObjectResultType)
        )

        return try self.instance.fetch(fetchRequest).map {
            .init(instance: $0)
        }
    }

    @discardableResult
    public func fetch<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ request: Request<PlainObject>,
        _ keyPath: KeyPath<PlainObject, Attribute>
    ) throws -> [Attribute] {
        let attribute = PlainObject.attribute(keyPath)
        let fetchRequest = request.makeFetchRequest(
            ofType: (NSDictionary.self, .dictionaryResultType),
            attributesToFetch: [attribute]
        )

        return try self.instance.fetch(fetchRequest).map {
            try Attribute.decode($0[attribute.name])
        }
    }

    @discardableResult
    public func fetch<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ request: Request<PlainObject>,
        _ keyPath: KeyPath<PlainObject, Attribute?>
    ) throws -> [Attribute?] {
        let attribute = PlainObject.attribute(keyPath)
        let fetchRequest = request.makeFetchRequest(
            ofType: (NSDictionary.self, .dictionaryResultType),
            attributesToFetch: [attribute]
        )

        return try self.instance.fetch(fetchRequest).map {
            try Attribute?.decode($0[attribute.name])
        }
    }

    // MARK: Internal

    unowned let instance: NSManagedObjectContext
}

public extension ManagedObjectContext {
    @discardableResult
    func fetchOne<PlainObject: ManagedObjectConvertible>(
        _ request: Request<PlainObject>
    ) throws -> ManagedObject<PlainObject>? {
        try self.fetch(request.limit(1)).first
    }

    @discardableResult
    func fetchOne<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ request: Request<PlainObject>,
        _ keyPath: KeyPath<PlainObject, Attribute>
    ) throws -> Attribute? {
        try self.fetch(request.limit(1), keyPath).first
    }

    @discardableResult
    func fetchOne<PlainObject: ManagedObjectConvertible, Attribute: SupportedAttributeType>(
        _ request: Request<PlainObject>,
        _ keyPath: KeyPath<PlainObject, Attribute?>
    ) throws -> Attribute? {
        try self.fetch(request.limit(1), keyPath).first ?? nil
    }
}
