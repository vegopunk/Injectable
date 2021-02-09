@propertyWrapper
struct TestableInject<Type> {

    typealias ObjectType = Type

    let wrappedValue: ObjectType
    
    init<Object: InjectableMock>(_ type: Object.Type) where Object.ServiceType == ObjectType {
        self.wrappedValue = Object.initialize()
    }
    
}
