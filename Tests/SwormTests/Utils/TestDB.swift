import CoreData
import Foundation
import Sworm
import SwormTools
import XCTest

enum TestDB {
    static func temporaryContainer(
        store: SQLiteStoreDescription,
        overwriteMergePolicy: Bool = false,
        action: (PersistentContainer) throws -> Void
    ) {
        do {
            let inMemoryStore = store.with(url: .devNull)
            let container = try NSPersistentContainer(store: inMemoryStore, bundle: .module)
            try container.loadPersistentStore()
            try action(.init(managedObjectContext: {
                let context = container.newBackgroundContext()
                if overwriteMergePolicy {
                    context.mergePolicy = NSOverwriteMergePolicy
                }
                return context
            }))
            try container.removePersistentStores()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
