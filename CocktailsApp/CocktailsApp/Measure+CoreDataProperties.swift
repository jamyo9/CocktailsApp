//
//  Measure+CoreDataProperties.swift
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

extension Measure {

    @NSManaged var strMeasure: String?
    
    @NSManaged var cocktail: Cocktail?

}
