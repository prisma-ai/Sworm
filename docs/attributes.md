# Attributes

To declare a model property as an attribute, its type must implement [SupportedAttributeType](/Sources/Sworm/Attributes/Protocols.swift) protocol (similar to Transformable). This protocol defines how data will be transformed to / from one of the CoreData [primitives](/Sources/Sworm/Attributes/Primitives.swift).

Primitives also implement SupportedAttributeType, but no additional transformation occurs when they are read / write.

This system is very convenient, as it allows you to write the serialization / deserialization logic of your own data types once and significantly reduce the amount of code for data conversion.

For example, UIImage <-> Data:

``` swift
extension UIImage: SupportedAttributeType {
    public func encodePrimitiveValue() -> Data {
        self.jpegData(compressionQuality: 1) ?? Data()
    }

    public static func decode(primitiveValue: Data) throws -> Self {
        guard let value = Self(data: primitiveValue) else {
            throw AttributeError.badInput(primitiveValue)
        }
        return value
    }
}
```

``` swift
struct BookCover {
    var id: UUID = .init()
    var image: UIImage? = nil
}

extension BookCover: ManagedObjectConvertible {
    static let entityName: String = "BookCover"

    static let attributes: Set<Attribute<BookCover>> = [
        .init(\.id, "id"),
        .init(\.image, "image"),
    ]

    static let relations: Void = ()
}
```

As you may have noticed, the model uses optional UIImage. Optional properties can be attributes if their Wrapped type implements SupportedAttributeType.

Also, for convenience, Sworm has a built-in SupportedAttributeType [implementation](/Sources/Sworm/Attributes/RawRepresentable.swift) for RawRepresentable types, whose RawValue can be attributes. All you need to do is tag your type with a protocol:

``` swift
enum Foo: Int {
    case bar1
    case bar2
}

extension Foo: SupportedAttributeType {}
```
