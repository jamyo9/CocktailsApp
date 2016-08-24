//
//  DataModel.swift
//  CocktailsApp
//
//  Created by Juan Alvarez
//

import UIKit
import CoreData

class DataModel: NSObject {
    
    private class var defaultCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    private class var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.context
    }
    
    private class func saveContext() {
        CoreDataStack.sharedInstance.saveContext()
    }
    
}// End of Class
