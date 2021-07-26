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

    @discardableResult
    public func perform<T>(action: @escaping (ManagedObjectContext) throws -> T) throws -> T {
        do {
            let context = try self.managedObjectContext()

            return try DataHelper.performAndWait(in: context, resetAfterExecution: self.cleanUpAfterExecution) {
                try action(.init(context))
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
