public enum AttributeError: Swift.Error, @unchecked Sendable {
    case badInput(Any?)
    case badAttribute(Context)

    public struct Context {
        public let name: String
        public let entity: String
        public let originalError: Swift.Error
    }
}
