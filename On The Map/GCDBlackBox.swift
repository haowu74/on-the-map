//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Hao Wu on 16/3/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
