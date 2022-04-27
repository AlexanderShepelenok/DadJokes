//
//  AppDelegate.swift
// 
//
//  Created by Aleksandr on 17/03/22.
//

import UIKit
import CoreLayer
import NetworkLayer
import DatabaseLayer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var serviceContainer: ServiceContainer?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let databaseService = CoreDataService()
        let networkService = URLSessionService()

        self.serviceContainer = ServiceContainer(databaseService: databaseService,
                                                 networkService: networkService,
                                                 favoritesManager: databaseService,
                                                 favoritesProviderCreator: databaseService)
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
