//
//  ViewController.swift
//  Injectable
//
//  Created by Денис Попов on 04.02.2021.
//

import UIKit

final class ViewController: UIViewController {
    
    @Inject(TestService.self) private var testService
    
    @Inject private var otherTestService: OtherTestService
    @Inject(OtherTestService.self) private var otherTestService2

    override func viewDidLoad() {
        super.viewDidLoad()
        testService.heheboi()
        otherTestService.heheboi()
        otherTestService2.heheboi()
    }
    
    
}

@propertyWrapper
struct Inject<Type> {

    typealias ServiceType = Type

    let wrappedValue: ServiceType

    init() where Type: Injectable {
        let wrappedValue = Assembly.shared.resolve(Type.ServiceType.self) as? Type
        if let wrappedValue = wrappedValue {
            self.wrappedValue = wrappedValue
        } else {
            Assembly.shared.register(lifetime: .singleton(lazy: true), initCall: Type.initialize)
            self.wrappedValue = Assembly.shared.resolve(Type.ServiceType.self) as! Type
        }
    }

    init<Service: Injectable>(_ type: Service.Type) where Service.ServiceType == ServiceType {
        let wrappedValue = Assembly.shared.resolve(ServiceType.self) as? Service
        if let wrappedValue = wrappedValue as? ServiceType {
            self.wrappedValue = wrappedValue
        } else {
            Assembly.shared.register(lifetime: .singleton(lazy: true), initCall: Service.initialize)
            self.wrappedValue = Assembly.shared.resolve()
        }
    }
}

protocol Injectable: AnyObject {
    associatedtype ServiceType
    static func initialize() -> ServiceType
}






protocol SecondTestServiceProtocol {
    func wtf()
}

protocol TestServiceProtocol {
    func heheboi()
}

final class OtherTestService: TestServiceProtocol, Injectable {
    
    static func initialize() -> TestServiceProtocol {
        OtherTestService()
    }
    
    
    typealias ServiceType = TestServiceProtocol
    
    func heheboi() {
        print("hehe boi from", OtherTestService.self)
    }
    
    func configure() {
        print("configure???", OtherTestService.self)
    }
}

final class TestService: TestServiceProtocol, Injectable {
    static func initialize() -> TestServiceProtocol {
        TestService()
    }
    
    
    typealias ServiceType = TestServiceProtocol
    
    func heheboi() {
        print("hehe boi from", TestService.self)
    }
    
}
