//
//  Cocktail.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 12/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation
import CoreData


class Cocktail: NSManagedObject {
    
    struct Keys {
        static let ID = "idDrink"
        static let DrinkThumb = "strDrinkThumb"
        static let Drink = "strDrink"
        static let Category = "strCategory"
        static let Alcoholic = "strAlcoholic"
        static let Glass = "strGlass"
        static let Instructions = "strInstructions"
        static let Ingredient = "strIngredient"
        static let Measure = "strMeasure"
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.idDrink = 0
        self.strDrinkThumb = ""
        self.drinkThumb = nil
        self.strDrink = ""
        self.strCategory = ""
        self.strAlcoholic = ""
        self.strGlass = ""
        self.strInstructions = ""
        self.isFavorite = false
    }
    
    convenience init(cocktail: Cocktail, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Cocktail", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.idDrink = cocktail.idDrink
        self.strDrinkThumb = cocktail.strDrinkThumb
        self.strDrink = cocktail.strDrink
        self.strCategory = cocktail.strCategory
        self.strAlcoholic = cocktail.strAlcoholic
        self.strGlass = cocktail.strGlass
        self.strInstructions = cocktail.strInstructions
        
        self.isFavorite = false
        
//        var ingredients = Set<Ingredient>()
//        for ingredient in cocktail.ingredients! {
//            ingredients.insert((ingredient as! Ingredient))
//        }
//        self.ingredients = ingredients
//        
//        var measures = Set<Measure>()
//        for measure in cocktail.measures! {
//            measures.insert(Measure(measure: (measure as! Measure), context: context))
//        }
//        self.measures = measures
    }
    
    convenience init(idDrink: NSNumber, strDrink: String, strDrinkThumb: AnyObject, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Cocktail", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.idDrink = idDrink
        self.strDrink = strDrink
        if strDrinkThumb is NSNull {
            self.strDrinkThumb = ""
        } else {
            self.strDrinkThumb = strDrinkThumb as? String
        }
        self.drinkThumb = nil
        self.strCategory = ""
        self.strAlcoholic = ""
        self.strGlass = ""
        self.strInstructions = ""
        
        self.isFavorite = false
    }
    
    convenience init(dictionary: [String:AnyObject], isFavorite: Bool, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Cocktail", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.idDrink = NSNumber(int:Int32(dictionary[Keys.ID] as! String)!)
        self.strDrinkThumb = dictionary[Keys.DrinkThumb] as? String
        self.strDrink = dictionary[Keys.Drink] as? String
        self.strCategory = dictionary[Keys.Category] as? String
        self.strAlcoholic = dictionary[Keys.Alcoholic] as? String
        self.strGlass = dictionary[Keys.Glass] as? String
        self.strInstructions = dictionary[Keys.Instructions] as? String
        
        self.isFavorite = isFavorite
    }
    
    func hasIngredients() -> Bool {
        return ingredients!.count != 0
    }
    
    func hasMeasures() -> Bool {
        return measures!.count != 0
    }
    
    func isCompleted() -> Bool {
        return hasIngredients() && hasMeasures() && self.idDrink != 0 && self.strDrinkThumb != "" && self.drinkThumb != nil && self.strDrink != "" && self.strCategory != "" && self.strAlcoholic != "" && self.strGlass != "" && self.strInstructions != ""
    }
}
