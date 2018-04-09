//
//  StudentLocations.swift
//  On The Map
//
//  Created by Hao Wu on 9/4/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import Foundation

// MARK: Singleton StudentLocations

final class StudentLocations {
    
    private init() {}
    
    static let shared = StudentLocations()
    
    var locations = Array<StudentLocation>()
}
