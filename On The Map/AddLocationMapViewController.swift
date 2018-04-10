//
//  AddLocationMapViewController.swift
//  On The Map
//
//  Created by Hao Wu on 3/4/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
import MapKit

class AddLocationMapViewController: UIViewController {

    // MARK: IBOutlet
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: IBAction
    
    @IBAction func submitNewLocation(_ sender: Any) {
        
        let location = appDelegate.studentLocation
        if newStudent {
            client.postLocation(location) { (error) in
                if error != nil {
                    self.addLocationFailed()
                } else {
                    performUIUpdatesOnMain {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    self.appDelegate.studentLocation = location
                }
            }
        } else {
            client.putLocation(location) { (error) in
                if error != nil {
                    self.addLocationFailed()
                } else {
                    performUIUpdatesOnMain {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    self.appDelegate.studentLocation = location
                }
            }
        }
    }
    
    // MARK: Properties
    
    var newStudent: Bool = true
    let locationManager = CLLocationManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let client = Client.sharedInstance()
    
    // MARK: Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let annotation = MKPointAnnotation()
        annotation.title = appDelegate.studentLocation.MapString
        annotation.coordinate = CLLocationCoordinate2DMake(appDelegate.studentLocation.Latitude, appDelegate.studentLocation.Longitude)
        self.mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        self.mapView.setRegion(region, animated: false)
    }
}

// MARK: AddLocationMapViewController UI Functions

private extension AddLocationMapViewController {
    
    func addLocationFailed() {
        let message = "New Location Cannot be Submit to Server."
        let alert = UIAlertController(title: "Submit Location Failed.", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Cancel Log In"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
