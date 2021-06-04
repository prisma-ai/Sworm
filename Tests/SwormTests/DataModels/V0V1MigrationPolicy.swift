import CoreData
import Foundation

@objc(V0V1MigrationPolicy)
final class V0V1MigrationPolicy: NSEntityMigrationPolicy {
    @objc
    func changeID(_ value: NSNumber) -> NSNumber {
        NSNumber(value: value.doubleValue)
    }
}
