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
    
    // MARK: IBOutlets
    
    @IBOutlet weak var addLocationBtn: UIBarButtonItem!
    @IBOutlet weak var reloadLocationBtn: UIBarButtonItem!
    @IBOutlet weak var logoutBtn: UIBarButtonItem!
    
    // MARK: IBActions

    @IBAction func logoutButtonTouched(_ sender: Any) {
        client.logout { error in
            if error != nil {
                return
            }
            // Delete location when log off
            self.appDelegate.deleteLocation()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewLocation(_ sender: Any) {
        confirmAddLocation(newLocation: self.newStudent)
    }
    
    @IBAction func reloadLocations(_ sender: Any) {
        updateLocations()
    }
    
    // MARK: Properties
    var studentInfo = StudentLocations.shared
    var newStudent: Bool = true
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let client = Client.sharedInstance()
    
    // MARK: Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUI(enable: false)
        checkLocationExist()
        updateLocations()
    }
    
    // Function of UIViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStudentPositionOverwrite" {
            let addLocationVC = segue.destination as! AddNewLocationViewController
            addLocationVC.newStudent = newStudent
        }
    }
}

private extension MapTabBarViewController {

    //Check if the Student has already existed
    func checkLocationExist() {
        let uniqueId = appDelegate.accountKey
        client.queryLocation(uniqueId!) { (results, error, other) in
            if error != nil {
                return
            } else if other == -1 {
                return
            } else {
                if let results = results {
                    if results.count > 0 {
                        self.newStudent = false
                        let result = results[0]
                        self.appDelegate.studentLocation.CreatedAt = result["createdAt"] as! String
                        self.appDelegate.studentLocation.Latitude = result["latitude"] as? Double == nil ? 0 : result["latitude"] as! Double
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
            }
            performUIUpdatesOnMain {
                self.setUI(enable: true)
            }
        }
    }

    //Get 1000 locations from the API
    func updateLocations() {
        studentInfo.locations.removeAll()
        client.getLocations { (results, error, other) in
            if error != nil {
                performUIUpdatesOnMain {
                    self.updateLocationsFailed()
                }
            } else if (other == -1) {
                performUIUpdatesOnMain {
                    self.updateLocationsFailed()
                }
            } else {
                if let results = results {
                    for result in results {
                        let location = StudentLocation(location: result as! Dictionary<String, AnyObject>)
                        self.studentInfo.locations.append(location)
                    }
                }
                performUIUpdatesOnMain {
                    self.updateLoactionsToMapAndTable()
                }
            }
        }
    }
}

// MARK: - UI functions

private extension MapTabBarViewController {
    
    func setUI(enable: Bool) {
        logoutBtn.isEnabled = enable
        reloadLocationBtn.isEnabled = enable
        addLocationBtn.isEnabled = enable
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
    
    func updateLoactionsToMapAndTable() {
        var annotations = [MKPointAnnotation]()
        
        for dictionary in self.studentInfo.locations {
            
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
        tableViewController.tableView.reloadData()
    }
    
    //Load student locations failed
    func updateLocationsFailed() {
        let message = "There was an error retrieving student data."
        let alert = UIAlertController(title: "Network Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Network Error"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
