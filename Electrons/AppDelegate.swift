//
//  AppDelegate.swift
//  Electrons
//
//  Created by Jimmy M Andersson on 2019-04-06.
//  Copyright © 2019 Applyn. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.makeKeyAndVisible()
    let model = ElectronsModel(capacity: 300)
    self.window?.rootViewController = ElectronsViewController(model: model)
    return true
  }
}

