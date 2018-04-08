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
    
    var studentLocation = StudentLocation()
    
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
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(objectId)"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }
        }
        task.resume()
    }
}

