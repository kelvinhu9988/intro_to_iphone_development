//
//  FunctionsDB.swift
//  GraphingCalculator2
//
//  Created by Craig Frey on 9/23/17.
//  Copyright © 2017 CS2048 Instructor. All rights reserved.
//

import Foundation
import UIKit

let FunctionsDBChangeNotification = "FUNCTIONS_DB_CHANGED"

class FunctionsDB {
    static var sharedInstance = FunctionsDB()
    
    var functions = ["x", "0.1 * sin(10 * x)", "0.1 * log(10 * x)"] {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(FunctionsDBChangeNotification), object: self)
        }
    }
    var functionImages: [UIImage?] = [nil, nil, nil] {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(FunctionsDBChangeNotification), object: self)
        }
    }
}
