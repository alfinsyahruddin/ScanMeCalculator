//
//  Persistence.swift
//  ScanMeCalculator
//
//  Created by Alfin on 12/03/23.
//

import CoreData

struct PersistenceController {    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ScanMeCalculator")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = ScanResultEntity(context: viewContext)
            newItem.id = UUID()
            newItem.input = "1+1"
            newItem.output = 2.0
            newItem.date = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    
    static var testing: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()

}
