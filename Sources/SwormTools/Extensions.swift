import CoreData

public extension URL {
    static var devNull: URL {
        URL(fileURLWithPath: "/dev/null")
    }
}

public extension Bundle {
    enum BundleCoreDataError: Swift.Error {
        case mappingModelNotFound(name: String)
        case managedObjectModelNotFound(versionName: String, modelName: String)
    }

    func mappingModel(name: String) throws -> NSMappingModel {
        guard let url = self.url(forResource: name, withExtension: "cdm"), let model = NSMappingModel(contentsOf: url) else {
            throw BundleCoreDataError.mappingModelNotFound(name: name)
        }
        return model
    }

    func managedObjectModel(versionName: String, modelName: String) throws -> NSManagedObjectModel {
        guard let model = self.mom(versionName, modelName, optimized: true) ?? self.mom(versionName, modelName, optimized: false) else {
            throw BundleCoreDataError.managedObjectModelNotFound(versionName: versionName, modelName: modelName)
        }
        return model
    }

    private func mom(_ v: String, _ d: String, optimized: Bool) -> NSManagedObjectModel? {
        self.url(forResource: v, withExtension: optimized ? "omo" : "mom", subdirectory: "\(d).momd").flatMap {
            NSManagedObjectModel(contentsOf: $0)
        }
    }
}

public extension NSPersistentContainer {
    convenience init(store: SQLiteStoreDescription, bundle: Bundle) throws {
        let model = try bundle.managedObjectModel(
            versionName: store.modelVersions.last!.name,
            modelName: store.modelName
        )

        self.init(name: store.name, managedObjectModel: model)

        self.persistentStoreDescriptions = [.init(store: store)]
    }

    func loadPersistentStore() throws {
        assert(self.persistentStoreDescriptions.count == 1)

        var loadError: Swift.Error?
        self.loadPersistentStores { _, error in
            loadError = error
        }
        try loadError.flatMap { throw $0 }
    }

    func removePersistentStores() throws {
        try self.persistentStoreCoordinator.removePersistentStores()
    }
}

public extension NSPersistentStoreDescription {
    convenience init(store: SQLiteStoreDescription) {
        self.init(url: store.url)

        self.type = NSSQLiteStoreType
        self.shouldAddStoreAsynchronously = false
        self.shouldInferMappingModelAutomatically = false
        self.shouldMigrateStoreAutomatically = false
    }
}

// MARK: - Internal

extension FileManager {
    func createUniqueTemporaryDirectory() throws -> URL {
        let url = self.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try self.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
}

extension NSPersistentStoreCoordinator {
    func removePersistentStores() throws {
        try self.persistentStores.forEach {
            try self.remove($0)
        }
    }

    /// https://developer.apple.com/library/archive/qa/qa1809/_index.html
    /// https://sqlite.org/wal.html
    func checkpointWAL(at url: URL) throws {
        try self.remove(try self.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: url,
            options: [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
        ))
    }

    func replaceSQLiteStore(
        at destinationURL: URL,
        with sourceURL: URL
    ) throws {
        try self.replacePersistentStore(
            at: destinationURL,
            destinationOptions: nil,
            withPersistentStoreFrom: sourceURL,
            sourceOptions: nil,
            ofType: NSSQLiteStoreType
        )
    }

    func destroySQLiteStore(at url: URL) throws {
        try self.destroyPersistentStore(
            at: url,
            ofType: NSSQLiteStoreType,
            options: nil
        )
    }
}
