//
//  CocktailsConstants.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 12/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation

extension CocktailsAPI {
    
    struct Constants {
        
        // MARK: API Keys
        static let ParseApiKey : String = ""
        static let ParseAppID : String = ""
        
        // MARK: URLs
        static let baseURL : String = "https://www.thecocktaildb.com/api/"
        static let parseType : String = "json"
        static let apiVersion : String = "1"
        
        
        // MARK: Methods
        
        /* Udacity methods */
        static let searchMethod : String = "search.php"
        static let searchOption : String = "s"
        
        static let lookupMethod : String = "lookup.php"
        static let lookupOption : String = "i"
        
        static let randomMethod : String = "random.php"
        
        static let filterMethod : String = "filter.php"
        static let ingredientOption : String = "i"
        static let typeOption : String = "a"
        static let typeAlcocholValue : String = "Alcoholic"
        static let typeNoAlcocholValue : String = "Non_Alcoholic"
        static let categoryOption : String = "c"
        static let glassDrinkOption : String = "g"
        
        static let listMethod : String = "list.php"
        
}


//    Search cocktail by name
//    http://www.thecocktaildb.com/api/json/v1/1/search.php?s=margarita
//
//    Lookup full cocktail details by id
//    http://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=15112
//
//    Lookup a random cocktail
//    http://www.thecocktaildb.com/api/json/v1/1/random.php
//
//    Search by ingredient
//    http://www.thecocktaildb.com/api/json/v1/1/filter.php?i=Gin
//    http://www.thecocktaildb.com/api/json/v1/1/filter.php?i=Vodka
//
//    Search by alcoholic?
//    http://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic
//    http://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Non_Alcoholic
//
//    Filter by Category
//    http://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Ordinary_Drink
//    http://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocktail
//
//    Filter by Glass
//    http://www.thecocktaildb.com/api/json/v1/1/filter.php?g=Cocktail_glass
//    http://www.thecocktaildb.com/api/json/v1/1/filter.php?g=Champagne_flute
//
//    List the categories, glasses, ingredients or alcoholic filters
//    http://www.thecocktaildb.com/api/json/v1/1/list.php?c=list
//    http://www.thecocktaildb.com/api/json/v1/1/list.php?g=list
//    http://www.thecocktaildb.com/api/json/v1/1/list.php?i=list
//    http://www.thecocktaildb.com/api/json/v1/1/list.php?a=list

}