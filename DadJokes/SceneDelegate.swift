//
//  SceneDelegate.swift
//  DadJokes
//
//  Created by Aleksandr on 17/03/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var viewControllerFactory: ViewControllerFactory?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let serviceContainer = appDelegate.serviceContainer else {
                  fatalError("Dependency initialization failed")
              }

        let window = UIWindow(windowScene: windowScene)
        let viewControllerFactory = ViewControllerFactory(serviceContainer: serviceContainer)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let rootViewController = storyboard.instantiateInitialViewController { coder -> RootViewController? in
            viewControllerFactory.createRootViewController(coder)
        }

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window
        self.viewControllerFactory = viewControllerFactory
    }
}
