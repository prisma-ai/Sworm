# Read and write your data graph

The point of interaction with the data graph in Sworm is the PersistentContainer instance:

`let pc = PersistentContainer(...)`

further, all you need to do is call the `pc`'s method:

``` swift
try pc.perform { ctx in
    // read write your data here
}
```

or it's concurrent counterpart:

``` swift
try await pc.schedule { ctx in
    // read write your data here
}
```

`ctx` is the [ManagedObjectContext](/Sources/Sworm/Wrappers/ManagedObjectContext.swift) instance through which you read and write data:

``` swift
ctx.insert(...)
ctx.fetch(...)
ctx.delete(...)
```

You might think these methods work with your domain models. This is true, but not directly. In fact, interaction with data occurs using proxy objects [ManagedObject](/Sources/Sworm/Wrappers/ManagedObject.swift) and [ManagedObjectSet](/Sources/Sworm/Wrappers/ManagedObjectSet.swift), where T is the type of the domain model. Why is this needed? [ManagedObjectConvertible](/Sources/Sworm/ManagedObjectConvertible.swift) models define the structure of a graph, and proxy objects provide an API for working with the graph using information about that structure.

Let's take a look at how it works:

``` swift
extension Author: ManagedObjectConvertible {
    ...

    struct Relations {
        let books = ToManyRelation<Book>("books")
    }

    static let relations = Relations()
}

extension Book: ManagedObjectConvertible { ... }

...

let author = Author(name: "author")
let book1 = Book(name: "book 1")
let book2 = Book(name: "book 2")

try pc.perform { ctx in
    // types can be omitted - it's only for example

    // insert author -> get an object for data access
    let authorObject: ManagedObject<Author> = try ctx.insert(author)
    // get books collection from the author's object
    let bookObjects: ManagedObjectSet<Book> = authorObject.books

    // add new book objects to this list
    try bookObjects.add(ctx.insert(book1))
    try bookObjects.add(ctx.insert(book2))
}
```

ManagedObject has a set of paired `encode` / `decode` methods that allow you to read / write data models or attributes separately:

``` swift
try pc.perform { ctx in
    // fetch ManagedObject<Author>
    guard let authorObject = try ctx.fetchOne(Author.all) else {
        return
    }

    // get your pure swift entity
    let author = try authorObject.decode()
    // or single attribute
    let authorName = try authorObject.decode(\.name)

    // update its value
    authorObject.encode(Author(name: "foo", age: 50))
    // or update name only
    authorObject.encode(\.name, "foo")
}
```
