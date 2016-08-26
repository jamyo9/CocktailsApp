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
        super.init(entity: entity, insertIntoManagedObjectContext: nil)
    }
    
    init(cocktail: Cocktail, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Cocktail", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.idDrink = cocktail.idDrink
        self.strDrinkThumb = cocktail.strDrinkThumb
        self.strDrink = cocktail.strDrink
        self.strCategory = cocktail.strCategory
        self.strAlcoholic = cocktail.strAlcoholic
        self.strGlass = cocktail.strGlass
        self.strInstructions = cocktail.strInstructions
        
//        self.ingredients = cocktail.ingredients
//        self.measures = cocktail.measures
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Cocktail", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: nil)
        self.idDrink = NSNumber(int:Int32(dictionary[Keys.ID] as! String)!)
        self.strDrinkThumb = dictionary[Keys.DrinkThumb] as? String
        self.strDrink = dictionary[Keys.Drink] as? String
        self.strCategory = dictionary[Keys.Category] as? String
        self.strAlcoholic = dictionary[Keys.Alcoholic] as? String
        self.strGlass = dictionary[Keys.Glass] as? String
        self.strInstructions = dictionary[Keys.Instructions] as? String
    }
    
    init(idDrink: Int, strDrinkThumb: String, drinkThumb: NSData, strDrink: String, strCategory: String, strAlcoholic: String, strGlass: String, strInstructions: String, context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entityForName("Cocktail", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: nil)
        
        self.idDrink = idDrink as NSNumber
        self.strDrinkThumb = strDrinkThumb as String
        self.drinkThumb = drinkThumb as NSData
        self.strDrink = strDrink as String
        self.strCategory = strCategory as String
        self.strAlcoholic = strAlcoholic as String
        self.strGlass = strGlass as String
        self.strInstructions = strInstructions as String
        
        self.ingredients = nil
        self.measures = nil
    }
    
    init(idDrink: Int, strDrinkThumb: String, drinkThumb: NSData, strDrink: String, strCategory: String, strAlcoholic: String, strGlass: String, strInstructions: String, ingredients: Set<Ingredient>, measures: Set<Measure>, context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entityForName("Cocktail", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: nil)
        
        self.idDrink = idDrink as NSNumber
        self.strDrinkThumb = strDrinkThumb as String
        self.drinkThumb = drinkThumb as NSData
        self.strDrink = strDrink as String
        self.strCategory = strCategory as String
        self.strAlcoholic = strAlcoholic as String
        self.strGlass = strGlass as String
        self.strInstructions = strInstructions as String
        
        self.ingredients = ingredients
        self.measures = measures
    }
    
//    override func prepareForDeletion() {
//        super.prepareForDeletion()
//        ImageCache.sharedInstance.deleteImage(idDrink!)
//    }
    
    func hasIngredients() -> Bool {
        return ingredients!.count != 0
    }
    
    func hasMeasures() -> Bool {
        return measures!.count != 0
    }
    
}
