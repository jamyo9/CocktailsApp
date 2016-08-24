//
//  Ingredient.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 12/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation
import CoreData


class Ingredient: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(strIngredient: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Ingredient", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.strIngredient = strIngredient as String
    }
}
