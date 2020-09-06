//
//  SceneDelegate.swift
//  PersonsList
//
//  Created by Alex Yatsenko on 31.07.2020.
//  Copyright © 2020 Alexislog's Production. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let coreDataManager = CoreDataManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.tintColor = .black
        let personsVC = PersonsTableViewController(coreDataManager: coreDataManager)
        window?.rootViewController = UINavigationController(rootViewController: personsVC)
        window?.makeKeyAndVisible()
    }
}

