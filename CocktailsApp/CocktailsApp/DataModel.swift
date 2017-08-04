//
//  DataModel.swift
//  CocktailsApp
//
//  Created by Juan Alvarez
//

import UIKit
import CoreData

class DataModel: NSObject {
    
    fileprivate class var defaultCenter: NotificationCenter {
        return NotificationCenter.default
    }
    
    fileprivate class var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.context
    }
    
    fileprivate class func saveContext() {
        CoreDataStack.sharedInstance.saveContext()
    }
    
}// End of Class
