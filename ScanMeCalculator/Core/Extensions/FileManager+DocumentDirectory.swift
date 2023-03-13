//
//  FileManager+DocumentDirectory.swift
//  ScanMeCalculator
//
//  Created by Alfin on 13/03/23.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
