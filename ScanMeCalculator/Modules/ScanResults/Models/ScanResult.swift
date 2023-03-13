//
//  ScanResult.swift
//  ScanMeCalculator
//
//  Created by Alfin on 12/03/23.
//

import Foundation

struct ScanResult: Equatable, Identifiable, Codable {
    var id: UUID = UUID()
    var input: String
    var output: Double
    var date: Date = Date()
}
