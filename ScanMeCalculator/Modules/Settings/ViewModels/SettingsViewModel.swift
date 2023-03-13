//
//  SettingsViewModel.swift
//  ScanMeCalculator
//
//  Created by Alfin on 12/03/23.
//

import Foundation


final class SettingsViewModel: ObservableObject {
    @Published var settings: SettingsModel = SettingsModel(
        // Compile time
        theme: Theme.init(rawValue: Bundle.main.getInfo("THEME") ?? Theme.red.rawValue)!,
        scanSource: ScanSource.init(rawValue: Bundle.main.getInfo("SCAN_SOURCE") ?? ScanSource.camera.rawValue)!,
 
        // Run time
        storageEngine: StorageEngine.init(
            rawValue: UserDefaults.standard.string(
                forKey: UserDefaultsKey.storageEngine
            ) ?? StorageEngine.database.rawValue
        )!
   )
    
    func setStorageEngine(_ storageEngine: StorageEngine) -> Void {
        self.settings.storageEngine = storageEngine
        UserDefaults.standard.set(storageEngine.rawValue, forKey: UserDefaultsKey.storageEngine)
    }
}
