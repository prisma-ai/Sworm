import Foundation

@testable
import Sworm
import SwormTools
import XCTest

@available(OSX 10.15, *)
final class PredicateTests: XCTestCase {
    func testTypedAndUntypedQueryCombination() {
        let predicate: Predicate =
            (\PredicateABCD.a == 1 || \PredicateABCD.a == 2) &&
            (\PredicateABCD.b == 3 || \PredicateABCD.a == 4) &&
            !"foo.bar"

        XCTAssert(predicate.predicateDescriptor.query == "(((a == %@) OR (a == %@)) AND ((b == %@) OR (a == %@))) AND (NOT (foo.bar))")
    }

    func testEqualityAndComparability() {
        TestDB.perform(with: DataModels.predicates) { pc in
            let sourceEntries = [
                PredicateABCD(a: 10, b: 20),
                PredicateABCD(a: 30, b: 40),
                PredicateABCD(a: 50, b: 60),
                PredicateABCD(a: 70, b: 80),
                PredicateABCD(a: 90, b: 100),
            ]

            try pc.perform { ctx in
                try sourceEntries.forEach {
                    try ctx.insert($0)
                }
            }

            do {
                let query: Predicate = \PredicateABCD.a < 50 && \PredicateABCD.b > 20 || \PredicateABCD.b >= 100

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query).sort(\.a)).map { try $0.decode() }
                }

