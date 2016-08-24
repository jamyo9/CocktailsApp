//
//  Cocktail+CoreDataProperties.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 12/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Cocktail {

    @NSManaged var idDrink: NSNumber?
    @NSManaged var strDrinkThumb: String?
    @NSManaged var drinkThumb: NSData?
    @NSManaged var strDrink: String?
    @NSManaged var strCategory: String?
    @NSManaged var strAlcoholic: String?
    @NSManaged var strGlass: String?
    @NSManaged var strInstructions: String?
    
    @NSManaged var ingredients: NSSet?
    @NSManaged var measures: NSSet?

}
