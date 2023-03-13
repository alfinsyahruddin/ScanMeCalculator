//
//  Bundle+Info.swift
//  ScanMeCalculator
//
//  Created by Alfin on 12/03/23.
//

import Foundation

extension Bundle {
    func getInfo(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
     }
}
