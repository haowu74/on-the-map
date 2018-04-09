//
//  StudentLocations.swift
//  On The Map
//
//  Created by Hao Wu on 20/3/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import Foundation

struct StudentLocation {
    
    // MARK: Members
    var CreatedAt: String = ""
    var FirstName: String = ""
    var LastName: String = ""
    var Latitude: Double = 0
    var Longitude: Double = 0
    var MapString: String = ""
    var MediaUrl: String = ""
    var ObjectId: String = ""
    var UniqueKey: String = ""
    var UpdatedAt: String = ""
    
    // MARK: Constructor
    init(location: Dictionary<String, Any>?) {
        CreatedAt = location?["createdAt"] as? String ?? ""
        FirstName = location?["firstName"] as? String ?? ""
        LastName = location?["lastName"] as? String ?? ""
        Latitude = location?["latitude"] as? Double ?? 0
        Longitude = location?["longitude"] as? Double ?? 0
        MapString = location?["mapString"] as? String ?? ""
        MediaUrl = location?["mediaURL"] as? String ?? ""
        ObjectId = location?["objectId"] as? String ?? ""
        UniqueKey = location?["uniqueKey"] as? String ?? ""
        UpdatedAt = location?["updatedAt"] as? String ?? ""
    }
}
