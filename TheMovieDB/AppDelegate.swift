//
//  AppDelegate.swift
//  TheMovieDB
//
//  Created by Fransico D. on 2/21/19.
//  Copyright © 2019 innomar.cl. All rights reserved.
//
// swiftlint:disable discouraged_optional_collection
import AlamofireImage
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {

        //Mange cache for alamofire images
        _ = AutoPurgingImageCache(
            memoryCapacity: 100_000_000,
            preferredMemoryUsageAfterPurge: 60_000_000
        )

        // Override point for customization after application launch.
        return true
    }
}
// swiftlint:enable discouraged_optional_collection
