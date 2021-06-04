public protocol ManagedObjectConvertible {
    associatedtype Relations

    static var entityName: String { get }
    static var attributes: Set<Attribute<Self>> { get }
    static var relations: Relations { get }

    init()
}
