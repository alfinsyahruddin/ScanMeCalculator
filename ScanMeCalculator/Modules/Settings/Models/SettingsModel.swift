//
//  SettingsModel.swift
//  ScanMeCalculator
//
//  Created by Alfin on 12/03/23.
//

import Foundation


struct SettingsModel: Equatable {
    let theme: Theme
    let scanSource: ScanSource
    
    var storageEngine: StorageEngine
}
