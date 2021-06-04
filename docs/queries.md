# Queries

Sworm provides a very simple API for safe data queries.

A complete query looks like this:

``` swift
<T: ManagedObjectConvertible>
    .all
    .where(<predicate>)
    .sort(<property>, ascending: <true|false>)
    .limit(<integer value>)
    .offset(<integer value>)
```

You can use any combination of `where` `sort` `limit` `offset`.

We will not focus on limit/offset, so let's go straight to sorting and predicates.

## Predicates

The most important part of any query is the search predicate. To generate it, you need to write a strongly typed expression like the following:

`\T.count == 10 || \T.date > Date() && !(\T.id === [1, 2, 3])`

*Note*: The `===` operator is an "IN" operation.

This form of notation is very intuitive and fully corresponds to the logic that is usually used in classical conditional expressions: comparison operators (==,! =,>, <,> =, <=), logical operators (!, &&, ||) and so on.

Comparison operations are applicable to those attributes whose target primitives support these operations, i.e. are Equatable and / or Comparable.

Each of the operators calls the corresponding method (eg `>` <-> `greaterThan`) of the [Query](/Sources/Sworm/Requests/Query.swift) entity.

In addition to operator-method pairs, `Query` contains methods for text queries (`beginsWith`, `endsWith`, and `contains`) for which there are no built-in operators. And they need to be used directly:

`\T.count == 10 || Query.endsWith(\T.name, "foo")`

You may have noticed that everywhere attribute keypaths are specified in their full form (with a type) and you cannot omit the type. This was done to help the compiler quickly parse predicate expressions - tradeoff between speed of compilation and verbosity.

Queries in the CoreData are, of course, more complex - for example, aggregate functions of relations (@count), specifying indices (indexed:by:), etc. But in Sworm, type system usage is limited to attributes only. To prevent this limitation from becoming a problem, Sworm allows you to combine raw strings and swift expressions:

`\T.id == 4 && !"foo.bars.@count > 0"`

Since such queries are used much less often than exclusively attribute queries, this should not be a big problem.

## Sorting

For sorting by attribute to be possible, the target primitive of the attribute must be Comparable. And that's all you need to know about sorting in Sworm.

## Example

At the end i will give an example to make the picture very clear:

``` swift
let query = T
            .all
            .where(\T.marker === ["a", "d"] || \T.amount > 10 || Query.endsWith(\T.name, "ex"))
            .sort(\.name)
            .limit(5)

let result = try db.perform { ctx in
    try ctx.fetch(query).map { try $0.decode() }
}
```
