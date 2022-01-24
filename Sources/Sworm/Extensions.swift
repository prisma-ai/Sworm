import CoreData

internal extension NSManagedObject {
    subscript(primitiveValue key: String) -> Any? {
        get {
            self.willAccessValue(forKey: key)
            defer { self.didAccessValue(forKey: key) }
            return self.primitiveValue(forKey: key)
        }
        set {
            self.willChangeValue(forKey: key)
            self.setPrimitiveValue(newValue, forKey: key)
            self.didChangeValue(forKey: key)
        }
    }
}

internal extension NSManagedObjectContext {
    func execute<T>(
        _ reset: Bool,
        _ action: @escaping (ManagedObjectContext) throws -> T
    ) throws -> T {
        defer {
            if reset {
                self.reset()
            }
        }
        let result = try action(.init(self))
        if self.hasChanges {
            try self.save()
        }
        return result
    }

    func insert(entity name: String) -> NSManagedObject? {
        self.persistentStoreCoordinator
            .flatMap { $0.managedObjectModel.entitiesByName[name] }
            .flatMap { .init(entity: $0, insertInto: self) }
    }
}
