//
//  Measure.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 12/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation
import CoreData


class Measure: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(strMeasure: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Measure", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: nil)
        
        self.strMeasure = strMeasure as String
    }
    
    
    convenience init(measure: Measure, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Measure", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.strMeasure = measure.strMeasure
    }
}
