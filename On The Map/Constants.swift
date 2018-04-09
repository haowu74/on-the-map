//
//  Constants.swift
//  On The Map
//
//  Created by Hao Wu on 11/3/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit

// MARK: - Constants

struct Constants {
    
    // MARK: UI
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
    
    static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let ApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"

}

// MARK: Parameter Keys
struct ParameterKeys {
    static let ApiKey = "X-Parse-REST-API-Key"
    static let ApplicationId = "X-Parse-Application-Id"
    static let SessionID = "session_id"
    static let RequestToken = "request_token"
    static let Query = "query"
}
