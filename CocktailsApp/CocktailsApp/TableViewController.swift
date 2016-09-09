//
//  TableViewController.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 9/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    @IBOutlet weak var cocktailTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let cocktailsInstance = CocktailList.sharedInstance()
    
    var context: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.context
    }
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hidden = false
        tabBarController?.tabBar.hidden = false
        
        cocktailsInstance.getCocktailsByName(searchController.searchBar.text!) { success, errorString in
            if success == false {
                //if let errorString = errorString {
                if errorString != nil {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.showError("", errorMessage: errorString!)
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.reloadTable()
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TableViewController.reloadTable), name: "", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cocktailTableView.delegate = self
        self.cocktailTableView.dataSource = self
        self.cocktailTableView.allowsMultipleSelection = false
        
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "Cocktail", "Shot", "Punch", "Beer", "Shake"]
        tableView.tableHeaderView = searchController.searchBar
        
        let category = NSUserDefaults.standardUserDefaults().integerForKey("Category")
        let searchText = NSUserDefaults.standardUserDefaults().stringForKey("SearchText")
        searchController.searchBar.selectedScopeButtonIndex = category
        searchController.searchBar.text = searchText
        
        dispatch_async(dispatch_get_main_queue()) {
            if category != 0 || searchText != "" {
                self.searchController.searchBar.becomeFirstResponder()
            }
        }
        
        self.searchController.loadViewIfNeeded()
    }
    
    deinit {
        self.searchController.loadViewIfNeeded()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CocktailTableViewCell", forIndexPath: indexPath) as! CocktailTableCell
        let cocktail = cocktailsInstance.cocktails[indexPath.row]
        
        cell.activityIndicator.startAnimating()
        
        let strDrinkThumb = cocktail["strDrinkThumb"] as? String
        let strDrink = cocktail["strDrink"] as? String
        
        if (strDrinkThumb != nil) {
            CocktailsAPI.sharedInstance().taskForImageDownload(strDrinkThumb!) { imageData, error in
                if let data = imageData {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.cocktailImage!.image = UIImage(data: data)
                        cell.activityIndicator.stopAnimating()
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.activityIndicator.stopAnimating()
                        cell.cocktailImage.image = UIImage(named: "no-image")
                    }
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                cell.activityIndicator.stopAnimating()
                cell.cocktailImage.image = UIImage(named: "no-image")
            }
        }
        cell.textLable.text = strDrink
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cocktailsInstance.cocktails.count
    }
    
    func reloadTable() {
        self.cocktailTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CocktailDetailFromListSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let cocktail = cocktailsInstance.cocktails[indexPath.item]
                let controller = segue.destinationViewController as! CocktailDetailViewController
                controller.cocktailDictionary = cocktail
            }
        }
    }
}

extension TableViewController {
    
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
        let cancelAction = UIAlertAction(title: actionTitle, style: .Cancel) { (action) in
            self.cocktailsInstance.cocktails = []
            self.reloadTable()
        }
        alert.addAction(cancelAction)
        
        /* Present the alert view */
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func filterContentForCategory(category: String = "All") {
        var strCategory = ""
        cocktailsInstance.cocktails = cocktailsInstance.cocktails.filter({( cocktail : [String: AnyObject]) -> Bool in
            if cocktail["strCategory"] == nil {
                let idDrink = NSNumber(int:Int32(cocktail["idDrink"] as! String)!)
                CocktailsAPI.sharedInstance().getCocktailById(idDrink) {success, arrayOfCocktailDictionary, errorString in
                    if errorString == nil {
                        strCategory = (arrayOfCocktailDictionary![0] as? [String: AnyObject])!["strCategory"] as! String
                    }
                }
            } else {
                strCategory = cocktail["strCategory"] as! String
            }
            return (category == "All") || (strCategory == category)
        })
        tableView.reloadData()
    }
    
    func filterContentForName(searchText: String) {
        var strDrink = ""
        cocktailsInstance.cocktails = cocktailsInstance.cocktails.filter({( cocktail : [String: AnyObject]) -> Bool in
            
            if cocktail["strDrink"] == nil {
                let idDrink = NSNumber(int:Int32(cocktail["idDrink"] as! String)!)
                CocktailsAPI.sharedInstance().getCocktailById(idDrink) {success, arrayOfCocktailDictionary, errorString in
                    if errorString == nil {
                        strDrink = (arrayOfCocktailDictionary![0] as? [String: AnyObject])!["strDrink"] as! String
                    }
                }
            } else {
                strDrink = cocktail["strDrink"] as! String
            }
            
            return strDrink.lowercaseString.containsString(searchText.lowercaseString)
        })
        tableView.reloadData()
    }
}

extension TableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let searchBar = searchController.searchBar
        var category = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        if category == "All" {
            cocktailsInstance.getCocktailsByName(searchBar.text!) { success, errorString in
                if success == false {
                    //if let errorString = errorString {
                    if errorString != nil {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.showError("", errorMessage: errorString!)
                        })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.reloadTable()
                    }
                }
            }
        } else {
            searchBar.text = ""
            
            if category == "Punch" {
                category = "Punch / Party Drink"
            } else if category == "Shake" {
                category = "Milk / Float / Shake"
            }
            cocktailsInstance.getCocktailsByCategory(category) { success, errorString in
                if success == false {
                    //if let errorString = errorString {
                    if errorString != nil {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.showError("", errorMessage: errorString!)
                        })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.reloadTable()
                    }
                }
            }
        }
        self.filterContentForName(self.searchController.searchBar.text!)
        NSUserDefaults.standardUserDefaults().setInteger(selectedScope, forKey: "Category")
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.selectedScopeButtonIndex = 0
        searchBar.text = ""
        
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "SearchText")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "Category")
    }
}

extension TableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let category = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        cocktailsInstance.getCocktailsByName(searchBar.text!) { success, errorString in
            if success == false {
                //if let errorString = errorString {
                if errorString != nil {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.showError("", errorMessage: errorString!)
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.reloadTable()
                }
            }
        }
        self.filterContentForCategory(category)
        
        NSUserDefaults.standardUserDefaults().setObject(searchController.searchBar.text!, forKey: "SearchText")
    }
}