                XCTAssert(destinationEntites == [
                    PredicateABCD(a: 30, b: 40),
                    PredicateABCD(a: 90, b: 100),
                ])
            }

            do {
                let query: Predicate = (\PredicateABCD.a < 50 && \PredicateABCD.b > 20 || \PredicateABCD.b >= 100) && \PredicateABCD.b != 40

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query).sort(\.a)).map { try $0.decode() }
                }

                XCTAssert(destinationEntites == [
                    PredicateABCD(a: 90, b: 100),
                ])
            }
        }
    }

    func testNilComparison() {
        TestDB.perform(with: DataModels.predicates) { pc in
            let sourceEntries = [
                PredicateABCD(a: 10, b: 20, c: nil),
                PredicateABCD(a: 30, b: 40, c: "foo"),
                PredicateABCD(a: 50, b: 60, c: nil),
                PredicateABCD(a: 70, b: 80, c: "bar"),
            ]

            try pc.perform { ctx in
                try sourceEntries.forEach {
                    try ctx.insert($0)
                }
            }

            do {
                let query: Predicate = \PredicateABCD.c != nil && \PredicateABCD.a > 30

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query).sort(\.a)).map { try $0.decode() }
                }

                XCTAssert(destinationEntites == [
                    PredicateABCD(a: 70, b: 80, c: "bar"),
                ])
            }

            do {
                let query: Predicate = \PredicateABCD.c == nil && \PredicateABCD.a < 50

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query).sort(\.a)).map { try $0.decode() }
                }

                XCTAssert(destinationEntites == [
                    PredicateABCD(a: 10, b: 20, c: nil),
                ])
            }
        }
    }

    func testNonPrimitiveAttributeQuery() {
        TestDB.perform(with: DataModels.predicates) { pc in
            let sourceEntries = [
                PredicateABCD(a: 1, d: .foo),
                PredicateABCD(a: 2, d: .bar),
                PredicateABCD(a: 3, d: .bar),
                PredicateABCD(a: 4, d: nil),
            ]

            try pc.perform { ctx in
                try sourceEntries.forEach {
                    try ctx.insert($0)
                }
            }

            do {
                let query: Predicate = \PredicateABCD.d == .bar

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query).sort(\.a)).map { try $0.decode() }
                }

                XCTAssert(destinationEntites == [
                    PredicateABCD(a: 2, d: .bar),
                    PredicateABCD(a: 3, d: .bar),
                ])
            }

            do {
                let query: Predicate = \PredicateABCD.d != .bar || \PredicateABCD.d == nil

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query).sort(\.a)).map { try $0.decode() }
                }

                XCTAssert(destinationEntites == [
                    PredicateABCD(a: 1, d: .foo),
                    PredicateABCD(a: 4, d: nil),
                ])
            }
        }
    }

    func testUUIDAndURLQuery() {
        TestDB.perform(with: DataModels.predicates) { pc in
            let ids: [UUID] = [.init(), .init(), .init()]
            let urls: [URL?] = [
                URL(string: "https://xyz.com"),
                URL(string: "https://qwe.com"),
                URL(string: "https://fgh.com"),
            ]

            XCTAssert(ids.count == urls.count)

            try pc.perform { ctx in
                try zip(ids, urls).forEach {
                    try ctx.insert(PredicateIDURL(id: $0.0, url: $0.1))
                }
            }

            do {
                let query: Predicate = \PredicateIDURL.url == urls[0]

                let destinationEntity = try pc.perform { ctx in
                    try? ctx.fetchOne(PredicateIDURL.all.where(query))?.decode()
                }

                XCTAssert(destinationEntity?.id == ids[0])
            }

            do {
                let query: Predicate = \PredicateIDURL.id == ids[0]

                let destinationEntity = try pc.perform { ctx in
                    try? ctx.fetchOne(PredicateIDURL.all.where(query))?.decode()
                }

                XCTAssert(destinationEntity?.url == urls[0])
            }
        }
    }

    func testInLittle() {
        TestDB.perform(with: DataModels.predicates) { pc in
            let sourceEntries = [
                PredicateABCD(a: 1, c: "a"),
                PredicateABCD(a: 2, c: "b"),
                PredicateABCD(a: 3, c: "c"),
                PredicateABCD(a: 4, c: "d"),
            ]

            try pc.perform { ctx in
                try sourceEntries.forEach {
                    try ctx.insert($0)
                }
            }

            do {
                let query: Predicate = \PredicateABCD.c === ["a", "d"]

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query).sort(\.a)).map { try $0.decode() }
                }

                XCTAssert(destinationEntites == [
                    PredicateABCD(a: 1, c: "a"),
                    PredicateABCD(a: 4, c: "d"),
                ])
            }

            do {
                let query: Predicate = \PredicateABCD.c === ["a", "d"] || \PredicateABCD.a === [1, 2]

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query).sort(\.a)).map { try $0.decode() }
                }

                XCTAssert(destinationEntites == [
                    PredicateABCD(a: 1, c: "a"),
                    PredicateABCD(a: 2, c: "b"),
                    PredicateABCD(a: 4, c: "d"),
                ])
            }
        }
    }

    func testInBig() {
        let N = 200

        TestDB.perform(with: DataModels.predicates) { pc in
            let sourceEntries = (0 ..< N).map { _ in
                PredicateIDURL(id: .init())
            }

            let ids = Array(sourceEntries.prefix(N / 2).map(\.id))

            try pc.perform { ctx in
                try sourceEntries.forEach {
                    try ctx.insert($0)
                }
            }

            do {
                let query: Predicate = \PredicateIDURL.id === ids

                let destinationEntityIDs = try pc.perform { ctx in
                    try ctx.fetch(PredicateIDURL.all.where(query), \.id)
                }

                XCTAssert(Set(destinationEntityIDs) == Set(ids))
            }
        }
    }

    func testStringComparability() {
        TestDB.perform(with: DataModels.predicates) { pc in
            let sourceEntries = [
                PredicateABCD(c: "fOo1baR"),
                PredicateABCD(c: "foO2bAr"),
                PredicateABCD(c: "BaR1Foo"),
                PredicateABCD(c: "Bar2fOO"),
            ]

            try pc.perform { ctx in
                try sourceEntries.forEach {
                    try ctx.insert($0)
                }
            }

            do {
                let query: Predicate = Query.beginsWith(\PredicateABCD.c, "foo")

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query)).map { try $0.decode(\.c) }
                }

                XCTAssert(Set(destinationEntites) == [
                    "fOo1baR",
                    "foO2bAr",
                ])
            }

            do {
                let query: Predicate = Query.endsWith(\PredicateABCD.c, "foo")

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query)).map { try $0.decode(\.c) }
                }

                XCTAssert(Set(destinationEntites) == [
                    "BaR1Foo",
                    "Bar2fOO",
                ])
            }

            do {
                let query: Predicate = Query.contains(\PredicateABCD.c, "1")

                let destinationEntites = try pc.perform { ctx in
                    try ctx.fetch(PredicateABCD.all.where(query)).map { try $0.decode(\.c) }
                }

                XCTAssert(Set(destinationEntites) == [
                    "fOo1baR",
                    "BaR1Foo",
                ])
            }
        }
    }
}
