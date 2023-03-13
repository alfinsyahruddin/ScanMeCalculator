//
//  ScanResultsViewModel.swift
//  ScanMeCalculator
//
//  Created by Alfin on 12/03/23.
//

import Foundation
import SwiftUI
import Vision
import CoreData
import CryptoKit


final class ScanResultsViewModel: ObservableObject {
    @Published var results: [ScanResult] = []
    @Published var isShowPhotoLibrary = false
    @Published var image = UIImage()
    @Published var alert = Alert()
    @Published var storageEngine: StorageEngine? = nil
    
    private let moc: NSManagedObjectContext
    private let fileStoragePath: URL
    private let encryptionKey: SymmetricKey

    init(
        moc: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
        fileStoragePath: URL = FileManager.documentsDirectory.appendingPathComponent("ScanResults"),
        encryptionKey: SymmetricKey = SymmetricKey(data: SHA256.hash(data: Bundle.main.getInfo("ENCRYPTION_KEY")!.data(using: .utf8)!))
    ) {
        self.moc = moc
        self.fileStoragePath = fileStoragePath
        self.encryptionKey = encryptionKey
    }
        
    func delete(_ indexSet: IndexSet) -> Void {
        for index in indexSet {
            let result = results[index]
            
            DispatchQueue.main.async {
                self.results.remove(at: index)
                self.deleteScanResult(result)
            }
            
        }
    }
    
    func didReceiveImage(_ image: UIImage) -> Void {
       self.scanTextInImage(image) { [weak self] text in
           guard let self = self else { return }
           guard var input = text else {
               self.showAlert(Errors.noTextFoundInTheImage)
               return
           }
           
           input = input
               .replacingOccurrences(of: " ", with: "")
               .replacingOccurrences(of: "x", with: "*")
               .replacingOccurrences(of: "X", with: "*")
               .replacingOccurrences(of: "×", with: "*")
           
           if input.last == "=" {
               input.removeLast()
           }
           
           print("input: \(input)")
           
           if self.isValidExpression(text: input) {
               if let result = NSExpression(format: input).expressionValue(with: nil, context: nil) as? NSNumber {
                   let output = result.doubleValue
             
                   print("output: \(output)")
                   
                   let scanResult = ScanResult(input: input, output: output)
                   DispatchQueue.main.async {
                       withAnimation {
                           self.results.insert(scanResult, at: 0)
                           self.saveScanResult(scanResult)
                       }
                   }
                   
               } else {
                   self.showAlert(Errors.failedToSaveData)
               }
           } else {
               self.showAlert(Errors.invalidExpression)
           }
        }
    }
}



// MARK: - Storage
extension ScanResultsViewModel {
    func getScanResults() {
        switch self.storageEngine {
        case .database:
            self.databaseStorageGetScanResults()
            break
        case .file:
            self.fileStorageGetScanResults()
            break
        default:
            break
        }
    }
    
    func saveScanResult(_ scanResult: ScanResult) {
        switch self.storageEngine {
        case .database:
            self.databaseStorageSaveScanResult(scanResult)
            break
        case .file:
            self.fileStorageSaveScanResult(scanResult)
            break
        default:
            break
        }
    }
    
    func deleteScanResult(_ scanResult: ScanResult) {
        switch self.storageEngine {
        case .database:
            self.databaseStorageDeleteScanResult(scanResult)
            break
        case .file:
            self.fileStorageDeleteScanResult(scanResult)
            break
        default:
            break
        }
    }
}


// MARK: - File Storage
extension ScanResultsViewModel {
    private func fileStorageGetScanResults() {
        do {
            // Open data from File Storage
            let encryptedData = try Data(contentsOf: fileStoragePath)

            // Decrypt data
            let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
            let decryptedData = try ChaChaPoly.open(sealedBox, using: encryptionKey)
            
            // Decode JSON data
            results = try JSONDecoder().decode([ScanResult].self, from: decryptedData)
        } catch {
            results = []
            print(error)
        }
    }
    
    private func fileStorageSaveScanResult(_ scanResult: ScanResult) {
        self.saveToFileStorage()
    }
    
    private func fileStorageDeleteScanResult(_ scanResult: ScanResult) {
        self.saveToFileStorage()
    }
    
    private func saveToFileStorage() {
        do {
            // Encode JSON data
            let data = try JSONEncoder().encode(self.results)

            // Encrypt JSON data
            let encryptedData = try ChaChaPoly.seal(data, using: encryptionKey).combined

            // Save to File Storage
            try encryptedData.write(to: fileStoragePath, options: [.atomic, .completeFileProtection])
        } catch {
            print(error)
            showAlert(Errors.failedToSaveData)
        }
    }
}



// MARK: - Database Storage (Core Data)
extension ScanResultsViewModel {
    private func databaseStorageGetScanResults() {
        do {
            let request = NSFetchRequest<ScanResultEntity>(entityName: "ScanResultEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let scanResultEntities = try moc.fetch(request)
            self.results = scanResultEntities.map {
                ScanResult(
                    id: $0.id!,
                    input: $0.input!,
                    output: $0.output,
                    date: $0.date!
                )
            }
        } catch {
            results = []
            print(error)
        }
    }
    
    private func databaseStorageSaveScanResult(_ scanResult: ScanResult) {
        let entity = ScanResultEntity(context: moc)
        entity.id = scanResult.id
        entity.input = scanResult.input
        entity.output = scanResult.output
        entity.date = scanResult.date
        
        saveCoreData()
    }
    
    private func databaseStorageDeleteScanResult(_ scanResult: ScanResult) {
        let fetchRequest: NSFetchRequest<ScanResultEntity> = ScanResultEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", scanResult.id as CVarArg)
        let objects = try! moc.fetch(fetchRequest)
        for obj in objects {
            moc.delete(obj)
        }

        saveCoreData()
    }
    
    private func saveCoreData() {
        do {
            try moc.save()
        } catch {
            showAlert(Errors.failedToSaveData)
            print(error)
        }
    }
    
}


// MARK: - Internal Methods
extension ScanResultsViewModel {
    internal func showAlert(_ message: String) {
        DispatchQueue.main.async {
            self.alert = Alert(isShow: true, message: message)
        }
    }
    
    internal func isValidExpression(text: String) -> Bool {
        // only support 2 argument operations, for example: 1+1
        let regex = try! NSRegularExpression(pattern: "^\\d+[+\\-\\*\\/]\\d+$", options: NSRegularExpression.Options.caseInsensitive)
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        return matches.count > 0
    }
    
    internal func scanTextInImage(_ image: UIImage, completionHandler: @escaping (String?) -> Void) -> Void {
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                fatalError("Received invalid observations")
            }

            for observation in observations {
                guard let bestCandidate = observation.topCandidates(1).first else {
                    print("No candidate")
                    continue
                }

                print("Found text: \(bestCandidate.string)")
                
                completionHandler(bestCandidate.string)
                return
            }
            
            completionHandler(nil)
        }
        request.recognitionLevel = .accurate
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let img = image.cgImage else {
                fatalError("Missing image to scan")
            }

            let handler = VNImageRequestHandler(cgImage: img, options: [:])
            try? handler.perform([request])
        }
    }
    
}
