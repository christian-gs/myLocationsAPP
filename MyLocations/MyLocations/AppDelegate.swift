//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Christian on 2/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //core data variables
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabController = UITabBarController()
        let currentLocationViewController = CurrentLocationController()
        currentLocationViewController.tabBarItem = UITabBarItem(title: "Current Location", image: #imageLiteral(resourceName: "pin") , selectedImage: #imageLiteral(resourceName: "pin") )
        currentLocationViewController.managedObjectContext = self.managedObjectContext //coreData
        let currentLocationNavController = UINavigationController(rootViewController: currentLocationViewController)

        let locationsViewController = LocationsViewController()
        locationsViewController.tabBarItem = UITabBarItem(title: "Saved Locations", image: #imageLiteral(resourceName: "list"), selectedImage: #imageLiteral(resourceName: "list") )
        locationsViewController.managedObjectContext = self.managedObjectContext
        let locationsNavController = UINavigationController(rootViewController: locationsViewController)

        let mapViewController = MapViewController()
        mapViewController.tabBarItem = UITabBarItem(title: "Map", image: #imageLiteral(resourceName: "globe"), selectedImage: #imageLiteral(resourceName: "globe"))
        mapViewController.managedObjectContext = self.managedObjectContext
        let mapNavController = UINavigationController(rootViewController: mapViewController)
        tabController.viewControllers = [currentLocationNavController, locationsNavController, mapNavController]

        UIButton.appearance().setTitleColor(#colorLiteral(red: 1, green: 0.7658156157, blue: 0, alpha: 1), for: .normal)
        UITabBar.appearance().tintColor = #colorLiteral(red: 1, green: 0.7658156157, blue: 0, alpha: 1)
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 1, green: 0.7658156157, blue: 0, alpha: 1)
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.1532945335, green: 0.1665433645, blue: 0.184310317, alpha: 1)
        UITabBar.appearance().barTintColor = #colorLiteral(red: 0.1532945335, green: 0.1665433645, blue: 0.184310317, alpha: 1)
        UILabel.appearance().textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let textAttributes = [NSAttributedStringKey.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        UINavigationBar.appearance().titleTextAttributes = textAttributes

        
        window.rootViewController = tabController
        window.makeKeyAndVisible()
        self.window = window // cursed code

        //print coreData file path
        print("\n\n\n \(applicationDocumentsDirectory) \n\n\n")
        // custom method sets up listerner for fatalCoreData errors
        listenForFatalCoreDataNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK:- Helper methods

    //listener for custom fatalCoreData function
    func listenForFatalCoreDataNotifications() {
        // 1
        NotificationCenter.default.addObserver( forName: CoreDataSaveFailedNotification,
            object: nil, queue: OperationQueue.main, using: { notification in
                // 2
                let message = """
                There was a fatal error in the app and it cannot continue.

                Press OK to terminate the app. Sorry for the inconvenience.
                """
                // 3
                let alert = UIAlertController( title: "Internal Error", message: message, preferredStyle: .alert)
                // 4
                let action = UIAlertAction(title: "OK", style: .default) { _ in
                    let exception = NSException( name: NSExceptionName.internalInconsistencyException,
                        reason: "Fatal Core Data error", userInfo: nil)
                    exception.raise()
                }
                alert.addAction(action)
                // 5
                let tabController = self.window!.rootViewController!
                tabController.present(alert, animated: true, completion: nil)
        })
    }


}

