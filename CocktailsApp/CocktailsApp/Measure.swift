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

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(strMeasure: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Measure", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.strMeasure = strMeasure as String
    }
    
    
    convenience init(measure: Measure, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Measure", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.strMeasure = measure.strMeasure
    }
}
