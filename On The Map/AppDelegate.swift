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
    
    var studentLocation = StudentLocation(location: nil)
    
    let client = Client.sharedInstance
    
    // MARK: Life Cycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        locManager.requestWhenInUseAuthorization()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        //Delete location when the app is terminated
        deleteLocation()
    }
}

// MARK: Create URL from Parameters
extension AppDelegate {
    
    //Delete the location using Web API
    func deleteLocation() {
        let objectId = studentLocation.ObjectId
        client.deleteLocation(objectId, nil)
    }
}

