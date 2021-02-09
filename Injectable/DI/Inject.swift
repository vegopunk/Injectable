@propertyWrapper
struct Inject<Type> {

    typealias ObjectType = Type

    let wrappedValue: ObjectType
    
    init<Object: InjectableSingleton>(_ type: Object.Type) where Object.ServiceType == ObjectType {
        if let service = Assembly.shared.resolve(ObjectType.self) as? Object,
           let wrappedValue = service as? ObjectType {
            self.wrappedValue = wrappedValue
        } else {
            Assembly.shared.register(lifetime: .singleton(lazy: true), initCall: Object.initialize)
            self.wrappedValue = Assembly.shared.resolve()
        }
    }
    
    init<Object: InjectablePrototype>(_ type: Object.Type) where Object.ServiceType == ObjectType {
        self.wrappedValue = Object.initialize()
    }
    
}
