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
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var detailDescriptionLabel: UITextView!
    
    var cocktailSaved: Bool!
    
    var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.context
    }
    
    var cocktail: Cocktail?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !(cocktail?.isCompleted())! {
            
            self.activityIndicator.startAnimating()
            self.noImageLabel.hidden = true
            
            CocktailsAPI.sharedInstance().getCocktailById((cocktail?.idDrink)!) { success, arrayOfCocktailDictionaies, errorString in
                if errorString == nil {
                    if let cocktailDictionary = arrayOfCocktailDictionaies![0] as? [String: AnyObject] {
                        self.cocktail = CocktailList.sharedInstance().parseCocktail(cocktailDictionary)
                        
                        self.cocktailSaved = CoreDataStack.sharedInstance.cocktailAlreadySaved((self.cocktail?.idDrink)!)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.configureView()
                        }
                    } else {
                        // Server responded with success, but a nil array. Do not update local positions.
                        print("new cocktail data returned a nil array")
                    }
                } else {
                    print("error getCocktailById()")
                }
            }
        } else {
            cocktailSaved = CoreDataStack.sharedInstance.cocktailAlreadySaved((cocktail?.idDrink)!)
            dispatch_async(dispatch_get_main_queue()) {
                self.configureView()
            }
        }
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
    
    func favoriteAction(sender: AnyObject) {
        if cocktailSaved == false {
            CoreDataStack.sharedInstance.saveCocktail(self.cocktail!)
            cocktailSaved = true
        } else {
//            self.context.deleteObject(self.cocktail!)
//            do {
//                try self.context.save()
//            } catch {}
            CoreDataStack.sharedInstance.deleteCocktails((self.cocktail?.idDrink)!)
            cocktailSaved = false
        }
        configFavoriteCocktailButton()
    }
}

extension CocktailDetailViewController {
    
    func configureView() {
        if let detailCocktail = cocktail {
            if let titleLabel = titleLabel, cocktailImageView = cocktailImageView, detailDescriptionLabel = detailDescriptionLabel, activityIndicator = activityIndicator, noImageLabel = noImageLabel {
                titleLabel.text = detailCocktail.strDrink
                titleLabel.font = UIFont.boldSystemFontOfSize(20.0)
                
                if (detailCocktail.drinkThumb == nil ) {
                    if (detailCocktail.strDrinkThumb != nil) {
                        CocktailsAPI.sharedInstance().taskForImageDownload(detailCocktail.strDrinkThumb!) { imageData, error in
                            if let data = imageData {
                                self.context.performBlock {
                                    detailCocktail.drinkThumb = data
                                    CoreDataStack.sharedInstance.saveContext()
                                }
                                dispatch_async(dispatch_get_main_queue()) {
                                    cocktailImageView.image = UIImage(data: data)
                                    activityIndicator.stopAnimating()
                                    noImageLabel.hidden = true
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue()) {
                                    cocktailImageView.hidden = true
                                    activityIndicator.stopAnimating()
                                    noImageLabel.hidden = false
                                }
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            cocktailImageView.hidden = true
                            activityIndicator.stopAnimating()
                            noImageLabel.hidden = false
                        }
                    }
                } else {
                    cocktailImageView.image = UIImage(data: detailCocktail.drinkThumb!)
                    dispatch_async(dispatch_get_main_queue()) {
                        cocktailImageView.hidden = false
                        activityIndicator.stopAnimating()
                        noImageLabel.hidden = true
                    }
                }
                detailDescriptionLabel.text = self.createDescription()
            }
        }
        
        configFavoriteCocktailButton()
    }
    
    func configFavoriteCocktailButton() {
        if(cocktailSaved == true) {
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
}