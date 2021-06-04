import CoreData

public struct ManagedObjectSetIterator<PlainObject: ManagedObjectConvertible>: IteratorProtocol {
    private var iterator: NSFastEnumerationIterator

    internal init(iterator: NSFastEnumerationIterator) {
        self.iterator = iterator
    }

    public mutating func next() -> ManagedObject<PlainObject>? {
        (self.iterator.next() as? NSManagedObject).flatMap {
            .init(instance: $0)
        }
    }
}

public final class ManagedObjectSet<PlainObject: ManagedObjectConvertible>: Sequence {
    let name: String

    unowned let instance: NSManagedObject

    internal init(name: String, instance: NSManagedObject) {
        self.name = name
        self.instance = instance
    }

    private var set: NSMutableSet {
        self.instance.mutableSetValue(forKey: self.name)
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
}

public final class ManagedObjectOrderedSet<PlainObject: ManagedObjectConvertible>: Sequence {
    let name: String

    unowned let instance: NSManagedObject

    internal init(name: String, instance: NSManagedObject) {
        self.name = name
        self.instance = instance
    }

    private var set: NSMutableOrderedSet {
        self.instance.mutableOrderedSetValue(forKey: self.name)
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
