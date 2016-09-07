//
//  CoctailsAPI.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 12/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import Foundation

class CocktailsAPI {
    
    /* Shared session */
    var session: NSURLSession
    
    // MARK: - Shared Instance
    
    /* Instantiate a single instance of the CoctailsAPI. */
    class func sharedInstance() -> CocktailsAPI {
        
        struct Singleton {
            static var sharedInstance = CocktailsAPI()
        }
        
        return Singleton.sharedInstance
    }
    
    /* default initializer */
    init() {
        session = NSURLSession.sharedSession()
    }
    
    func getCocktailsByName(cocktailName: String, completionHandler: (success: Bool, arrayOfCocktailDictionaies: [AnyObject]?, errorString: String?) -> Void) {
        
        let baseURL = CocktailsAPI.Constants.baseURL + CocktailsAPI.Constants.parseType + "/v" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.searchMethod + "?" + CocktailsAPI.Constants.searchOption + "=" + cocktailName
        
        taskForGETMethod(baseURL) { JSONResult, error in
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(success: false, arrayOfCocktailDictionaies: nil, errorString: error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                if let arrayOfCocktailDicts = JSONResult.valueForKey("drinks") as? [AnyObject] {
                    completionHandler(success: true, arrayOfCocktailDictionaies: arrayOfCocktailDicts, errorString: nil)
                } else {
                    completionHandler(success: false, arrayOfCocktailDictionaies: nil, errorString: "No results from server.")
                }
            }
        }
    }
    
    func getCocktailsByCategory(cocktailCategory: String, completionHandler: (success: Bool, arrayOfCocktailDictionaies: [AnyObject]?, errorString: String?) -> Void) {
        
        let baseURL = CocktailsAPI.Constants.baseURL + CocktailsAPI.Constants.parseType + "/v" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.filterMethod + "?" + CocktailsAPI.Constants.categoryOption + "=" + cocktailCategory
        
        taskForGETMethod(baseURL) { JSONResult, error in
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(success: false, arrayOfCocktailDictionaies: nil, errorString: error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                if let arrayOfCocktailDicts = JSONResult.valueForKey("drinks") as? [AnyObject] {
                    completionHandler(success: true, arrayOfCocktailDictionaies: arrayOfCocktailDicts, errorString: nil)
                } else {
                    completionHandler(success: false, arrayOfCocktailDictionaies: nil, errorString: "No results from server.")
                }
            }
        }
    }
    
    func getCocktailCategories(completionHandler: (success: Bool, arrayOfCategoriesDictionary: [AnyObject]?, errorString: String?) -> Void) {
        let baseURL = CocktailsAPI.Constants.baseURL + CocktailsAPI.Constants.parseType + "/v" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.listMethod + "?" + CocktailsAPI.Constants.categoryOption + "=" + CocktailsAPI.Constants.listValue
        
        taskForGETMethod(baseURL) { JSONResult, error in
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(success: false, arrayOfCategoriesDictionary: nil, errorString: error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                if let arrayOfCategoriesDicts = JSONResult.valueForKey("drinks") as? [AnyObject] {
                    completionHandler(success: true, arrayOfCategoriesDictionary: arrayOfCategoriesDicts, errorString: nil)
                } else {
                    completionHandler(success: false, arrayOfCategoriesDictionary: nil, errorString: "No results from server.")
                }
            }
        }
    }
    
    func getCocktailById(idDrink: NSNumber, completionHandler: (success: Bool, arrayOfCocktailDictionary: [AnyObject]?, errorString: String?) -> Void) {
        
        let baseURL = CocktailsAPI.Constants.baseURL + CocktailsAPI.Constants.parseType + "/v" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.lookupMethod + "?" + CocktailsAPI.Constants.lookupOption + "=" + String(idDrink)
        
        taskForGETMethod(baseURL) { JSONResult, error in
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(success: false, arrayOfCocktailDictionary: nil, errorString: error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                if let arrayOfCocktailDicts = JSONResult.valueForKey("drinks") as? [AnyObject] {
                    completionHandler(success: true, arrayOfCocktailDictionary: arrayOfCocktailDicts, errorString: nil)
                } else {
                    completionHandler(success: false, arrayOfCocktailDictionary: nil, errorString: "No results from server.")
                }
            }
        }
    }
    
    func taskForImageDownload(photoURL: String, completionHandler: (imageData: NSData?, errorString: String?) -> Void) {
        let photoURL = photoURL.stringByReplacingOccurrencesOfString("http:", withString: "https:")
        taskForGetMethod(photoURL) { (data, error) in
            if let _ = error {
                completionHandler(imageData: nil, errorString: "Failed to download photo with url \(photoURL)")
            } else {
                completionHandler(imageData: data, errorString: nil)
            }
        }
    }
    
    func taskForGETMethod(baseUrl: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let url = NSURL(string: baseUrl.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        let request = NSMutableURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                let newError = CocktailsAPI.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                // success
                let returnData = data
                CocktailsAPI.parseJSONWithCompletionHandler(returnData!, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
    
    func taskForGetMethod(urlString: String/*, queryParameters: [String: AnyObject]?*/, completionHandler:(data: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask{
        
        //build and configure Get request
        //let urlString = urlString + escapedParameters(queryParameters!)
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        //make the request
        let task = session.dataTaskWithRequest(request){ (data, response, error) in
            
            if self.isSuccess(data, response: response, error: error, completionHandler: completionHandler) {
                completionHandler(data: data, error: nil)
            }
        }
        
        //start the request
        task.resume()
        
        return task
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    func isSuccess(data: NSData?, response: NSURLResponse?, error: NSError?, completionHandler: (data: NSData?, error: NSError?) -> Void) -> Bool {
        
        guard error == nil else {
            NSLog("There was an error with your request: \(error)")
            completionHandler(data: nil, error: error)
            return false
        }
        
        guard let data = data else {
            let errorMessage = "No data was returned by the request!"
            NSLog(errorMessage)
            let userInfo = [NSLocalizedDescriptionKey : errorMessage]
            completionHandler(data: nil, error: NSError(domain: "isSuccess", code: 1, userInfo: userInfo))
            return false
        }
        
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            var errorMessage : String
            if let response = response as? NSHTTPURLResponse {
                errorMessage = "Your request returned an invalid response! Status code \(response.statusCode)!"
            } else if let response = response {
                errorMessage = "Your request returned an invalid response! Response \(response)!"
            } else {
                errorMessage = "Your request returned an invalid response!"
            }
            
            NSLog(errorMessage)
            let userInfo = [NSLocalizedDescriptionKey : errorMessage]
            completionHandler(data: data, error: NSError(domain: "isSuccess", code: 1, userInfo: userInfo))
            return false
        }
        
        return true
    }
}