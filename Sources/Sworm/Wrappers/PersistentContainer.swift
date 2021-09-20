import CoreData

public final class PersistentContainer {
    // MARK: Lifecycle

    public init(
        managedObjectContext: @escaping () throws -> NSManagedObjectContext,
        logError: ((Swift.Error) -> Void)? = nil,
        cleanUpAfterExecution: Bool = true
    ) {
        self.managedObjectContext = managedObjectContext
        self.logError = logError
        self.cleanUpAfterExecution = cleanUpAfterExecution
    }

    // MARK: Public

    public enum Error: Swift.Error {
        case noResult
    }

    @discardableResult
    public func perform<T>(
        action: @escaping (ManagedObjectContext) throws -> T
    ) throws -> T {
        do {
            let context = try self.managedObjectContext()
            let reset = self.cleanUpAfterExecution

            if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
                return try context.performAndWait {
                    try context.execute(reset, action)
                }
            } else {
                var result: Result<T, Swift.Error>?

                context.performAndWait {
                    result = Result(catching: {
                        try context.execute(reset, action)
                    })
                }

                switch result {
                case let .success(value):
                    return value
                case let .failure(error):
                    throw error
                case .none:
                    throw Self.Error.noResult
                }
            }
        } catch {
            self.logError?(error)

            throw error
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func schedule<T>(
        immediate: Bool = false,
        action: @escaping (ManagedObjectContext) throws -> T
    ) async throws -> T {
        do {
            let context = try self.managedObjectContext()
            let reset = self.cleanUpAfterExecution

            return try await context.perform(schedule: immediate ? .immediate : .enqueued) {
                try context.execute(reset, action)
            }
        } catch {
            self.logError?(error)

            throw error
        }
    }

    // MARK: Private

    private let managedObjectContext: () throws -> NSManagedObjectContext
    private let logError: ((Swift.Error) -> Void)?
    private let cleanUpAfterExecution: Bool
}
