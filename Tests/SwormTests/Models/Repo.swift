import Foundation
import Sworm

protocol IdentifiableManagedObjectConvertible: ManagedObjectConvertible {
    associatedtype ID: SupportedAttributeType where ID.PrimitiveAttributeType: Equatable

    static var idKeyPath: KeyPath<Self, ID> { get }
}

final class Repo<T: IdentifiableManagedObjectConvertible> {
    private let pc: PersistentContainer

    init(pc: PersistentContainer) {
        self.pc = pc
    }

    func fetchAll() throws -> [T] {
        try self.pc.perform { context in
            try context.fetch(T.all).map { try $0.decode() }
        }
    }

    func insert(item: T) throws {
        try self.pc.perform { context in
            try context.insert(item)
        }
    }

    func delete(item: T) throws {
        try self.pc.perform { context in
            try context.delete(T.all.where(T.idKeyPath == item[keyPath: T.idKeyPath]))
        }
    }
}

struct RepoEntity: Equatable {
    var id: UUID = .init()
    var text: String = ""
}

extension RepoEntity: IdentifiableManagedObjectConvertible {
    static let entityName: String = "Entity"

    static var idKeyPath: KeyPath = \Self.id

    static let attributes: Set<Attribute<RepoEntity>> = [
        .init(\.id, "id"),
        .init(\.text, "text"),
    ]

    static let relations: Void = ()
}
