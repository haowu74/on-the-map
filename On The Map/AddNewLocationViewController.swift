//
//  AddNewLocationViewController.swift
//  On The Map
//
//  Created by Hao Wu on 2/4/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
import MapKit

class AddNewLocationViewController: UIViewController {

    // MARK: IBOutlet
    
    @IBOutlet weak var myLocationInput: UITextField!
    @IBOutlet weak var myWebSiteInput: UITextField!
    
    // MARK: IBAction
    
    @IBAction func findLocation(_ sender: Any) {
        searchLocation()
    }
    
    @IBAction func cancelAddLocation(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Properties
    
    var latitude: Double?
    var longitude: Double?
    var newStudent: Bool?
    var objectId: String?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Function of UIViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addStudentPositionMap" {
            let addLocationMapVC = segue.destination as! AddLocationMapViewController
            let loc = (sender as! AddNewLocationViewController).myLocationInput.text
            let url = (sender as! AddNewLocationViewController).myWebSiteInput.text
            appDelegate.studentLocation.MapString = loc!
            appDelegate.studentLocation.MediaUrl = url!
            appDelegate.studentLocation.Latitude = latitude!
            appDelegate.studentLocation.Longitude = longitude!
            
            addLocationMapVC.newStudent = newStudent!
        }
    }
}

private extension AddNewLocationViewController {

    // MARK: Private Functions
    
    //Get the Lat / Lon from the location name
    func searchLocation() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = myLocationInput!.text
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil || response?.mapItems.count == 0 {
                performUIUpdatesOnMain {
                    self.popupLocationNotFound()
                }
            } else {
                self.latitude = response?.boundingRegion.center.latitude
                self.longitude = response?.boundingRegion.center.longitude
                performUIUpdatesOnMain {
                    self.validateWebUrl()
                }
            }
        }
    }
}

// MARK: AddNewLocationViewController UI Functions

private extension AddNewLocationViewController {
    
    // Validate the URL string form
    func validateWebUrl() {
        if let urlString = myWebSiteInput?.text {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                if !UIApplication.shared.canOpenURL(url) {
                    popupUrlNotValid()
                } else {
                    self.performSegue(withIdentifier: "addStudentPositionMap", sender: self)
                }
            }
        }
    }
    
    //Pop up dialogue if the location can't be found
    func popupLocationNotFound() {
        let alert = UIAlertController(title: "Location Not Found", message: "Could Not Geocode this String.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Cancel action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    //Pop up dialogue if the URL is badly formed
    func popupUrlNotValid() {
        let alert = UIAlertController(title: "Location Not Found", message: "Invalid Link. Include HTTP(s)://.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Cancel action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
