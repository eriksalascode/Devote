//
//  Persistence.swift
//  Devote
//
//  Created by Erik Salas on 6/17/21.
//

import CoreData

struct PersistenceController {
    //MARK: - 1. PERSISTENT CONTROLLER
    static let shared = PersistenceController()

    //MARK: - 2. PERSISTENT CONTAINER
    let container: NSPersistentContainer

    //MARK: - 3. INITIALIZATION (load the persistent store)
    //using in memory storage instead of the default disk storage for this project
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Devote")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    //MARK: - 4. PREVIEW
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        //showing 10 sample items that are shown on preview
        for i in 0..<5 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.task = "Sample task No\(i)"
            newItem.completion = false
            newItem.id = UUID()
        }
        //using the do try catch block, we saved the data into the memory store
        do {
            try viewContext.save()
        } catch {

            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
