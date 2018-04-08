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
    
    // configuration for TheMovieDB, we'll take care of this for you =)...
    //var config = Config()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        locManager.requestWhenInUseAuthorization()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        deleteLocation()
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

