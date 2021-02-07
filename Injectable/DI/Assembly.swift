import Foundation

private let targetName = (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? ""

@objc open class Assembly: NSObject {
    
    static let shared = Assembly()
    
    // MARK: - Properties
    
    private final var overrides: [ScopeOverride] = []
    private final var singletons: [String: Any] = [:]
    private final var graphObjects: [String: AnyObject] = [:]
    private final var graphs: [String] = []
    private final var graphStackDepth = 0
    private final var objectsInitCalls: [String: () -> Any] = [:]
    private final var objectsInjectCalls: [String: (Any) -> Void] = [:]
    
    // MARK: - Public
    
    public final func register<ComponentType>(lifetime: Lifetime = .singleton(lazy: true),
                                              initCall: @escaping () -> ComponentType,
                                              injectCall: ((ComponentType) -> Void)? = nil) {
        let typeName = String(describing: type(of: ComponentType.self))
        let key = normalizedKey(from: typeName)
        
        switch lifetime {
        case .prototype:
            objectsInitCalls[key] = initCall
            objectsInjectCalls[key] = { injectCall?($0 as! ComponentType) }
        case .objectGraph:
            graphs.append(key)
            objectsInitCalls[key] = initCall
            objectsInjectCalls[key] = { injectCall?($0 as! ComponentType) }
        case .singleton(lazy: true):
            singletons[key] = InitCallBox(call: initCall)
            objectsInjectCalls[key] = { injectCall?($0 as! ComponentType) }
        case .singleton(lazy: false):
            let object = initCall()
            singletons[key] = object
            injectCall?(object)
        }
    }
    
    public final func unregister<ComponentType>(type: ComponentType.Type) {
        let typeName = String(describing: Swift.type(of: ComponentType.self))
        let key = normalizedKey(from: typeName)

        if let index = graphs.firstIndex(of: key) {
            graphs.remove(at: index)
        }
        singletons[key] = nil
        objectsInitCalls[key] = nil
        objectsInjectCalls[key] = nil
    }
    
    public final func scopeWith<T>(overrides: [ScopeOverride], scope: () -> T) -> T {
        self.overrides += overrides
        let result = scope()
        self.overrides = self.overrides.filter { value in
            overrides.contains(where: { $0 !== value })
        }
        return result
    }
    
    public final func resolve<ComponentType>() -> ComponentType {
        let typeName = String(describing: Swift.type(of: ComponentType.self))
        let key = normalizedKey(from: typeName)

        return resolve(withKey: key) as! ComponentType
    }

    @objc public func resolve(_ type: Any) -> Any? {
        var typeName = String(describing: Swift.type(of: type.self))
        if let type = type.self as? Protocol {
            typeName = NSStringFromProtocol(type)
        }

        return resolve(withKey: normalizedKey(from: typeName))
    }

    /// Резолвит зависимости уже существущего инстанса
    @objc public func resolve(instance: Any) {
        let typeName = String(describing: type(of: instance))
        let key = normalizedKey(from: typeName)

        guard let injectCall = objectsInjectCalls[key] else {
            print("⚠️ Cannot find inject closure for \(key) in \(String(describing: type(of: self)))")
            return
        }

        injectCall(instance)
    }
    
    // MARK: - Private
    
    private func resolve(withKey key: String) -> Any? {
        defer {
            if graphStackDepth == 0 {
                graphObjects.removeAll()
            }
        }

        for override in overrides.reversed() {
            if key == normalizedKey(from: String(describing: type(of: override.type.self))) {
                return override.factory()
            }
        }

        if let result = singletons[key] as? InitCallBox {
            let object = result.call()
            singletons[key] = object
            graphStackDepth += 1
            objectsInjectCalls[key]?(object)
            graphStackDepth -= 1
            return object
        }

        if let result = singletons[key] {
            return result
        }

        var graphObject = false
        if graphs.contains(key) {
            graphObject = true
            if let res = graphObjects[key] {
                return res
            }
        }

        guard let result = objectsInitCalls[key]?() else {
//            preconditionFailure("Cannot resolve init call for \(key)")
            return nil
        }

        if graphObject {
            graphObjects[key] = result as AnyObject
        }

        graphStackDepth += 1
        objectsInjectCalls[key]?(result)
        graphStackDepth -= 1

        return result
    }
    
    private func normalizedKey(from typeName: String) -> String {
        let key = typeName
            .replacingOccurrences(of: targetName + ".", with: "")
            .replacingOccurrences(of: ".Type", with: "")
            .replacingOccurrences(of: ".Protocol", with: "")
            .replacingOccurrences(of: "Optional<", with: "")
            .replacingOccurrences(of: ">", with: "")
        return key
    }
    
}

// MARK: - Nested types
extension Assembly {
    public enum Lifetime {
        case prototype
        case objectGraph
        case singleton(lazy: Bool)
    }
    
    public class ScopeOverride {
        let type: Any
        let factory: () -> Any
        
        public init(type: Any, factory: @escaping () -> Any) {
            self.type = type
            self.factory = factory
        }
    }
    
    public class InitCallBox {
        let call: () -> Any
        
        init(call: @escaping () -> Any) {
            self.call = call
        }
    }
}
