//
//  FavoriteCocktailsCollectionViewController.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 22/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class FavoriteCocktailsCollectionViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.context
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        
        fetchedResultsController.delegate = self
    }
    
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Cocktail")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
}

extension FavoriteCocktailsCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cocktail = fetchedResultsController.objectAtIndexPath(indexPath) as! Cocktail
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CocktailCellID", forIndexPath: indexPath) as! CocktailCollectionCell
        
        if (cocktail.drinkThumb == nil ) {
            
            cell.activityIndicator.startAnimating()
            
            if (cocktail.strDrinkThumb != nil && cocktail.strDrinkThumb != "") {
                CocktailsAPI.sharedInstance().taskForImageDownload(cocktail.strDrinkThumb!) { imageData, error in
                    if let data = imageData {
                        self.context.performBlock {
                            cocktail.drinkThumb = data
                            CoreDataStack.sharedInstance.saveContext()
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.photoView!.image = UIImage(data: data)
                            cell.activityIndicator.stopAnimating()
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.activityIndicator.stopAnimating()
                            cell.photoView.image = UIImage(named: "no-image")                        }
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.activityIndicator.stopAnimating()
                    cell.photoView.image = UIImage(named: "no-image")
                }
            }
        } else {
            cell.photoView!.image = UIImage(data: cocktail.drinkThumb!)
            dispatch_async(dispatch_get_main_queue()) {
                cell.activityIndicator.stopAnimating()
            }
        }

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CocktailDetailFromFavoritesSegue" {
            let detailsVC: CocktailDetailViewController = segue.destinationViewController as! CocktailDetailViewController
            let indexPath = self.collectionView.indexPathsForSelectedItems()![0]
            let cocktail = (fetchedResultsController.objectAtIndexPath(indexPath) as! Cocktail)
            detailsVC.cocktail = cocktail
        }
    }
}