protocol InjectableSingleton {
    associatedtype ServiceType
    static func initialize() -> ServiceType
}
protocol InjectablePrototype {
    associatedtype ServiceType
    static func initialize() -> ServiceType
}

protocol InjectableMock {
    associatedtype ServiceType
    static func initialize() -> ServiceType
}
