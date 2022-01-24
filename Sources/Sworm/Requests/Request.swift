import CoreData

public extension ManagedObjectConvertible {
    static var all: Request<Self> {
        .init(
            fetchLimit: nil,
            fetchOffset: nil,
            predicateDescriptor: nil,
            sortDescriptors: []
        )
    }
}

public struct Request<PlainObject: ManagedObjectConvertible> {
    public func limit(_ value: Int) -> Request<PlainObject> {
        .init(
            fetchLimit: value,
            fetchOffset: self.fetchOffset,
            predicateDescriptor: self.predicateDescriptor,
            sortDescriptors: self.sortDescriptors
        )
    }

    public func offset(_ value: Int) -> Request<PlainObject> {
        .init(
            fetchLimit: self.fetchLimit,
            fetchOffset: value,
            predicateDescriptor: self.predicateDescriptor,
            sortDescriptors: self.sortDescriptors
        )
    }

    public func `where`(raw query: String, _ args: Any...) -> Request<PlainObject> {
        .init(
            fetchLimit: self.fetchLimit,
            fetchOffset: self.fetchOffset,
            predicateDescriptor: .init(query: query, args: args),
            sortDescriptors: self.sortDescriptors
        )
    }

    public func `where`(_ predicate: Predicate) -> Request<PlainObject> {
        .init(
            fetchLimit: self.fetchLimit,
            fetchOffset: self.fetchOffset,
            predicateDescriptor: predicate.predicateDescriptor,
            sortDescriptors: self.sortDescriptors
        )
    }

    public func sort<Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute>,
        ascending: Bool = true
    ) -> Request<PlainObject> where Attribute.PrimitiveAttributeType: Comparable {
        .init(
            fetchLimit: self.fetchLimit,
            fetchOffset: self.fetchOffset,
            predicateDescriptor: self.predicateDescriptor,
            sortDescriptors: self.sortDescriptors + [(keyPath, ascending)]
        )
    }

    public func sort<Attribute: SupportedAttributeType>(
        _ keyPath: KeyPath<PlainObject, Attribute?>,
        ascending: Bool = true
    ) -> Request<PlainObject> where Attribute.PrimitiveAttributeType: Comparable {
        .init(
            fetchLimit: self.fetchLimit,
            fetchOffset: self.fetchOffset,
            predicateDescriptor: self.predicateDescriptor,
            sortDescriptors: self.sortDescriptors + [(keyPath, ascending)]
        )
    }

    typealias SortDescriptor = (keyPath: PartialKeyPath<PlainObject>, ascending: Bool)

    let fetchLimit: Int?
    let fetchOffset: Int?

    let predicateDescriptor: PredicateDescriptor?
    let sortDescriptors: [SortDescriptor]
}

extension Request {
    func makeFetchRequest<ResultType: NSFetchRequestResult>(
        ofType resultType: (ResultType.Type, NSFetchRequestResultType),
        attributesToFetch: Set<Attribute<PlainObject>>? = nil
    ) -> NSFetchRequest<ResultType> {
        let propertiesToFetch = (attributesToFetch ?? PlainObject.attributes).map(\.name)

        let fetchRequest = NSFetchRequest<ResultType>(entityName: PlainObject.entityName)
        fetchRequest.resultType = resultType.1
        fetchRequest.propertiesToFetch = propertiesToFetch
        fetchRequest.includesPropertyValues = !propertiesToFetch.isEmpty

        self.fetchLimit.flatMap {
            fetchRequest.fetchLimit = $0
        }
        self.fetchOffset.flatMap {
            fetchRequest.fetchOffset = $0
        }
        self.predicateDescriptor.flatMap {
            fetchRequest.predicate = NSPredicate(
                format: $0.query,
                argumentArray: $0.args
            )
        }
        if !self.sortDescriptors.isEmpty {
            fetchRequest.sortDescriptors = self.sortDescriptors.map {
                NSSortDescriptor(
                    key: PlainObject.attribute($0.keyPath).name,
                    ascending: $0.ascending
                )
            }
        }

        return fetchRequest
    }
}
