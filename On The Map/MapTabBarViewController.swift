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

    override func viewDidLoad() {
        super.viewDidLoad()

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
        }
        task.resume()
    }
    
    @IBAction func reloadLocations(_ sender: Any) {
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
                        
                        let location = StudentLocation(CreatedAt: result["createdAt"] as! String, FirstName: result["firstName"] as! String, LastName: result["lastName"] as! String , Latitude: result["latitude"] as! Double, Longitude: result["longitude"] as! Double, MapString: result["mapString"] as! String, MediaUrl: "", ObjectId: result["objectId"] as! String, UniqueKey: result["uniqueKey"] as! String, UpdatedAt: result["updatedAt"] as! String)
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
                    annotation.subtitle = mediaURL
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                }
                
                // When the array is complete, we add the annotations to the map.
                let mapViewController = self.viewControllers?[0] as! MapViewController
                mapViewController.mapView.addAnnotations(annotations)
                
                let navViewController = self.viewControllers?[1] as! UINavigationController
                let tableViewController = navViewController.topViewController as! StudentListTableViewController
                tableViewController.locations = self.locations
                tableViewController.tableView.reloadData()
            }
            
            
        }
        task.resume()
    }
    

}
