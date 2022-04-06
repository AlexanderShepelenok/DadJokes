//
//  AppDelegate.swift
//  DadJokes
//
//  Created by Aleksandr on 17/03/22.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var serviceContainer: ServiceContainer?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.serviceContainer = ServiceContainer()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting
                     connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}
