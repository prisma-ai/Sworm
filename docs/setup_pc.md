# Proper setup of PersistentContainer

[PersistentContainer](/Sources/Sworm/Wrappers/PersistentContainer.swift) is your entry point for data interaction. And what and where will happen with the data will depend on its settings.

The initializer of this object takes 3 parameters as input. Let's take a look at each of them in turn.

## 1) managedObjectContext

The first and most important parameter is the closure, which returns the context for working with the data. You may be asking why not just create an NSPersistentContainer instance and pass it inside a PersistentContainer, similar to NSManagedObjectContext <-> [ManagedObjectContext](/Sources/Sworm/Wrappers/ManagedObjectContext.swift)?

The answer is simple - closure is much more flexible:

``` swift
let nspc = NSPersistentContainer(...)

let pc = PersistentContainer(managedObjectContext: nspc.newBackgroundContext)

...

let pc = PersistentContainer(managedObjectContext: {
    Thread.isMainThread ? nspc.viewContext : nspc.newBackgroundContext()
})
```

Also note that the closure is throwable. This makes it possible to safely create and use a PersistentContainer instance without being tied to the initialization and activation process of the object that creates the NSManagedObjectContext instances.

For example, the NSPersistentContainer, in addition to initializing the object, also requires calling `loadPersistentStores`:

``` swift
var isReady: Bool = false

...

let nspc = NSPersistentContainer(...)

let pc = PersistentContainer(managedObjectContext: {
    if !isReady {
        throw ...
    }

    return Thread.isMainThread ? nspc.viewContext : nspc.newBackgroundContext()
})

...

nspc.loadPersistentStores(completionHandler: { _, _ in })

isReady = true
```

## 2) logError

This is a closure that allows you to catch and log any errors that occur when working with data:

``` swift
PersistentContainer(
    managedObjectContext: ...,
    logError: { error in
        print(error)
    }
)
```

## 3) cleanUpAfterExecution

The most interesting parameter that allows you to balance between RAM and Disk I/O. As you probably know, NSManagedObjectContext, among other functionality, is a cache of managed objects. And with intensive data operations, this cache can grow significantly. To clear the context, it has a `reset` method, the documentation for which says that for guaranteed cleaning of objects, they should not have external strong references. In normal use of CoreData, this requirement is difficult to fulfill, but Sworm doesn't store strong references to managed objects, so the reset call is guaranteed to clear the memory of objects. `cleanUpAfterExecution` is responsible for whether to call `reset` after all data operations have been performed or not.

By default, this parameter is set to true, which means:

``` swift
try pc.perform { ctx in
    // that the "ctx" will be cleared after the execution of this closure has finished
}
```

Whether to use this parameter is up to you. Disk I/O is no longer a very expensive operation and sometimes the extra megabytes of RAM are much more valuable.
