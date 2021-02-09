import UIKit

final class ViewController: UIViewController {
    
    @Inject(SomeService.self) var someService
    @Inject(YBMAppDelegateDeeplinks.self) var YBMAppDelegateDeeplinksPr
    
    
    @Inject(YMTAppRouter.self) var appRouter
    @Inject(YMTRoutes.self) var routes
    @Inject(DeeplinkProccessorTracker.self) var deeplinkTracker
    
    @Inject(SKURouter.self) var skuRouter
    
    @Inject(SomeObject.self) var someObject
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("----------------")
        print("appRouter uuid =", appRouter.uuid,
              "| deeplinkTracker uuid =", appRouter.deeplinkTracker.uuid,
              "| appRouter uuid =", appRouter.routes.uuid
        )
        print("----------------")
        print("routes uuid =", routes.uuid,
              "| deeplinkTracker uuid =", routes.deeplinkTracker.uuid
        )
        print("----------------")
        print("deeplinkTracker uuid =", deeplinkTracker.uuid)
        print("----------------")
        
        
        
        
        skuRouter.view = self
        print("Другой пример")
        print("skuRouter uuid =", skuRouter.uuid,
              "| skuRouter.view =", skuRouter.view ?? "empty view"
        )
        print("----------------")
        
        
        
        
        print("Другой пример")
        print("some object =", someObject)
        print("----------------")
    }
}


// Пример с любым контроллером и роутером

final class SKURouter: InjectablePrototype {
    
    typealias ServiceType = SKURouter
    static func initialize() -> SKURouter {
        SKURouter()
    }
    weak var view: ViewController?
    
    let uuid = UUID().uuidString
}

protocol  YBMAppDelegateDeeplinksPr {
    func configure()
}

final class SomeService: YBMAppDelegateDeeplinksPr, InjectableSingleton {
    func configure() {
        
    }
    
    typealias ServiceType = YBMAppDelegateDeeplinksPr
    static func initialize() -> YBMAppDelegateDeeplinksPr {
        SomeService()
    }
}

// was objectGraph
final class YBMAppDelegateDeeplinks: YBMAppDelegateDeeplinksPr, InjectablePrototype {
    typealias ServiceType = YBMAppDelegateDeeplinksPr
    static func initialize() -> YBMAppDelegateDeeplinksPr {
        YBMAppDelegateDeeplinks()
    }
    @Inject(YMTAppRouter.self) var appRouter
    
    let uuid = UUID().uuidString
    
    func configure() {
        print("configure")
    }
}

// was singleton
final class YMTAppRouter: InjectableSingleton {
    typealias ServiceType = YMTAppRouter
    static func initialize() -> YMTAppRouter {
        YMTAppRouter()
    }
    @Inject(DeeplinkProccessorTracker.self) var deeplinkTracker
    @Inject(YMTRoutes.self) var routes: YMTRoutes
    
    let uuid = UUID().uuidString
}

// was objectGraph
final class YMTRoutes: InjectableSingleton {
    typealias ServiceType = YMTRoutes
    static func initialize() -> YMTRoutes {
        YMTRoutes()
    }
    @Inject(DeeplinkProccessorTracker.self) var deeplinkTracker
    
    let uuid = UUID().uuidString
}


// was singleton
final class DeeplinkProccessorTracker: InjectableSingleton {
    typealias ServiceType = DeeplinkProccessorTracker
    static func initialize() -> DeeplinkProccessorTracker {
        DeeplinkProccessorTracker()
    }
    
    let uuid = UUID().uuidString
}





// custom type

final class SomeObject: InjectablePrototype {
    static func initialize() -> DeferredObject<SomeObject> {
        .init {
            SomeObject()
        }
    }
    
    typealias ServiceType = DeferredObject<SomeObject>
    
}



