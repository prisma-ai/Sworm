import CoreData

public struct SQLiteStoreDescription {
    public init(
        name: String,
        url: URL,
        modelName: String,
        modelVersions: [ModelVersion]
    ) {
        assert(!modelVersions.isEmpty)

        self.name = name
        self.url = url
        self.modelName = modelName
        self.modelVersions = modelVersions
    }

    public struct ModelVersion: ExpressibleByStringLiteral {
        public init(
            name: String,
            mappingModelName: String?
        ) {
            self.name = name
            self.mappingModelName = mappingModelName
        }

        public init(stringLiteral value: String) {
            self.name = value
            self.mappingModelName = nil
        }

        public let name: String
        public let mappingModelName: String?
    }

    public let name: String
    public let url: URL
    public let modelName: String
    public let modelVersions: [ModelVersion]

    public func with(url: URL) -> SQLiteStoreDescription {
        .init(
            name: self.name,
            url: url,
            modelName: self.modelName,
            modelVersions: self.modelVersions
        )
    }

    public func with(maxVersion: Int) -> SQLiteStoreDescription {
        .init(
            name: self.name,
            url: self.url,
            modelName: self.modelName,
            modelVersions: Array(self.modelVersions[0 ... maxVersion])
        )
    }
}
