import Foundation
import Sworm
import SwormTools
import XCTest

@available(OSX 10.15, *)
final class ReadWriteTests: XCTestCase {
    func testCRUD() {
        TestDB.temporaryContainer(store: DataModels.bookLibrary) { pc in
            let Author = BookLibrary.Author(
                name: "cool author",
                age: 50
            )

            let Book = BookLibrary.Book(
                name: "cool book 1",
                year: 2010
            )

            let Review1 = BookLibrary.Book.Review(
                text: "wow",
                mark: 9
            )

            let Review2 = BookLibrary.Book.Review(
                text: "so much wow",
                mark: 10
            )

            let Cover = BookLibrary.Book.Cover(
                url: URL(string: "https://fantlab.ru/work2699")
            )

            // insert objects

            try pc.perform { ctx in
                let authorObject = try ctx.insert(Author)
                let bookObject = try ctx.insert(Book)
                let review1Object = try ctx.insert(Review1)
                let review2Object = try ctx.insert(Review2)
                let coverObject = try ctx.insert(Cover)

                bookObject.reviews.add(review1Object)
                bookObject.reviews.add(review2Object)
                bookObject.cover = coverObject
                authorObject.books.add(bookObject)
            }

            // read and check

            try pc.perform { ctx in
                guard let author = try ctx.fetchOne(BookLibrary.Author.all) else {
                    XCTFail("wtf, no author")

                    return
                }

                XCTAssert((try author.decode()) == Author)

                let books = Array(author.books)

                XCTAssert(books.count == 1)

                let book = books[0]

                XCTAssert((try book.decode()) == Book)
                XCTAssert((try book.author?.decode()) == Author)
                XCTAssert((try book.cover?.decode()) == Cover)
                XCTAssert((try book.cover?.book?.decode()) == Book)

                let reviews = Array(book.reviews)

                XCTAssert(reviews.count == 2)

                let review1 = reviews[0]
                let review2 = reviews[1]

                XCTAssert((try review1.decode()) == Review1)
                XCTAssert((try review1.book?.decode()) == Book)
                XCTAssert((try review2.decode()) == Review2)
                XCTAssert((try review2.book?.decode()) == Book)
            }

            // update

            let Review3 = BookLibrary.Book.Review(
                text: "trash!",
                mark: 1
            )

            try pc.perform { ctx in
                guard let author = try ctx.fetchOne(BookLibrary.Author.all),
                      let book = Array(author.books).first
                else {
                    return
                }

                book.author = nil
                book.cover = nil
                book.reviews.forEach {
                    book.reviews.remove($0)
                    ctx.delete($0)
                }

                try book.reviews.add(ctx.insert(Review3))
            }

            // read and check

            try pc.perform { ctx in
                do {
                    guard let author = try ctx.fetchOne(BookLibrary.Author.all) else {
                        XCTFail("wtf, no author")

                        return
                    }

                    XCTAssert((try author.decode()) == Author)

                    let books = Array(author.books)

                    XCTAssert(books.isEmpty)
                }

                do {
                    guard let book = try ctx.fetchOne(BookLibrary.Book.all) else {
                        XCTFail("wtf, no book")

                        return
                    }

                    XCTAssert((try book.decode()) == Book)

                    XCTAssert(book.author == nil)
                    XCTAssert(book.cover == nil)

                    let reviews = Array(book.reviews)

                    XCTAssert(reviews.count == 1)
                    XCTAssert((try reviews[0].decode()) == Review3)
                    XCTAssert((try reviews[0].book?.decode()) == Book)
                }
            }
        }
    }

    func testRequestSortLimit() {
        TestDB.temporaryContainer(store: DataModels.bookLibrary) { pc in
            try pc.perform(action: { context in
                try (1 ... 10).reversed().forEach {
                    try context.insert(
                        BookLibrary.Book(
                            name: "\($0)",
                            year: $0 % 2 == 0 ? 2010 : 2020
                        )
                    )
                }
            })

            let bookNames: [String] = try pc.perform { ctx in
                let query = BookLibrary.Book
                    .all
                    .sort(\.year)
                    .sort(\.name)
                    .limit(8)
                    .offset(1)

                return try ctx.fetch(query, \.name)
            }

            XCTAssert(bookNames == ["2", "4", "6", "8", "1", "3", "5", "7"])
        }
    }

    func testNotUniqueInsertFail() {
        TestDB.temporaryContainer(store: DataModels.bookLibrary) { pc in
            let id = UUID()

            var err: Error?

            do {
                try pc.perform { ctx in
                    try ctx.insert(BookLibrary.Book(id: id))
                    try ctx.insert(BookLibrary.Book(id: id))
                }
            } catch {
                err = error
            }

            XCTAssert(err != nil)
        }
    }

    func testMultiThreadReadWrite() {
        TestDB.temporaryContainer(store: DataModels.bookLibrary) { pc in
            DispatchQueue.concurrentPerform(iterations: 100) { number in
                do {
                    try pc.perform { ctx in
                        try ctx.insert(BookLibrary.Book(year: number))
                    }
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }

            let bookNames = try pc.perform { ctx in
                try ctx.fetch(BookLibrary.Book.all.sort(\.year), \.year)
            }

            XCTAssert(bookNames == Array(0 ..< 100))
        }
    }

    func testMultiThreadReadWriteRelationsStability() {
        TestDB.temporaryContainer(store: DataModels.bookLibrary, overwriteMergePolicy: true) { pc in
            try pc.perform { ctx in
                try ctx.insert(BookLibrary.Author(id: .init(), name: "Leo", age: 100))
            }

            DispatchQueue.concurrentPerform(iterations: 100) { _ in
                do {
                    try pc.perform { ctx in
                        if let author = try ctx.fetchOne(BookLibrary.Author.all) {
                            if Bool.random() {
                                try author.books.add(ctx.insert(BookLibrary.Book()))
                            } else {
                                author.books.forEach {
                                    author.books.delete($0, context: ctx)
                                }
                            }
                        }
                    }
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }
    }
}
