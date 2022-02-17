import Foundation
import Sworm
import SwormTools

enum DataModels {
    static let attributes = SQLiteStoreDescription(
        name: "AttributeSetsDataModel",
        url: FileManager.default.temporaryDirectory,
        modelName: "AttributeSetsDataModel",
        modelVersions: ["V0"]
    )

    static let predicates = SQLiteStoreDescription(
        name: "PredicateDataModel",
        url: FileManager.default.temporaryDirectory,
        modelName: "PredicateDataModel",
        modelVersions: ["V0"]
    )

    static let bookLibrary = SQLiteStoreDescription(
        name: "BookLibraryDataModel",
        url: FileManager.default.temporaryDirectory,
        modelName: "BookLibraryDataModel",
        modelVersions: ["V0"]
    )

    static let migrations = SQLiteStoreDescription(
        name: "MigratableStore",
        url: FileManager.default.temporaryDirectory,
        modelName: "MigratableDataModel",
        modelVersions: [
            "V0",
            .init(name: "V1", mappingModelName: "V0V1"),
            .init(name: "V2", mappingModelName: "V1V2"),
            "V3",
        ]
    )

    static let repo = SQLiteStoreDescription(
        name: "RepoDataModel",
        url: FileManager.default.temporaryDirectory,
        modelName: "RepoDataModel",
        modelVersions: ["V0"]
    )

    static let blob = SQLiteStoreDescription(
        name: "BLOBModel",
        url: FileManager.default.temporaryDirectory,
        modelName: "BLOBModel",
        modelVersions: ["V0", "V1", "V2", "V3"]
    )
}
