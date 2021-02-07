import UIKit

extension Assembly {
    fileprivate class Holder: NSObject {
        static var shared = Holder()
        
        var injections: [String: (Any) -> Void] = [:]
        
        override init() {
            super.init()
            swizzleInstantiateViewFromXib()
            swizzleInstantiateViewControllerFromXib()
            swizzleInstantiateViewControllerFromStoryboard()
        }
        
        private func swizzleInstantiateViewFromXib() {
            let originalSelector = #selector(UIView.init(coder:))
            let swizzledSelector = #selector(UIView.swizzledInstantiateView(coder:))
            
            guard let originalMethod = class_getInstanceMethod(UIView.self, originalSelector) else {
                return
            }
            guard let swizzledMethod = class_getInstanceMethod(UIView.self, swizzledSelector) else {
                return
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        private func swizzleInstantiateViewControllerFromXib() {
            let originalSelector = #selector(UIViewController.init(nibName:bundle:))
            let swizzledSelector = #selector(
                UIViewController.swizzledInstantiateViewControllerWithNibName(nibName:bundle:)
            )

            guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector) else {
                return
            }
            guard let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
                return
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }

        private func swizzleInstantiateViewControllerFromStoryboard() {
            let originalSelector = #selector(UIViewController.init(coder:))
            let swizzledSelector = #selector(UIViewController.swizzledInstantiateViewViewController(coder:))

            guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector) else {
                return
            }
            guard let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
                return
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    public final func registerInjection<ComponentType>(_ type: ComponentType.Type,
                                                       injection: @escaping (ComponentType) -> Void) {
        let identifier = String(reflecting: type)

        Holder.shared.injections[identifier] = { [weak self] element in
            self?.register(lifetime: .objectGraph, initCall: { element as! ComponentType })
            injection(element as! ComponentType)
            self?.unregister(type: type)
        }
    }
    
}

// MARK: - UIView
extension UIView {
    @objc func swizzledInstantiateView(coder: NSCoder) -> UIView {
        let view = swizzledInstantiateView(coder: coder)
        injectFor(view)
        return view
    }

    private func injectFor(_ view: UIView) {
        if let restorationId = view.restorationIdentifier,
            let injection = Assembly.Holder.shared.injections[restorationId] {
            injection(view)
            return
        }

        let className = String(reflecting: type(of: view))

        if let injection = Assembly.Holder.shared.injections[className] {
            injection(view)
            return
        }
    }
}


// MARK: - UIViewController
extension UIViewController {

    @objc func swizzledInstantiateViewControllerWithNibName(nibName: String?, bundle: Bundle?) -> UIViewController {
        let viewController = swizzledInstantiateViewControllerWithNibName(nibName: nibName, bundle: bundle)
        injectFor(viewController)
        return viewController
    }

    @objc func swizzledInstantiateViewViewController(coder: NSCoder) -> UIViewController {
        let viewController = swizzledInstantiateViewViewController(coder: coder)
        injectFor(viewController)
        return viewController
    }

    private func injectFor(_ viewController: UIViewController) {
        if let restorationId = viewController.restorationIdentifier,
            let injection = Assembly.Holder.shared.injections[restorationId] {
            injection(viewController)
            return
        }

        let className = String(reflecting: type(of: viewController))

        if let injection = Assembly.Holder.shared.injections[className] {
            injection(viewController)
            return
        }
    }
}
