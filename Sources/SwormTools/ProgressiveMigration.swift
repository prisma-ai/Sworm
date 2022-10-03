import CoreData

public final class SQLiteProgressiveMigration {
    public init?(
        store: SQLiteStoreDescription,
        bundle: Bundle,
        defaultEntityMigrationPolicyClassName: String? = nil,
        writableSourceStores: Bool = false
    ) throws {
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: store.url,
            options: nil
        ) else {
            return nil
        }

        let models: [NSManagedObjectModel] = try store.modelVersions.map { version in
            try bundle.managedObjectModel(versionName: version.name, modelName: store.modelName)
        }

        guard let currentModelIndex = models.firstIndex(where: {
            $0.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }) else {
            throw Error.storeCompatibleModelNotFound
        }

        let modelIndicesToMigrate = models.indices.dropFirst(currentModelIndex)

        let steps = try zip(modelIndicesToMigrate.dropLast(), modelIndicesToMigrate.dropFirst()).map {
            try Step(
                sourceModel: models[$0],
                destinationModel: models[$1],
                source: store.modelVersions[$1].mappingModelName.flatMap { .bundle(bundle, $0) } ?? .auto,
                defaultEntityMigrationPolicyClassName: defaultEntityMigrationPolicyClassName
            )
        }

        guard !steps.isEmpty else {
            return nil
        }

        self.originalStoreURL = store.url
        self.metadata = metadata
        self.currentModel = models[currentModelIndex]
        self.bundle = bundle
        self.steps = steps
        self.currentModelIndex = currentModelIndex
        self.writableSourceStores = writableSourceStores
    }

    public enum Error: Swift.Error {
        case storeCompatibleModelNotFound
    }

    public typealias Progress = (Int, Int) -> Void

    public let currentModelIndex: Int

    public var stepCount: Int {
        self.steps.count
    }

    public func performMigration(
        progress: Progress?,
        temporaryDirectory: URL = FileManager.default.temporaryDirectory
    ) throws {
        let storeCoordinator = NSPersistentStoreCoordinator(
            managedObjectModel: self.currentModel
        )

        try storeCoordinator.checkpointWAL(at: self.originalStoreURL)

        progress?(0, self.steps.count)

        var currentStoreURL = self.originalStoreURL

        for (index, step) in self.steps.enumerated() {
            let newStoreURL = temporaryDirectory.appendingPathComponent(UUID().uuidString)

            try autoreleasepool {
                try step.migrate(
                    from: currentStoreURL,
                    to: newStoreURL,
                    readOnlySource: !self.writableSourceStores
                )
            }

            if currentStoreURL != self.originalStoreURL {
                try storeCoordinator.destroySQLiteStore(at: currentStoreURL)
            }

            currentStoreURL = newStoreURL

            progress?(index + 1, self.steps.count)
        }

        try storeCoordinator.replaceSQLiteStore(
            at: self.originalStoreURL,
            with: currentStoreURL
        )

        if currentStoreURL != self.originalStoreURL {
            try storeCoordinator.destroySQLiteStore(at: currentStoreURL)
        }
    }

    final class Step {
        init(
            sourceModel: NSManagedObjectModel,
            destinationModel: NSManagedObjectModel,
            source: Source,
            defaultEntityMigrationPolicyClassName: String?
        ) throws {
            let mappingModel: NSMappingModel

            switch source {
            case .auto:
                mappingModel = try NSMappingModel.inferredMappingModel(
                    forSourceModel: sourceModel,
                    destinationModel: destinationModel
                )
            case let .bundle(bundle, name):
                mappingModel = try bundle.mappingModel(name: name)
            }

            if let defaultEntityMigrationPolicyClassName {
                mappingModel.entityMappings.forEach {
                    if $0.entityMigrationPolicyClassName == nil {
                        $0.entityMigrationPolicyClassName = defaultEntityMigrationPolicyClassName
                    }
                }
            }

            self.sourceModel = sourceModel
            self.destinationModel = destinationModel
            self.mappingModel = mappingModel
        }

        enum Source {
            case auto
            case bundle(Bundle, String)
        }

        let sourceModel: NSManagedObjectModel
        let destinationModel: NSManagedObjectModel
        let mappingModel: NSMappingModel

        func migrate(
            from sourceURL: URL,
            to destinationURL: URL,
            readOnlySource: Bool
        ) throws {
            try NSMigrationManager(
                sourceModel: self.sourceModel,
                destinationModel: self.destinationModel
            ).migrateStore(
                from: sourceURL,
                sourceType: NSSQLiteStoreType,
                options: [NSReadOnlyPersistentStoreOption: NSNumber(value: readOnlySource)],
                with: self.mappingModel,
                toDestinationURL: destinationURL,
                destinationType: NSSQLiteStoreType,
                destinationOptions: nil
            )
        }
    }

    let originalStoreURL: URL
    let metadata: [String: Any]
    let currentModel: NSManagedObjectModel
    let bundle: Bundle
    let steps: [Step]
    let writableSourceStores: Bool
}
