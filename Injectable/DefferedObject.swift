public class DeferredObject<T> {

    // MARK: - Properties

    public var object: T {
        if objectStorage == nil {
            objectStorage = acquire()
        }

        return objectStorage
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var objectStorage: T!

    private let acquire: () -> T

    // MARK: - Lifecycle

    public init(acquire: @escaping () -> T) {
        self.acquire = acquire
    }
}
