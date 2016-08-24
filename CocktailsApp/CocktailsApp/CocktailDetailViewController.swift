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
    @IBOutlet weak var detailDescriptionLabel: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.context
    }
    
    var cocktail: Cocktail? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let detailCocktail = cocktail {
            if let titleLabel = titleLabel, cocktailImageView = cocktailImageView, detailDescriptionLabel = detailDescriptionLabel {
                titleLabel.text = detailCocktail.strDrink
                titleLabel.font = UIFont.boldSystemFontOfSize(20.0)
                if (detailCocktail.drinkThumb != nil) {
                    cocktailImageView.image = UIImage(data: detailCocktail.drinkThumb!)
                }
                detailDescriptionLabel.text = self.createDescription()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func favoriteAction(sender: AnyObject) {
        let actionButton = sender as! UIBarButtonItem
        if actionButton.tag == 0 {
            var cocktail = NSEntityDescription.insertNewObjectForEntityForName("Cocktail", inManagedObjectContext: self.context) as! Cocktail
            cocktail = self.cocktail!
            do {
                try self.context.save()
                actionButton.tag = 1
            } catch {}
            self.saveButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: Selector("favoriteAction"))
        } else if actionButton.tag == 1 {
            self.context.deleteObject(self.cocktail!)
            actionButton.tag = 0
            self.saveButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("favoriteAction"))
        }
    }
}

extension CocktailDetailViewController {
    
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
//        print(description)
        return description
    }
    
}