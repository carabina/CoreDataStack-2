//
//  CoreDataStack.swift
//  CoreDataStack
//
//  Created by Felipe Ricieri on 05/11/17.
//  Copyright © 2017 Ricieri ME. All rights reserved.
//

import Foundation
import CoreData

/**
 *  CoreData Stack
 *  @description    Abstraction of CoreData Stack. Thanks to Realm Academy (https://academy.realm.io)
 *  @url            Read more in https://academy.realm.io/posts/andy-matuschak-refactor-mega-controller/
 */
public class CoreDataStack {
    
    /**
     * Name of the CoreData Stack
     */
    fileprivate(set) public var stackName: String = "CoreData"
    
    /**
     * Constructor
     */
    init(stackName: String) {
        self.stackName = stackName
    }
    
    /**
     * URLs
     */
    public lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    /**
     * Object Model
     */
    public lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURK = Bundle.main.url(forResource: self.stackName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURK)!
    }()
    
    /**
     * Persistent Coordinator
     */
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(self.stackName).sqlite")
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            fatalError("CoreDataStack --> ⚠️ Couldn't load database: \(error)")
        }
        
        return coordinator
    }()
    
    /**
     * Main Context
     */
    public lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    /**
     *  managedObject(withEntityName:)
     *  @description        Creates an Entity
     *  @param entityName   Desired Entity's name
     *  @return             Managed Object itself
     */
    func managedObject(withEntityName entityName: String) -> NSManagedObject {
        return NSManagedObject(
            entity: managedObjectContext.persistentStoreCoordinator!.managedObjectModel.entitiesByName[entityName]!,
            insertInto: managedObjectContext
        )
    }
    
    /**
     *  write(_:)
     *  @description    Performs a block of changes & saves it
     *  @param changes  Block of changes
     */
    func write(_ changes: @escaping () -> Void) {
        
        // Performs
        changes()
        
        // Saves
        do {
            try managedObjectContext.save()
        } catch let error {
            print("CoreDataStack --> ⚠️ Saving task failed: \(error.localizedDescription)")
        }
    }
    
    /*
     // Example of how create a managed object
     let newTask = NSManagedObject(entity: coreDataStack.managedObjectContext.persistentStoreCoordinator!.managedObjectModel.entitiesByName["Task"]!, insertIntoManagedObjectContent: coreDataStack.managedObjectContext)
     newTask.setValue(addViewController.textField.text, forKey "title")
     newTask.setValue(addViewController.datePicker.text, forKey "dueDate")
     try! coreDataStack.managedObjectContext.save()
     */
}

