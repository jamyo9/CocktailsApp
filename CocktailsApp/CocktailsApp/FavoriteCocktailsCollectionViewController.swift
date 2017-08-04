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

class FavoriteCocktailsCollectionViewController: UIViewController {//, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.context
    }
    
    var favoriteCocktails: [Cocktail] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.favoriteCocktails = CoreDataStack.sharedInstance.getFavoriteCocktails()
        
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        
//        fetchedResultsController.delegate = self
//        
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {}
    }
    
//    // MARK: - NSFetchedResultsController
//    lazy var fetchedResultsController: NSFetchedResultsController = {
//        
//        let fetchRequest = NSFetchRequest(entityName: "Cocktail")
//        fetchRequest.sortDescriptors = []
//        fetchRequest.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(bool: true))
//        fetchRequest.returnsObjectsAsFaults   = false
//        
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
//        
//        fetchedResultsController.delegate = self
//        
//        return fetchedResultsController
//    }()
}

extension FavoriteCocktailsCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let sectionInfo = self.fetchedResultsController.sections![section]
//        return sectionInfo.numberOfObjects
        return self.favoriteCocktails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cocktail = fetchedResultsController.objectAtIndexPath(indexPath) as! Cocktail
        let cocktail = favoriteCocktails[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CocktailCellID", for: indexPath) as! CocktailCollectionCell
        
        if (cocktail.drinkThumb == nil ) {
            
            cell.activityIndicator.startAnimating()
            
            if (cocktail.strDrinkThumb != nil && cocktail.strDrinkThumb != "") {
                CocktailsAPI.sharedInstance().taskForImageDownload(cocktail.strDrinkThumb!) { imageData, error in
                    if let data = imageData {
                        cocktail.drinkThumb = data
                        CoreDataStack.sharedInstance.saveContext()
                        DispatchQueue.main.async {
                            cell.photoView!.image = UIImage(data: data)
                            cell.activityIndicator.stopAnimating()
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.activityIndicator.stopAnimating()
                            cell.photoView.image = UIImage(named: "no-image")
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()
                    cell.photoView.image = UIImage(named: "no-image")
                }
            }
        } else {
            cell.photoView!.image = UIImage(data: cocktail.drinkThumb! as Data)
            DispatchQueue.main.async {
                cell.activityIndicator.stopAnimating()
            }
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CocktailDetailFromFavoritesSegue" {
            let detailsVC: CocktailDetailViewController = segue.destination as! CocktailDetailViewController
            let indexPath = self.collectionView.indexPathsForSelectedItems![0]
//            let cocktail = (fetchedResultsController.objectAtIndexPath(indexPath) as! Cocktail)
            let cocktail = self.favoriteCocktails[(indexPath as NSIndexPath).row]
            detailsVC.cocktail = cocktail
        }
    }
}
