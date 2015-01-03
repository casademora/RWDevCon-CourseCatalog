//
//  CoreDataStack+Additions.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/29/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import Foundation
import CoreData
import Swell

private func entityNameFromType<T : NSManagedObject>(type:T.Type) -> String?
{
    return NSStringFromClass(type).componentsSeparatedByString(".").last
}

private func cast<T, U>(object:T?) -> U?
{
    if let object = object {
        return object as? U
    }
    return .None
}

extension CoreDataStack
{
    func find<T : NSManagedObject>(type:T.Type, orderedBy: [NSSortDescriptor]? = nil, predicate:NSPredicate? = nil) -> [T]?
    {
        let request = NSFetchRequest(entityName: entityNameFromType(type)!)
        request.predicate = predicate
        request.sortDescriptors = orderedBy
        
        var error : NSError?
        let result = mainContext.executeFetchRequest(request, error: &error) as? [T]
        if result == nil
        {
            logger.error("[find] \(error)")
        }
        return result
    }
    
    func findFirst<T : NSManagedObject>(type:T.Type, predicate:NSPredicate? = nil) -> T?
    {
        let request = NSFetchRequest(entityName: entityNameFromType(type)!)
        request.predicate = predicate
        request.fetchLimit = 1
        
        var error : NSError?
        let result = mainContext.executeFetchRequest(request, error: &error) as? [T]
        if result == nil
        {
            logger.error("[find] \(error)")
        }
        return result?.first
    }
    
    func exists<T : NSManagedObject>(type:T.Type, predicate:NSPredicate? = nil) -> Bool
    {
        let request = NSFetchRequest(entityName: entityNameFromType(type)!)
        request.predicate = predicate
        
        var error : NSError?
        let count = mainContext.countForFetchRequest(request, error: &error)
        if count == NSNotFound
        {
            logger.error("[exists] \(error)")
        }
        return count > 0
    }
    
    //CRUD
    public func create<T : NSManagedObject>(type:T.Type) -> T?
    {
        return create(type, inContext: mainContext)
    }
    
    func createInBackground<T : NSManagedObject>(type:T.Type) -> T?
    {
        return create(type, inContext: backgroundContext)
    }
    
    func create<T : NSManagedObject>(type:T.Type, inContext context:NSManagedObjectContext) -> T?
    {
        if let entityName = entityNameFromType(type)
        {
            let entity = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as NSManagedObject
            return cast(entity)
        }
        return .None
    }
    
    public func save()
    {
        saveUsing(Context: backgroundContext)
    }
    
    func saveUsing(Context context:NSManagedObjectContext)
    {
        var error : NSError?
        if context.hasChanges
        {
            let saved = context.save(&error)
            if !saved
            {
                logger.error("Error saving: \(error)")
            }
            else
            {
                logger.debug("Saved context successfully")
            }
        }
        else
        {
            logger.warn("No changes to save")
        }
    }
}