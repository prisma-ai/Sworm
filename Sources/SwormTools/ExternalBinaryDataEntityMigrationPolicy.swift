import CoreData

@objc(ExternalBinaryDataEntityMigrationPolicy)
open class ExternalBinaryDataEntityMigrationPolicy: NSEntityMigrationPolicy {
    open override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        let attributes = sInstance.entity.attributesByName.filter {
            $0.value.isOptional && $0.value.allowsExternalBinaryDataStorage
        }

        guard !attributes.isEmpty else {
            return
        }

        try manager.destinationContext.save()

        attributes.forEach {
            sInstance.setValue(nil, forKey: $0.key)
        }

        try manager.sourceContext.save()

        let destinationInstances = manager.destinationInstances(
            forEntityMappingName: mapping.name,
            sourceInstances: [sInstance]
        )

        destinationInstances.forEach {
            manager.destinationContext.refresh($0, mergeChanges: false)
        }
    }
}
