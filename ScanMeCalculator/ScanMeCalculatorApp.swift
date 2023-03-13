//
//  ScanMeCalculatorApp.swift
//  ScanMeCalculator
//
//  Created by Alfin on 12/03/23.
//

import SwiftUI

@main
struct ScanMeCalculatorApp: App {
    @StateObject var scanResultsViewModel: ScanResultsViewModel = .init()
    @StateObject var settingsViewModel: SettingsViewModel = .init()
    
    var body: some Scene {
        WindowGroup {
            ScanResultsView(
                scanResultsViewModel: scanResultsViewModel,
                settingsViewModel: settingsViewModel
            )
            .accentColor(settingsViewModel.settings.theme.accentColor)
            .onAppear {
                UIView.appearance().tintColor = UIColor(settingsViewModel.settings.theme.accentColor)
            }
        }
    }
}

