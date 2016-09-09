//
//  CocktailDetailViewController.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 22/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import CoreData

class CocktailDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cocktailImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var detailDescriptionLabel: UITextView!
    
    var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.context
    }
    
    var cocktail: Cocktail?
    var cocktailDictionary: [String: AnyObject]?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.cocktail == nil {
            let idDrink = NSNumber(int:Int32(cocktailDictionary!["idDrink"] as! String)!)
            self.activityIndicator.startAnimating()
                    
            CocktailsAPI.sharedInstance().getCocktailById(idDrink) { success, arrayOfCocktailDictionary, errorString in
                if errorString == nil {
                    if let cocktailDictionary = arrayOfCocktailDictionary![0] as? [String: AnyObject] {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.configureView(cocktailDictionary)
                        }
                    } else {
                        // Server responded with success, but a nil array. Do not update local positions.
                        self.showError("", errorMessage: "Cocktail data returned a nil")
                    }
                } else {
                    self.showError("", errorMessage: "Error Getting Cocktail")
                }
            }
        } else {
            if !(self.cocktail!.isCompleted()) {
                
                self.activityIndicator.startAnimating()
                
                CocktailsAPI.sharedInstance().getCocktailById((self.cocktail!.idDrink)!) { success, arrayOfCocktailDictionary, errorString in
                    if errorString == nil {
                        if let cocktailDictionary = arrayOfCocktailDictionary![0] as? [String: AnyObject] {                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.configureView(cocktailDictionary)
                            }
                        } else {
                            // Server responded with success, but a nil array. Do not update local positions.
                            self.showError("", errorMessage: "Cocktail data returned a nil")
                        }
                    } else {
                        self.showError("", errorMessage: "Error Getting Cocktail")
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.configureView()
                }
            }
        }
    }
    
    func favoriteAction(sender: AnyObject) {
        if self.cocktail == nil {
            self.cocktail = CocktailList.sharedInstance().parseCocktail(self.cocktailDictionary!, isFavorite: true)
        } else {
            self.context.deleteObject(self.cocktail!)
            CoreDataStack.sharedInstance.saveContext()
        }
        
        configFavoriteCocktailButton()
    }
}

extension CocktailDetailViewController {
    
