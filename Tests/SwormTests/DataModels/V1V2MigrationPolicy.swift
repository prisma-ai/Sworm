import CoreData
import Foundation

@objc(V1V2MigrationPolicy)
final class V1V2MigrationPolicy: NSEntityMigrationPolicy {
    @objc
    func multiplyByTen(_ value: NSNumber) -> NSNumber {
        NSNumber(value: value.doubleValue * 10)
    }
}
