public enum AttributeError: Swift.Error {
    case badInput(Any?)
    case badAttribute(Context)

    // MARK: Public

    public struct Context {
        public let name: String
        public let entity: String
        public let originalError: Swift.Error
    }
}
