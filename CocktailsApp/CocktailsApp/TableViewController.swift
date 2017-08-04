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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = false
        tabBarController?.tabBar.isHidden = false
        
        cocktailsInstance.getCocktailsByName(searchController.searchBar.text!) { success, errorString in
            if success == false {
                //if let errorString = errorString {
                if errorString != nil {
                    DispatchQueue.main.async(execute: {
                        self.showError("", errorMessage: errorString!)
                    })
                }
            } else {
                DispatchQueue.main.async {
                    self.reloadTable()
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.reloadTable), name: NSNotification.Name(rawValue: ""), object: nil)
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
        
        let category = UserDefaults.standard.integer(forKey: "Category")
        let searchText = UserDefaults.standard.string(forKey: "SearchText")
        searchController.searchBar.selectedScopeButtonIndex = category
        searchController.searchBar.text = searchText
        
        DispatchQueue.main.async {
            if category != 0 || searchText != "" {
                self.searchController.searchBar.becomeFirstResponder()
            }
        }
        
        self.searchController.loadViewIfNeeded()
    }
    
    deinit {
        self.searchController.loadViewIfNeeded()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CocktailTableViewCell", for: indexPath) as! CocktailTableCell
        let cocktail = cocktailsInstance.cocktails[(indexPath as NSIndexPath).row]
        
        cell.activityIndicator.startAnimating()
        
        let strDrinkThumb = cocktail["strDrinkThumb"] as? String
        let strDrink = cocktail["strDrink"] as? String
        
        if (strDrinkThumb != nil) {
            CocktailsAPI.sharedInstance().taskForImageDownload(strDrinkThumb!) { imageData, error in
                if let data = imageData {
                    DispatchQueue.main.async {
                        cell.cocktailImage!.image = UIImage(data: data)
                        cell.activityIndicator.stopAnimating()
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.activityIndicator.stopAnimating()
                        cell.cocktailImage.image = UIImage(named: "no-image")
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                cell.activityIndicator.stopAnimating()
                cell.cocktailImage.image = UIImage(named: "no-image")
            }
        }
        cell.textLable.text = strDrink
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cocktailsInstance.cocktails.count
    }
    
    func reloadTable() {
        self.cocktailTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CocktailDetailFromListSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let cocktail = cocktailsInstance.cocktails[(indexPath as NSIndexPath).item]
                let controller = segue.destination as! CocktailDetailViewController
                controller.cocktailDictionary = cocktail
            }
        }
    }
}

extension TableViewController {
    
    func showError(_ errorCode: String, errorMessage: String?){
        let titleString = "Error"
        var errorString = ""
        errorString = errorMessage!
        showAlert(titleString, alertMessage: errorString, actionTitle: "Cancel")
    }
    
    //Function that configures and shows an alert
    func showAlert(_ alertTitle: String, alertMessage: String, actionTitle: String){
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: actionTitle, style: .cancel) { (action) in
            self.cocktailsInstance.cocktails = []
            self.reloadTable()
        }
        alert.addAction(cancelAction)
        
        /* Present the alert view */
        self.present(alert, animated: true, completion: nil)
    }
    
    func filterContentForCategory(_ category: String = "All") {
        var strCategory = ""
        cocktailsInstance.cocktails = cocktailsInstance.cocktails.filter({( cocktail : [String: AnyObject]) -> Bool in
            if cocktail["strCategory"] == nil {
                let idDrink = NSNumber(value: Int32(cocktail["idDrink"] as! String)! as Int32)
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
    
    func filterContentForName(_ searchText: String) {
        var strDrink = ""
        cocktailsInstance.cocktails = cocktailsInstance.cocktails.filter({( cocktail : [String: AnyObject]) -> Bool in
            
            if cocktail["strDrink"] == nil {
                let idDrink = NSNumber(value: Int32(cocktail["idDrink"] as! String)! as Int32)
                CocktailsAPI.sharedInstance().getCocktailById(idDrink) {success, arrayOfCocktailDictionary, errorString in
                    if errorString == nil {
                        strDrink = (arrayOfCocktailDictionary![0] as? [String: AnyObject])!["strDrink"] as! String
                    }
                }
            } else {
                strDrink = cocktail["strDrink"] as! String
            }
            
            return strDrink.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

extension TableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let searchBar = searchController.searchBar
        var category = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        if category == "All" {
            cocktailsInstance.getCocktailsByName(searchBar.text!) { success, errorString in
                if success == false {
                    //if let errorString = errorString {
                    if errorString != nil {
                        DispatchQueue.main.async(execute: {
                            self.showError("", errorMessage: errorString!)
                        })
                    }
                } else {
                    DispatchQueue.main.async {
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
                        DispatchQueue.main.async(execute: {
                            self.showError("", errorMessage: errorString!)
                        })
                    }
                } else {
                    DispatchQueue.main.async {
                        self.reloadTable()
                    }
                }
            }
        }
        self.filterContentForName(self.searchController.searchBar.text!)
        UserDefaults.standard.set(selectedScope, forKey: "Category")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.selectedScopeButtonIndex = 0
        searchBar.text = ""
        
        UserDefaults.standard.set("", forKey: "SearchText")
        UserDefaults.standard.set(0, forKey: "Category")
    }
}

extension TableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let category = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        cocktailsInstance.getCocktailsByName(searchBar.text!) { success, errorString in
            if success == false {
                //if let errorString = errorString {
                if errorString != nil {
                    DispatchQueue.main.async(execute: {
                        self.showError("", errorMessage: errorString!)
                    })
                }
            } else {
                DispatchQueue.main.async {
                    self.reloadTable()
                }
            }
        }
        self.filterContentForCategory(category)
        
        UserDefaults.standard.set(searchController.searchBar.text!, forKey: "SearchText")
    }
}
