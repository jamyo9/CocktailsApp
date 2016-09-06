//
//  CocktailList.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 12/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import CoreData

class CocktailList {
    var cocktails: [Cocktail] = []
    
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
        for cocktail in CoreDataStack.sharedInstance.getFavoriteCocktails() {
            cocktails.append(cocktail)
            print(cocktail.idDrink)
        }
    }
    
    func getCocktailsByName(cocktailName: String, completion: (result: Bool, errorString: String?) -> Void) {
        
        CocktailsAPI.sharedInstance().getCocktailsByName(cocktailName) { success, arrayOfCocktailDictionaies, errorString in
            if errorString == nil {
                if let array = arrayOfCocktailDictionaies as? [[String: AnyObject]] {
                    
                    self.reset()
                    
                    // Update collection of position with the new data from Parse.
                    for cocktailDictionary in array {
                        let idDrink = NSNumber(int:Int32(cocktailDictionary["idDrink"] as! String)!)
                        
                        if !self.findById(idDrink) {
                            self.cocktails.append(self.parseCocktail(cocktailDictionary))
                        }
                    }
                    
                    self.sortList()
                    
                    // Send a notification indicating new position data has been obtained from Parse.
                    NSNotificationCenter.defaultCenter().postNotificationName("cocktailUpdateNotificationKey", object: self)
                    
                    completion(result:true, errorString: nil)
                } else {
                    // Server responded with success, but a nil array. Do not update local positions.
                    print("new cocktail data returned a nil array")
                    completion(result:true, errorString: nil)
                }
            } else {
                print("error getCocktailsByName()")
                completion(result:false, errorString: errorString)
            }
        }
    }
    
    func getCocktailsByCategory(cocktailCategory: String, completion: (result: Bool, errorString: String?) -> Void) {
        
        CocktailsAPI.sharedInstance().getCocktailsByCategory(cocktailCategory) { success, arrayOfCocktailDictionaies, errorString in
            if errorString == nil {
                if let array = arrayOfCocktailDictionaies as? [[String: AnyObject]] {
                    
                    self.reset()
                    
                    // Update collection of position with the new data from Parse.
                    for cocktailDictionary in array {
                        let idDrink = NSNumber(int:Int32(cocktailDictionary["idDrink"] as! String)!)
                        
                        if !self.findById(idDrink) {
                            let cocktail = Cocktail(idDrink: idDrink, strDrink: (cocktailDictionary["strDrink"] as? String)!, strDrinkThumb: cocktailDictionary["strDrinkThumb"]!, context: self.context)
                            self.cocktails.append(cocktail)
                        }
                    }
                    
                    self.sortList()
                    
                    // Send a notification indicating new position data has been obtained from Parse.
                    NSNotificationCenter.defaultCenter().postNotificationName("cocktailUpdateNotificationKey", object: self)
                    
                    completion(result:true, errorString: nil)
                } else {
                    // Server responded with success, but a nil array. Do not update local positions.
                    print("new cocktail data returned a nil array")
                    completion(result:true, errorString: nil)
                }
            } else {
                print("error getCocktailsByCategory()")
                completion(result:false, errorString: errorString)
            }
        }
    }
    
    /* sort list by date */
    func sortList() {
        self.cocktails.sortInPlace {
            $0.strDrink!.compare($1.strDrink!) == NSComparisonResult.OrderedAscending
        }
    }
    
    /* debug helper function */
    func printList() {
        for cocktail in cocktails {
            print("\(cocktail.idDrink)")
        }
    }
    
    func parseCocktail(cocktailDictionary: [String: AnyObject]) -> Cocktail {
        var ingredients = Set<Ingredient>()
        var measures = Set<Measure>()
        
        for index in 1...15 {
            let ingredient = Ingredient(strIngredient: (cocktailDictionary["strIngredient" + String(index)] as? String)!, context: self.context)
            if ingredient.strIngredient != "" && ingredient.strIngredient != " " {
                ingredients.insert(ingredient)
            }
            let measure = Measure(strMeasure: (cocktailDictionary["strMeasure" + String(index)] as? String)!, context: self.context)
            if measure.strMeasure != "" && measure.strMeasure != " " {
                measures.insert(measure)
            }
        }
        
        // create a position object and add it to this object's collection.
        let cocktail = Cocktail(dictionary: cocktailDictionary, context: self.context)
        cocktail.ingredients = ingredients
        cocktail.measures = measures
        return cocktail
    }
    
    func findById(idDrink: NSNumber) -> Bool {
        for cocktail in self.cocktails {
            if cocktail.idDrink == idDrink {
                return true
            }
        }
        return false
    }
}
