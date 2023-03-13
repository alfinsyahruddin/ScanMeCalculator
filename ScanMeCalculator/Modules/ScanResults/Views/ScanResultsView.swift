//
//  ScanResultsView.swift
//  ScanMeCalculator
//
//  Created by Alfin on 12/03/23.
//


import SwiftUI


struct ScanResultsView: View {    
    @ObservedObject var scanResultsViewModel: ScanResultsViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    
    var body: some View {
        NavigationView {
            List {
                
                if scanResultsViewModel.results.isEmpty {
                    Text("No data available.")
                }
                
                ForEach(scanResultsViewModel.results) { item in
                    HStack {
                        Text("\(item.input) = \(String(format: "%g", item.output))")
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("\(item.date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondaryLabel)
                    }
                }
                .onDelete(perform: { scanResultsViewModel.delete($0) })
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        SettingsView(settingsViewModel: settingsViewModel)
                    } label: {
                        Image("icon.settings").renderingMode(.template)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        scanResultsViewModel.isShowPhotoLibrary = true
                    }) {
                        Image("icon.scan").renderingMode(.template)
                    }
                }
            }
            .navigationBarTitle("Scan me!", displayMode: .inline)
            .sheet(isPresented: $scanResultsViewModel.isShowPhotoLibrary) {
                ImagePicker(
                    sourceType: settingsViewModel.settings.scanSource == .camera ? .camera : .photoLibrary,
                    selectedImage: Binding(
                        get: { scanResultsViewModel.image },
                        set: { scanResultsViewModel.didReceiveImage($0) }
                    )
                )
            }
            .alert(scanResultsViewModel.alert.message, isPresented: $scanResultsViewModel.alert.isShow) {
                Button("OK", role: .cancel) { }
            }
            .onChange(of: settingsViewModel.settings.storageEngine) { newValue in
                scanResultsViewModel.storageEngine = settingsViewModel.settings.storageEngine
                scanResultsViewModel.getScanResults()
            }
            .onAppear {
                scanResultsViewModel.storageEngine = settingsViewModel.settings.storageEngine
                scanResultsViewModel.getScanResults()
            }
        }
    }
}



struct ScanResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ScanResultsView(
            scanResultsViewModel: .init(moc: PersistenceController.preview.container.viewContext),
            settingsViewModel: .init()
        )
    }
}

