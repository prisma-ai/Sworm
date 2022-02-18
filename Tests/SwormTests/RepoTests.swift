import Foundation
import Sworm
import SwormTools
import XCTest

@available(OSX 10.15, *)
final class RepoTests: XCTestCase {
    func testRepo() {
        TestDB.perform(with: DataModels.repo) { pc in
            let repo = Repo<RepoEntity>(pc: pc)

            XCTAssert((try repo.fetchAll()).isEmpty)

            // insert

            var entity = RepoEntity(id: .init(), text: "foo")

            try repo.insert(item: entity)

            XCTAssert((try repo.fetchAll()) == [entity])

            // update

            entity.text = "bar"

            try repo.update(item: entity)

            XCTAssert((try repo.fetchAll()) == [entity])

            // delete

            try repo.delete(item: entity)

            XCTAssert((try repo.fetchAll()).isEmpty)
        }
    }
}
