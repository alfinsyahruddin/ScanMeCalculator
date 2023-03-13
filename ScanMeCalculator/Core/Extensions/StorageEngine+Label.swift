//
//  StorageEngine+Label.swift
//  ScanMeCalculator
//
//  Created by Alfin on 13/03/23.
//

import Foundation

extension StorageEngine {
    var label: String {
        switch self {
        case .database:
            return "Database Storage"
        case .file:
            return "File Storage (Encrypted)"
        }
    }
}
