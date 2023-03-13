//
//  SettingsView.swift
//  ScanMeCalculator
//
//  Created by Alfin on 12/03/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        ScrollView {
            RadioSelect<StorageEngine>(
                title: "Storage Engine",
                keys: StorageEngine.allCases.map { $0.label },
                values: StorageEngine.allCases,
                selected: Binding(
                    get: { settingsViewModel.settings.storageEngine },
                    set: { settingsViewModel.setStorageEngine($0) }
                )
            )
        }
        .padding()
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsViewModel: .init())
    }
}
