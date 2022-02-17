import Foundation
import Sworm

extension CustomAttributeSet.CustomType: SupportedAttributeType {
    func encodePrimitiveValue() -> String {
        self.description
    }

    static func decode(primitiveValue: String) throws -> CustomAttributeSet.CustomType {
        guard let value = CustomAttributeSet.CustomType(primitiveValue) else {
            throw AttributeError.badInput(primitiveValue)
        }
        return value
    }
}

extension CustomAttributeSet.CustomEnumeration: SupportedAttributeType {}

extension PrimitiveAttributeFullSet: ManagedObjectConvertible {
    static let entityName: String = "PrimitiveAttributeFullSet"

    static let attributes: Set<Attribute<PrimitiveAttributeFullSet>> = [
        .init(\.x1, "x1"),
        .init(\.x2, "x2"),
        .init(\.x3, "x3"),
        .init(\.x4, "x4"),
        .init(\.x5, "x5"),
        .init(\.x6, "x6"),
        .init(\.x7, "x7"),
        .init(\.x8, "x8"),
        .init(\.x9, "x9"),
        .init(\.x10, "x10"),
        .init(\.x11, "x11"),
        .init(\.x12, "x12"),
        .init(\.x13, "x13"),
    ]

    static let relations: Void = ()
}

extension CustomAttributeSet: ManagedObjectConvertible {
    static let entityName: String = "CustomAttributeSet"

    static let attributes: Set<Attribute<CustomAttributeSet>> = [
        .init(\.x1, "x1"),
        .init(\.x2, "x2"),
        .init(\.x3, "x3"),
        .init(\.x4, "x4"),
        .init(\.x5, "x5"),
        .init(\.x6, "x6"),
    ]

    static let relations: Void = ()
}

extension DemoAttributeSetRef: ManagedObjectConvertible {
    static let entityName: String = "DemoAttributeSetRef"

    static let attributes: Set<Attribute<DemoAttributeSetRef>> = [
        .init(\.x1, "x1"),
        .init(\.x2, "x2"),
    ]

    static let relations: Void = ()
}

extension MigratableModels.A: ManagedObjectConvertible {
    static let entityName: String = "A"

    static let attributes: Set<Attribute<MigratableModels.A>> = [
        .init(\.id, "id"),
        .init(\.name, "name"),
    ]

    static let relations: Void = ()
}

extension MigratableModels.B: ManagedObjectConvertible {
    static let entityName: String = "B"

    static let attributes: Set<Attribute<MigratableModels.B>> = [
        .init(\.identifier, "identifier"),
        .init(\.text, "text"),
    ]

    static let relations: Void = ()
}

extension MigratableModels.C: ManagedObjectConvertible {
    static let entityName: String = "C"

    static let attributes: Set<Attribute<MigratableModels.C>> = [
        .init(\.foo, "foo"),
    ]

    static let relations: Void = ()
}

extension PredicateABCD.SomeEnum: SupportedAttributeType {}

extension PredicateABCD: ManagedObjectConvertible {
    static let entityName: String = "ABCD"

    static let attributes: Set<Attribute<PredicateABCD>> = [
        .init(\.a, "a"),
        .init(\.b, "b"),
        .init(\.c, "c"),
        .init(\.d, "d"),
    ]

    static let relations: Void = ()
}

extension PredicateIDURL: ManagedObjectConvertible {
    static let entityName: String = "IDURL"

    static let attributes: Set<Attribute<PredicateIDURL>> = [
        .init(\.id, "id"),
        .init(\.url, "url"),
    ]

    static let relations: Void = ()
}

extension BookLibrary.Author: ManagedObjectConvertible {
    static let entityName: String = "Author"

    static let attributes: Set<Attribute<BookLibrary.Author>> = [
        .init(\.id, "id"),
        .init(\.name, "name"),
        .init(\.age, "age"),
    ]

    struct Relations {
        let books = ToManyRelation<BookLibrary.Book>("books")
    }

    static let relations = Relations()
}

extension BookLibrary.Book.Review: ManagedObjectConvertible {
    static let entityName: String = "Review"

    static let attributes: Set<Attribute<BookLibrary.Book.Review>> = [
        .init(\.id, "id"),
        .init(\.text, "text"),
        .init(\.mark, "mark"),
    ]

    struct Relations {
        let book = ToOneRelation<BookLibrary.Book>("book")
    }

    static let relations = Relations()
}

extension BookLibrary.Book.Cover: ManagedObjectConvertible {
    static let entityName: String = "Cover"

    static let attributes: Set<Attribute<BookLibrary.Book.Cover>> = [
        .init(\.url, "url"),
    ]

    struct Relations {
        let book = ToOneRelation<BookLibrary.Book>("book")
    }

    static let relations = Relations()
}

extension BookLibrary.Book: ManagedObjectConvertible {
    static let entityName: String = "Book"

    static let attributes: Set<Attribute<BookLibrary.Book>> = [
        .init(\.id, "id"),
        .init(\.name, "name"),
        .init(\.year, "year"),
    ]

    struct Relations {
        let author = ToOneRelation<BookLibrary.Author>("author")
        let cover = ToOneRelation<BookLibrary.Book.Cover>("cover")
        let reviews = ToManyOrderedRelation<BookLibrary.Book.Review>("reviews")
    }

    static let relations = Relations()
}

extension Blob: ManagedObjectConvertible {
    static let entityName: String = "Blob"

    static let attributes: Set<Attribute<Blob>> = [
        .init(\.data, "data"),
    ]

    static let relations: Void = ()
}
