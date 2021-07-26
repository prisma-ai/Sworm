import CoreData

public final class SQLiteProgressiveMigration {
    // MARK: Lifecycle

    public init?(store: SQLiteStoreDescription, bundle: Bundle) throws {
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
                source: store.modelVersions[$1].mappingModelName.flatMap { .bundle(bundle, $0) } ?? .auto
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
    }

    // MARK: Public

    public enum Error: Swift.Error {
        case storeCompatibleModelNotFound
    }

    public typealias Progress = (Int, Int) -> Void

    public var stepCount: Int {
        self.steps.count
    }

    public func performMigration(progress: Progress?) throws {
        let storeCoordinator = NSPersistentStoreCoordinator(
            managedObjectModel: self.currentModel
        )

        try storeCoordinator.checkpointWAL(at: self.originalStoreURL)

        progress?(0, self.steps.count)

        var currentStoreURL = self.originalStoreURL

        for (index, step) in self.steps.enumerated() {
            let newStoreURL = URL(
                fileURLWithPath: NSTemporaryDirectory(),
                isDirectory: true
            ).appendingPathComponent(
                UUID().uuidString
            )

            try step.migrate(
                from: currentStoreURL,
                to: newStoreURL
            )

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

    // MARK: Internal

    final class Step {
        // MARK: Lifecycle

        init(
            sourceModel: NSManagedObjectModel,
            destinationModel: NSManagedObjectModel,
            source: Source
        ) throws {
            switch source {
            case .auto:
                self.mappingModel = try NSMappingModel.inferredMappingModel(
                    forSourceModel: sourceModel,
                    destinationModel: destinationModel
                )
            case let .bundle(bundle, name):
                self.mappingModel = try bundle.mappingModel(name: name)
            }
            self.sourceModel = sourceModel
            self.destinationModel = destinationModel
        }

        // MARK: Internal

        enum Source {
            case auto
            case bundle(Bundle, String)
        }

        let sourceModel: NSManagedObjectModel
        let destinationModel: NSManagedObjectModel
        let mappingModel: NSMappingModel

        func migrate(from sourceURL: URL, to destinationURL: URL) throws {
            try NSMigrationManager(
                sourceModel: self.sourceModel,
                destinationModel: self.destinationModel
            ).migrateStore(
                from: sourceURL,
                sourceType: NSSQLiteStoreType,
                options: nil,
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
}
