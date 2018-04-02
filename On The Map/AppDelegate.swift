//
//  AppDelegate.swift
//  On The Map
//
//  Created by Hao Wu on 7/3/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties
    
    var window: UIWindow?
    
    var sharedSession = URLSession.shared
    var requestToken: String? = nil
    var accountRegistered: Bool? = nil
    var accountKey: String? = nil
    var sessionID: String? = nil
    var sessionExpiration: String? = nil
    var userID: Int? = nil
    
    var myLon: Double? = nil
    var myLat: Double? = nil
    var myCreate: String? = nil
    var myUpdate: String? = nil
    
    var locManager = CLLocationManager()
    
    // configuration for TheMovieDB, we'll take care of this for you =)...
    //var config = Config()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locManager.requestWhenInUseAuthorization()
        var currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
            
            currentLocation = locManager.location
            
        }
        
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
}

// MARK: Create URL from Parameters
extension AppDelegate {
    
    func udacityURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        //components.scheme = Constants.UdacityDB.ApiScheme
        //components.host = Constants.UdacityDB.ApiHost
        //components.path = Constants.UdacityDB.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}

