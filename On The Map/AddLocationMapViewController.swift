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

    @IBOutlet weak var mapView: MKMapView!

    var newStudent: Bool = true

    let locationManager = CLLocationManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func submitNewLocation(_ sender: Any) {
        
        let location = appDelegate.studentLocation
        var request = newStudent ? URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!) : URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(location.ObjectId)")!)
        request.httpMethod = newStudent ? "POST" : "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.httpBody = "{\"uniqueKey\": \"\(location.UniqueKey)\",\"firstName\": \"\(location.FirstName)\",\"lastName\": \"\(location.LastName)\",\"mapString\": \"\(location.MapString)\", \"mediaURL\": \"\(location.MediaUrl)\",\"latitude\": \(location.Latitude), \"longitude\": \(location.Longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            DispatchQueue.main.async {
               self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
        task.resume()
        
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
