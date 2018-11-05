//
//  AppDelegate.swift
//  Example
//
//  Created by Luong Van Lam on 11/4/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let viewModel = RepoViewModel(firstPageIndex: 1, itemPerPage: 10)
    let next = TableViewExample(viewModel: viewModel)

    window?.rootViewController = next
    window?.makeKeyAndVisible()

    return true
  }
}
