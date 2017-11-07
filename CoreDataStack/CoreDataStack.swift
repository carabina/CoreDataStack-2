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
    public static var debugMode: Bool = false
    
    /**
     * Name of the CoreData Stack
     */
    private(set) public var stackName: String
    
    /**
     * iOS 10.0 addition: Persistent Container (all in one!)
     */
    private(set) public lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: self.stackName)
        container.loadPersistentStores { (storeDescription, error) in
            guard let error = error as NSError? else { return }
            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            fatalError("\n🗄 CoreDataStack --> Persistent Container failed: Error --> \(error), User Info --> \(error.userInfo)\n")
        }
        return container
    }()
    
    /**
     * Constructor
     */
    init(stackName: String) {
        assert(stackName != "", "stackName cannot be empty. Please provide your Mapping Model name.")
        self.stackName = stackName
    }
    
    /**
     *  managedObject(withEntityName:)
     *  @description        Creates an Entity
     *  @param entityName   Desired Entity's name
     *  @return             Managed Object itself
     */
    public func managedObject(withEntityName entityName: String) -> NSManagedObject {
        return NSManagedObject(
            entity: persistentContainer.managedObjectModel.entitiesByName[entityName]!,
            insertInto: persistentContainer.viewContext
        )
    }
    
    /**
     *  write(andSave:changes:)
     *  @description        Performs a block of changes & saves it
     *  @param shouldSave   Tells to Persistent Container if it should be saved or no
     *  @param changes      Block of changes
     */
    public func write(andSave shouldSave: Bool = true, changes: @escaping () -> Void) throws {
        
        // Performs
        changes()
        
        // Saves
        guard shouldSave else { return }
        try save()
    }
    
    /**
     *  save()
     *  @description        Save changes to persistent container's view context
     */
    public func save() throws {
        
        let context = persistentContainer.viewContext
        guard context.hasChanges else {
            if CoreDataStack.debugMode { print("\n🗄 CoreDataStack --> Ignoring command, no changes applied...\n") }
            return
        }
        
        do {
            try context.save()
            if CoreDataStack.debugMode { print("\n🗄 CoreDataStack --> Context saved!\n") }
        } catch let error {
            if CoreDataStack.debugMode { print("\n🗄 CoreDataStack --> ⚠️ Saving task failed: \(error.localizedDescription)\n") }
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

