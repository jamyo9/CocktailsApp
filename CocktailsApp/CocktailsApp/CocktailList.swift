//
//  CocktailList.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 12/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import CoreData

class CocktailList {
    
    var cocktails: [[String: AnyObject]] = []
    
    var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.context
    }
    
    /* This class is instantiated as a Singleton. This function returns the singleton instance. */
    class func sharedInstance() -> CocktailList {
        
        struct Singleton {
            static var sharedInstance = CocktailList()
        }
        
        return Singleton.sharedInstance
    }
    
    func reset() {
        cocktails.removeAll(keepCapacity: false)
    }
    
    func getCocktailsByName(cocktailName: String, completion: (result: Bool, errorString: String?) -> Void) {
        
        CocktailsAPI.sharedInstance().getCocktailsByName(cocktailName) { success, arrayOfCocktailDictionaies, errorString in
            if errorString == nil {
                self.reset()
                self.cocktails = (arrayOfCocktailDictionaies as? [[String: AnyObject]])!
                completion(result:true, errorString: nil)
            } else {
                NSLog("error getCocktailsByName()")
                completion(result:false, errorString: errorString)
            }
        }
    }
    
    func getCocktailsByCategory(cocktailCategory: String, completion: (result: Bool, errorString: String?) -> Void) {
        
        CocktailsAPI.sharedInstance().getCocktailsByCategory(cocktailCategory) { success, arrayOfCocktailDictionaies, errorString in
            if errorString == nil {
                self.reset()
                self.cocktails = (arrayOfCocktailDictionaies as? [[String: AnyObject]])!
                completion(result:true, errorString: nil)
            } else {
                NSLog("error getCocktailsByCategory()")
                completion(result:false, errorString: errorString)
            }
        }
    }
    
    func parseCocktail(cocktailDictionary: [String: AnyObject], isFavorite: Bool) -> Cocktail {
        var ingredients = Set<Ingredient>()
        var measures = Set<Measure>()
        
        for index in 1...15 {
            let ingredientStr = (cocktailDictionary["strIngredient" + String(index)] as? String)!
            if ingredientStr != "" && ingredientStr != " " {
                let ingredient = Ingredient(strIngredient: ingredientStr, context: self.context)
                ingredients.insert(ingredient)
            }
            
            let measureStr = (cocktailDictionary["strMeasure" + String(index)] as? String)!
            if measureStr != "" && measureStr != " " {
                let measure = Measure(strMeasure: measureStr, context: self.context)
                measures.insert(measure)
            }
        }
        
        // create a position object and add it to this object's collection.
        let cocktail = Cocktail(dictionary: cocktailDictionary, isFavorite: isFavorite, context: self.context)
        cocktail.ingredients = ingredients
        cocktail.measures = measures
        
        CoreDataStack.sharedInstance.saveContext()
        
        return cocktail
    }
}
