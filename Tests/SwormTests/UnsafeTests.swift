import Foundation

@testable
import Sworm
import XCTest

// do not pass references to context-produced objects like
// managed object/sets/iterators, etc. to external scope
// outside "perform" closure
// it's unsafe and may leads to app crash or runtime undefined behavior

@available(OSX 10.15, *)
// Remove low dash to test
final class UnsafeTests: XCTestCase {
    func _testDeallocatedReferenceAccess1() {
        TestDB.perform(with: DataModels.bookLibrary) { pc in
            let book = BookLibrary.Book(name: "some book")

            try pc.perform(action: { ctx in
                try ctx.insert(book)
            })

            let managedObject = try pc.perform(action: { ctx in
                try ctx.fetchOne(BookLibrary.Book.all)
            })

            _ = try? managedObject?.decode()
        }
    }

    func _testDeallocatedReferenceAccess2() {
        TestDB.perform(with: DataModels.bookLibrary) { pc in
            try pc.perform(action: { ctx in
                let authorObject = try ctx.insert(BookLibrary.Author())
                authorObject.books.add(try ctx.insert(BookLibrary.Book()))
            })

            let managedObjects = try pc.perform(action: { ctx in
                try ctx.fetchOne(BookLibrary.Author.all)?.books
            })

            managedObjects?.forEach {
                print($0)
            }
        }
    }

    func _testDeallocatedReferenceAccess3() {
        TestDB.perform(with: DataModels.bookLibrary) { pc in
            var managedObjects: ManagedObjectSet<BookLibrary.Book>?

            try pc.perform(action: { ctx in
                let authorObject = try ctx.insert(BookLibrary.Author())
                authorObject.books.add(try ctx.insert(BookLibrary.Book()))
                managedObjects = authorObject.books
            })

            managedObjects?.forEach {
                print($0)
            }
        }
    }

    func _testIterator() {
        TestDB.perform(with: DataModels.bookLibrary) { pc in
            try pc.perform(action: { ctx in
                let authorObject = try ctx.insert(BookLibrary.Author())
                authorObject.books.add(try ctx.insert(BookLibrary.Book()))
            })

            do {
                let iterator = try pc.perform(action: { ctx in
                    try ctx.fetchOne(BookLibrary.Author.all)!.books.makeIterator()
                })

                XCTAssert(Array(AnySequence { iterator }).isEmpty)
            }

            do {
                let iterator: ManagedObjectSetIterator<BookLibrary.Book> = try pc.perform(action: { ctx in
                    let author = try ctx.fetchOne(BookLibrary.Author.all)!
                    author.books.forEach { _ in }
                    return author.books.makeIterator()
                })

                XCTAssert(!Array(AnySequence { iterator }).isEmpty)
            }
        }
    }
}
