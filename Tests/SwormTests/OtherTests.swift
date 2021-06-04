import Foundation

@testable
import Sworm
import SwormTools
import XCTest

@available(OSX 10.15, *)
final class OtherTests: XCTestCase {
    func testIsNotReady() {
        struct NotReadyError: Swift.Error {}

        let pc = PersistentContainer(
            managedObjectContext: {
                throw NotReadyError()
            },
            logError: { error in
                XCTAssert(error is NotReadyError)
            }
        )

        do {
            try pc.perform { ctx in
                try ctx.insert(BookLibrary.Book())
            }
        } catch {
            XCTAssert(error is NotReadyError)
        }
    }
}
