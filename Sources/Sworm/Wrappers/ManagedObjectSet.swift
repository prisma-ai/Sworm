import CoreData

public struct ManagedObjectSetIterator<PlainObject: ManagedObjectConvertible>: IteratorProtocol {
    internal init(iterator: NSFastEnumerationIterator) {
        self.iterator = iterator
    }

    public mutating func next() -> ManagedObject<PlainObject>? {
        (self.iterator.next() as? NSManagedObject).flatMap {
            .init(instance: $0)
        }
    }

    private var iterator: NSFastEnumerationIterator
}

public final class ManagedObjectSet<PlainObject: ManagedObjectConvertible>: Sequence {
    internal init(name: String, instance: NSManagedObject) {
        self.name = name
        self.instance = instance
    }

    public func makeIterator() -> ManagedObjectSetIterator<PlainObject> {
        .init(iterator: self.set.makeIterator())
    }

    public func add(_ object: ManagedObject<PlainObject>) {
        self.set.add(object.instance)
    }

    public func remove(_ object: ManagedObject<PlainObject>) {
        self.set.remove(object.instance)
    }

    let name: String

    unowned let instance: NSManagedObject

    private var set: NSMutableSet {
        self.instance.mutableSetValue(forKey: self.name)
    }
}

public final class ManagedObjectOrderedSet<PlainObject: ManagedObjectConvertible>: Sequence {
    internal init(name: String, instance: NSManagedObject) {
        self.name = name
        self.instance = instance
    }

    public func makeIterator() -> ManagedObjectSetIterator<PlainObject> {
        .init(iterator: self.set.makeIterator())
    }

    public func add(_ object: ManagedObject<PlainObject>) {
        self.set.add(object.instance)
    }

    public func remove(_ object: ManagedObject<PlainObject>) {
        self.set.remove(object.instance)
    }

    let name: String

    unowned let instance: NSManagedObject

    private var set: NSMutableOrderedSet {
        self.instance.mutableOrderedSetValue(forKey: self.name)
    }
}

public extension ManagedObjectSet {
    func delete(_ object: ManagedObject<PlainObject>, context: ManagedObjectContext) {
        self.remove(object)

        context.delete(object)
    }
}

public extension ManagedObjectOrderedSet {
    func delete(_ object: ManagedObject<PlainObject>, context: ManagedObjectContext) {
        self.remove(object)

        context.delete(object)
    }
}
