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
        
        cell.activityIndicator.startAnimating()
        cell.noImageLabel.hidden = true
        
        if (cocktail.drinkThumb == nil ) {
            if (cocktail.strDrinkThumb != nil) {
                CocktailsAPI.sharedInstance().taskForImageDownload(cocktail.strDrinkThumb!) { imageData, error in
                    if let data = imageData {
                        self.context.performBlock {
                            cocktail.drinkThumb = data
                            CoreDataStack.sharedInstance.saveContext()
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.photoView!.image = UIImage(data: data)
                            cell.activityIndicator.stopAnimating()
                            cell.noImageLabel.hidden = true
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.photoView.hidden = true
                            cell.activityIndicator.stopAnimating()
                            cell.noImageLabel.hidden = false
                        }
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.photoView.hidden = true
                    cell.activityIndicator.stopAnimating()
                    cell.noImageLabel.hidden = false
                }
            }
        } else {
            cell.photoView!.image = UIImage(data: cocktail.drinkThumb!)
            dispatch_async(dispatch_get_main_queue()) {
                cell.photoView.hidden = false
                cell.activityIndicator.stopAnimating()
                cell.noImageLabel.hidden = true
            }
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CocktailDetailFromFavoritesSegue" {
            let detailsVC: CocktailDetailViewController = segue.destinationViewController as! CocktailDetailViewController
            let indexPath = self.collectionView.indexPathsForSelectedItems()![0]
            detailsVC.cocktail = (fetchedResultsController.objectAtIndexPath(indexPath) as! Cocktail)
        }
    }
}