import CoreData

public extension NSManagedObject {
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

public enum DataHelper {
    public enum Error: Swift.Error {
        case unknownEntity(String)
        case noResult
    }

    public static func insert(
        entity name: String,
        into context: NSManagedObjectContext
    ) throws -> NSManagedObject {
        guard let coordinator = context.persistentStoreCoordinator,
              let entity = coordinator.managedObjectModel.entitiesByName[name]
        else {
            throw Error.unknownEntity(name)
        }

        return .init(entity: entity, insertInto: context)
    }

    public static func performAndWait<T>(
        in context: NSManagedObjectContext,
        resetAfterExecution: Bool,
        _ action: @escaping () throws -> T
    ) throws -> T {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            return try context.performAndWait {
                let value = try action()

                if context.hasChanges {
                    try context.save()
                }

                if resetAfterExecution {
                    context.reset()
                }

                return value
            }
        } else {
            var result: Result<T, Swift.Error>?

            context.performAndWait {
                result = Result(catching: {
                    let value = try action()
                    if context.hasChanges {
                        try context.save()
                    }
                    return value
                })

                if resetAfterExecution {
                    context.reset()
                }
            }

            switch result {
            case let .success(value):
                return value
            case let .failure(error):
                throw error
            case .none:
                throw Error.noResult
            }
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public static func schedule<T>(
        in context: NSManagedObjectContext,
        immediate: Bool,
        resetAfterExecution: Bool,
        _ action: @escaping () throws -> T
    ) async throws -> T {
        try await context.perform(schedule: immediate ? .immediate : .enqueued) {
            let value = try action()

            if context.hasChanges {
                try context.save()
            }

            if resetAfterExecution {
                context.reset()
            }

            return value
        }
    }
}
