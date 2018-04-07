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

    @IBOutlet weak var myLocationInput: UITextField!
    @IBOutlet weak var myWebSiteInput: UITextField!
    
    @IBAction func findLocation(_ sender: Any) {
        searchLocation()
        
    }
    
    @IBAction func cancelAddLocation(_ sender: Any) {
        //self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    var latitude: Double?
    var longitude: Double?
    var newStudent: Bool?
    var objectId: String?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
    
    func searchLocation() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = myLocationInput!.text
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil || response?.mapItems.count == 0 {
                DispatchQueue.main.async {
                    self.popupLocationNotFound()
                }
            } else {
                self.latitude = response?.boundingRegion.center.latitude
                self.longitude = response?.boundingRegion.center.longitude
                self.validateWebUrl()
            }
        }
        
    }
    
    
    func validateWebUrl() {
        if let urlString = myWebSiteInput?.text {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                if !UIApplication.shared.canOpenURL(url) {
                    popupLocationNotFound()
                } else {
                    self.performSegue(withIdentifier: "addStudentPositionMap", sender: self)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addStudentPositionMap" {
            let addLocationMapVC = segue.destination as! AddLocationMapViewController
            let loc = (sender as! AddNewLocationViewController).myLocationInput.text
            let url = (sender as! AddNewLocationViewController).myWebSiteInput.text
            appDelegate.studentLocation.MapString = loc!
            appDelegate.studentLocation.MediaUrl = url!
            appDelegate.studentLocation.Latitude = latitude!
            appDelegate.studentLocation.Longitude = longitude!
            /*
            addLocationMapVC.location = loc
            addLocationMapVC.url = url
            addLocationMapVC.latitude = latitude
            addLocationMapVC.longitude = longitude
            
            addLocationMapVC.newStudent = newStudent!
            addLocationMapVC.objectId = objectId
            */
            
            addLocationMapVC.newStudent = newStudent!
        }
    }
    
    func popupLocationNotFound() {
        let alert = UIAlertController(title: "New Location", message: "This is an alert.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Cancel action"), style: .default, handler: { _ in
            NSLog("The \"Cancel\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func popupUrlNotValid() {
        let alert = UIAlertController(title: "Overwrite Location", message: "This is an alert.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Cancel action"), style: .default, handler: { _ in
            NSLog("The \"Cancel\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
