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

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(strIngredient: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Ingredient", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.strIngredient = strIngredient as String
    }
    
    convenience init(ingredient: Ingredient, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Ingredient", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.strIngredient = ingredient.strIngredient
    }
}
