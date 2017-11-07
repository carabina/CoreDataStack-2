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
     * Debugging mode state
     */
    private(set) public static var debugMode: Bool = false
    
    /**
     * Name of the CoreData Stack
     */
    private(set) public var stackName: String
    
    /**
     * Constructor
     */
    init(stackName: String) {
        assert(stackName != "", "stackName cannot be empty. Please provide your Mapping Model name.")
        self.stackName = stackName
    }
    
    /**
     * URLs
     */
    private(set) public lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    /**
     * Object Model
     */
    private(set) public lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURK = Bundle.main.url(forResource: self.stackName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURK)!
    }()
    
    /**
     * Persistent Coordinator
     */
    private(set) public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
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
    private(set) public lazy var managedObjectContext: NSManagedObjectContext = {
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
    open func managedObject(withEntityName entityName: String) -> NSManagedObject {
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
    open func write(andSave shouldSave: Bool = true, changes: @escaping () -> Void) throws {
        
        // Performs
        changes()
        
        // Saves
        guard shouldSave else { return }
        do {
            try managedObjectContext.save()
            if CoreDataStack.debugMode { print("CoreDataStack --> Context saved!") }
        } catch let error {
            if CoreDataStack.debugMode { print("CoreDataStack --> ⚠️ Saving task failed: \(error.localizedDescription)") }
            throw error
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