    func configureView() {
        if let detailCocktail = cocktail {
            if let titleLabel = titleLabel, cocktailImageView = cocktailImageView, detailDescriptionLabel = detailDescriptionLabel, activityIndicator = activityIndicator {
                titleLabel.text = detailCocktail.strDrink
                titleLabel.font = UIFont.boldSystemFontOfSize(20.0)
                
                if (detailCocktail.drinkThumb == nil ) {
                    if (detailCocktail.strDrinkThumb != nil) {
                        CocktailsAPI.sharedInstance().taskForImageDownload(detailCocktail.strDrinkThumb!) { imageData, error in
                            if let data = imageData {
                                    detailCocktail.drinkThumb = data
                                dispatch_async(dispatch_get_main_queue()) {
                                    cocktailImageView.image = UIImage(data: data)
                                    activityIndicator.stopAnimating()
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue()) {
                                    activityIndicator.stopAnimating()
                                    cocktailImageView.image = UIImage(named: "no-image")
                                }
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            activityIndicator.stopAnimating()
                            cocktailImageView.image = UIImage(named: "no-image")
                        }
                    }
                } else {
                    cocktailImageView.image = UIImage(data: detailCocktail.drinkThumb!)
                    dispatch_async(dispatch_get_main_queue()) {
                        activityIndicator.stopAnimating()
                    }
                }
                detailDescriptionLabel.text = self.createDescription()
            }
        }
        
        configFavoriteCocktailButton()
    }
    
    func configureView(cocktailDictionary: [String: AnyObject]) {
            if let titleLabel = titleLabel, cocktailImageView = cocktailImageView, detailDescriptionLabel = detailDescriptionLabel, activityIndicator = activityIndicator {
                
                let strDrinkThumb = cocktailDictionary["strDrinkThumb"] as? String
                let strDrink = cocktailDictionary["strDrink"] as? String

                
                titleLabel.text = strDrink
                titleLabel.font = UIFont.boldSystemFontOfSize(20.0)
                
                if (strDrinkThumb != nil) {
                    CocktailsAPI.sharedInstance().taskForImageDownload(strDrinkThumb!) { imageData, error in
                        if let data = imageData {
                            dispatch_async(dispatch_get_main_queue()) {
                                cocktailImageView.image = UIImage(data: data)
                                activityIndicator.stopAnimating()
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                activityIndicator.stopAnimating()
                                cocktailImageView.image = UIImage(named: "no-image")
                            }
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        activityIndicator.stopAnimating()
                        cocktailImageView.image = UIImage(named: "no-image")
                    }
                }
            detailDescriptionLabel.text = createDescription(cocktailDictionary)
        }
        
        let idDrink = NSNumber(int:Int32(cocktailDictionary["idDrink"] as! String)!)
        let cocktails = CoreDataStack.sharedInstance.getCocktailsById(idDrink)
        if cocktails.count > 0 {
            self.cocktail = cocktails[0]
        }
        self.configFavoriteCocktailButton()
    }
    
    func configFavoriteCocktailButton() {
        if(self.cocktail?.isFavorite == true) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(CocktailDetailViewController.favoriteAction(_:)))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(CocktailDetailViewController.favoriteAction(_:)))
        }
    }
    
    func createDescription() -> String {
        var description: String = ""
        
        description += "Category: " + (self.cocktail?.strCategory)!
        description += "\nType of Glass: " + (self.cocktail?.strGlass)!
        description += "\nAlcochol: " + (self.cocktail?.strAlcoholic)!
        
        description += "\nInstructions: \n\n"
        description += (self.cocktail?.strInstructions)!
        description += "\n\n"
        description += "Ingredients:"
        description += "\n"
        for ingredient in (self.cocktail?.ingredients)! {
            let strIngredient = (ingredient as! Ingredient).strIngredient
            if strIngredient != "" {
                description += " ⋅ " + strIngredient! + "\n"
            }
        }
        
        description += "\nMeasures:"
        description += "\n"
        for measure in (self.cocktail?.measures)! {
            let strMeasure = (measure as! Measure).strMeasure
            if strMeasure != "" {
                description += " ⋅ " + strMeasure! + "\n"
            }
        }
        return description
    }
    
    func createDescription(cocktailDictionary: [String: AnyObject]) -> String {
        let strCategory = cocktailDictionary["strCategory"] as? String
        let strAlcoholic = cocktailDictionary["strAlcoholic"] as? String
        let strGlass = cocktailDictionary["strGlass"] as? String
        let strInstructions = cocktailDictionary["strInstructions"] as? String
        
        var ingredients = [String]()
        var measures = [String]()
        
        for index in 1...15 {
            let ingredientStr = (cocktailDictionary["strIngredient" + String(index)] as? String)!
            if ingredientStr != "" && ingredientStr != " " {
                ingredients.append(ingredientStr)
            }
            
            let measureStr = (cocktailDictionary["strMeasure" + String(index)] as? String)!
            if measureStr != "" && measureStr != " " {
                measures.append(measureStr)
            }
        }
        
        var description: String = ""
        
        description += "Category: " + strCategory!
        description += "\nType of Glass: " + strGlass!
        description += "\nAlcochol: " + strAlcoholic!
        
        description += "\nInstructions: \n\n"
        description += (strInstructions)!
        description += "\n\n"
        description += "Ingredients:"
        description += "\n"
        for strIngredient in ingredients {
            if strIngredient != "" {
                description += " ⋅ " + strIngredient + "\n"
            }
        }
        
        description += "\nMeasures:"
        description += "\n"
        for strMeasure in measures {
            if strMeasure != "" {
                description += " ⋅ " + strMeasure + "\n"
            }
        }
        return description
    }
    
    func showError(errorCode: String, errorMessage: String?){
        let titleString = "Error"
        var errorString = ""
        errorString = errorMessage!
        showAlert(titleString, alertMessage: errorString, actionTitle: "Cancel")
    }
    
    //Function that configures and shows an alert
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: actionTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        /* Present the alert view */
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}