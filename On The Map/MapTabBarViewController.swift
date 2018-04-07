//
//  MapTabBarViewController.swift
//  On The Map
//
//  Created by Hao Wu on 16/3/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
import MapKit

class MapTabBarViewController: UITabBarController {
    
    var locations: [StudentLocation] = []
    
    var newStudent: Bool = true
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func logoutButtonTouched(_ sender: Any) {
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
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            
            self.dismiss(animated: true, completion: nil)
            
            self.appDelegate.deleteLocation()
        }
        task.resume()
    }
    
    
    @IBAction func addNewLocation(_ sender: Any) {
        checkLocationExist()
    }
    
    
    
    @IBAction func reloadLocations(_ sender: Any) {
        updateLocations()
    }
    
    //Check if the Student has already existed
    func checkLocationExist() {
        
        let uniqueId = appDelegate.accountKey
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueId!)%22%7D"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error
                return
            }
            let parsedResult: [String:[AnyObject]]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:[AnyObject]]
                if let results = parsedResult["results"] {
                    if results.count > 0 {
                        self.newStudent = false
                        let result = results[0]
                        self.appDelegate.studentLocation.CreatedAt = result["createdAt"] as! String
                        self.appDelegate.studentLocation.FirstName = result["firstName"] as? String == nil ? "" : result["firstName"] as! String
                        //self.appDelegate.studentLocation.LastName = result["lastName"] as? String == nil ? "" : result["lastName"] as! String
                        //self.appDelegate.studentLocation.Latitude = result["latitude"] as? Double == nil ? 0 : result["latitude"] as! Double
                        self.appDelegate.studentLocation.Longitude = result["longitude"] as? Double == nil ? 0 : result["longitude"] as! Double
                        self.appDelegate.studentLocation.MapString = result["mapString"] as? String == nil ? "" : result["mapString"] as! String
                        self.appDelegate.studentLocation.MediaUrl = result["mediaURL"] as? String == nil ? "" : result["mediaURL"] as! String
                        self.appDelegate.studentLocation.ObjectId = result["objectId"] as! String
                        self.appDelegate.studentLocation.UniqueKey = result["uniqueKey"] as! String
                        self.appDelegate.studentLocation.UpdatedAt = result["updatedAt"] as! String
                        
                    } else {
                        self.newStudent = true

                    }
                }
                
            } catch {
                //print("Could not parse the data as JSON: '\(newData)'")
                return
            }
            DispatchQueue.main.async {
                self.confirmAddLocation(newLocation: self.newStudent)
            }
            
        }
        task.resume()
    }

    func confirmAddLocation(newLocation: Bool) {
        
        if newLocation {
            //If you have not set location yet
            self.performSegue(withIdentifier: "showStudentPositionOverwrite", sender: nil)
        } else {
            //If you have already set a location
            let message = "User \"\(appDelegate.studentLocation.FirstName) \(appDelegate.studentLocation.LastName)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Location?"
            let alert = UIAlertController(title: "Overwrite Location", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Overwrite", comment: "Default action"), style: .default, handler: { _ in
                self.performSegue(withIdentifier: "showStudentPositionOverwrite", sender: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStudentPositionOverwrite" {
            //let navController = segue.destination as! UINavigationController
            //let addLocationVC = navController.viewControllers[0] as! AddNewLocationViewController
            let addLocationVC = segue.destination as! AddNewLocationViewController
            addLocationVC.newStudent = newStudent
        }
    }
    
    func updateLocations() {
        locations.removeAll()
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=1000")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            
            //print(String(data: newData!, encoding: .utf8)!)
            let parsedResult: [String:[AnyObject]]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:[AnyObject]]
                if let results = parsedResult["results"] {
                    for result in results {
                        let location = StudentLocation(CreatedAt: result["createdAt"] as! String,
                                                       FirstName: result["firstName"] as? String == nil ? "" : result["firstName"] as! String,
                                                       LastName: result["lastName"] as? String == nil ? "" : result["lastName"] as! String,
                                                       Latitude: result["latitude"] as? Double == nil ? 0 : result["latitude"] as! Double,
                                                       Longitude: result["longitude"] as? Double == nil ? 0 : result["longitude"] as! Double,
                                                       MapString: result["mapString"] as? String == nil ? "" : result["mapString"] as! String,
                                                       MediaUrl: result["mediaURL"] as? String == nil ? "" : result["mediaURL"] as! String,
                                                       ObjectId: result["objectId"] as! String,
                                                       UniqueKey: result["uniqueKey"] as! String,
                                                       UpdatedAt: result["updatedAt"] as! String)
                        self.locations.append(location)
                    }
                }
                
            } catch {
                //print("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            DispatchQueue.main.async {
                var annotations = [MKPointAnnotation]()
                
                // The "locations" array is loaded with the sample data below. We are using the dictionaries
                // to create map annotations. This would be more stylish if the dictionaries were being
                // used to create custom structs. Perhaps StudentLocation structs.
                
                for dictionary in self.locations {
                    
                    // Notice that the float values are being used to create CLLocationDegree values.
                    // This is a version of the Double type.
                    let lat = CLLocationDegrees(dictionary.Latitude)
                    let long = CLLocationDegrees(dictionary.Longitude)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = dictionary.FirstName
                    let last = dictionary.LastName
                    let mediaURL = dictionary.MediaUrl
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    
                    let attributedString = NSMutableAttributedString(string: mediaURL)
                    attributedString.addAttribute(.link, value: mediaURL, range: NSRange(location: 0, length: mediaURL.count))
                    
                    annotation.subtitle = mediaURL
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                    
                }
                
                // When the array is complete, we add the annotations to the map.
                let mapViewController = self.viewControllers?[0] as! MapViewController
                mapViewController.mapView.addAnnotations(annotations)
                mapViewController.mapView.delegate = mapViewController
                let tableViewController = self.viewControllers?[1] as! StudentListTableViewController
                tableViewController.locations = self.locations
                tableViewController.tableView.reloadData()
            }
            
        }
        task.resume()
    }
    
    
}
