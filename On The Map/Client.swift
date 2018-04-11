//
//  Client.swift
//  On The Map
//
//  Created by Hao Wu on 9/4/18.
//  Copyright © 2018 S&J. All rights reserved.
//
import UIKit
import Foundation

class Client {
    
    // MARK: Properties
    
    // constants
    let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    let ApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let ApiKeyField = "X-Parse-REST-API-Key"
    let ApplicationIdField = "X-Parse-Application-Id"
    
    // shared session
    var session = URLSession.shared
    
    // MARK: Web API Functions
    
    // Create Session
    func login(_ username: String, _ password: String, _ completionHandlerForLogin: @escaping (_ id: String?, _ expiration: String?, _ registered: Bool?, _ key: String?, _ error: Error?, _ other: Int) -> Void) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandlerForLogin(nil, nil, nil, nil, error, 0)
            } else {
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
                    if let status = parsedResult["status"]{
                        completionHandlerForLogin(nil, nil, nil, nil, nil, status as! Int)
                    }
                    if let session = parsedResult["session"], let account = parsedResult["account"] {
                        let id = session["id"] as? String
                        let expiration = session["expiration"] as? String
                        let registered = account["registered"] as? Bool
                        let key = account["key"] as? String
                        completionHandlerForLogin(id, expiration, registered, key, nil, 0)
                    }
                } catch {
                    completionHandlerForLogin(nil, nil, nil, nil, nil, -1)
                }
            }
        }
        task.resume()
    }
    
    // Delete Session
    func logout(_ completionHandlerForLogout: @escaping (_ error: Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            completionHandlerForLogout(nil)
        }
        task.resume()
    }
    
    // Get Username
    func getUsername(_ userId: String, _ completionHandlerForUsername: @escaping (_ firstName: String?, _ lastName: String?, _ error: Error?, _ other: Int) -> Void) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(userId)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandlerForUsername(nil, nil, error, 0)
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
                if let user = parsedResult["user"] {
                    let lastName = user["last_name"] as? String
                    let firstName = user["first_name"] as? String
                    completionHandlerForUsername(lastName, firstName, nil, 0)
                }
            } catch {
                completionHandlerForUsername(nil, nil, nil, -1)
            }
        }
        task.resume()
    }
    
    // Read Student Info
    func queryLocation(_ uniqueId: String, _ completionHandlerForLocation: @escaping (_ location: StudentLocation?, _ error: Error?, _ other: Int) -> Void) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueId)%22%7D"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue(ApplicationId, forHTTPHeaderField: ApplicationIdField)
        request.addValue(ApiKey, forHTTPHeaderField: ApiKeyField)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandlerForLocation(nil, error, 0)
            } else {
                do {
                    let parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:[AnyObject]]
                    if let results = parsedResult["results"] {
                        if results.count > 0 {
                            let location = StudentLocation(location: results[0] as! Dictionary<String, AnyObject>)
                            completionHandlerForLocation(location, nil, 0)
                        } else {
                            completionHandlerForLocation(nil, nil, 0)
                        }
                    }
                } catch {
                    completionHandlerForLocation(nil, nil, -1)
                }
            }
        }
        task.resume()
    }
    
    // Get Students Info
    func getLocations(_ completionHandlerForLocations: @escaping (_ locations: [StudentLocation]?, _ error: Error?, _ other: Int) -> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(ApplicationId, forHTTPHeaderField: ApplicationIdField)
        request.addValue(ApiKey, forHTTPHeaderField: ApiKeyField)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandlerForLocations(nil, error, 0)
            } else {
                do {
                    let parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:[AnyObject]]
                    if let results = parsedResult["results"] {
                        var locations: [StudentLocation] = []
                        for result in results {
                            let location = StudentLocation(location: result as! Dictionary<String, AnyObject>)
                            locations.append(location)
                        }
                        completionHandlerForLocations(locations, nil, 0)
                    }                    
                } catch {
                    completionHandlerForLocations(nil, nil, -1)
                }
            }
        }
        task.resume()
    }
    
    // Add new Student Info
    func postLocation(_ location: StudentLocation, _ completionHandlerForLocation: @escaping (_ error: Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(ApplicationId, forHTTPHeaderField: ApplicationIdField)
        request.addValue(ApiKey, forHTTPHeaderField: ApiKeyField)
        request.httpBody = "{\"uniqueKey\": \"\(location.UniqueKey)\",\"firstName\": \"\(location.FirstName)\",\"lastName\": \"\(location.LastName)\",\"mapString\": \"\(location.MapString)\", \"mediaURL\": \"\(location.MediaUrl)\",\"latitude\": \(location.Latitude), \"longitude\": \(location.Longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
                completionHandlerForLocation(error)
        }
        task.resume()
    }
    
    // Update Student Info
    func putLocation(_ location: StudentLocation, _ completionHandlerForLocation: @escaping (_ error: Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(location.ObjectId)")!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(ApplicationId, forHTTPHeaderField: ApplicationIdField)
        request.addValue(ApiKey, forHTTPHeaderField: ApiKeyField)
        request.httpBody = "{\"uniqueKey\": \"\(location.UniqueKey)\",\"firstName\": \"\(location.FirstName)\",\"lastName\": \"\(location.LastName)\",\"mapString\": \"\(location.MapString)\", \"mediaURL\": \"\(location.MediaUrl)\",\"latitude\": \(location.Latitude), \"longitude\": \(location.Longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            completionHandlerForLocation(error)
        }
        task.resume()
    }
    
    // Delete Student Info
    func deleteLocation(_ objectId: String, _ completionHandlerForLocation: ((_ error: Error?) -> Void)?) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(objectId)"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(ApplicationId, forHTTPHeaderField: ApplicationIdField)
        request.addValue(ApiKey, forHTTPHeaderField: ApiKeyField)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            completionHandlerForLocation?(error)
        }
        task.resume()
    }

    // MARK: Shared Instance
    
    private init() {}
    
    static let sharedInstance = Client()

}
