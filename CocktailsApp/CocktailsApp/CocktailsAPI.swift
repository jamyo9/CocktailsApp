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
    var session: URLSession
    
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
        session = URLSession.shared
    }
    
    func getCocktailsByName(_ cocktailName: String, completionHandler: @escaping (_ success: Bool, _ arrayOfCocktailDictionaies: [AnyObject]?, _ errorString: String?) -> Void) {
        
        let baseURL = CocktailsAPI.Constants.baseURL + CocktailsAPI.Constants.parseType + "/v" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.searchMethod + "?" + CocktailsAPI.Constants.searchOption + "=" + cocktailName
        
        taskForGETMethod(baseURL) { JSONResult, error in
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(false, nil, error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                if let arrayOfCocktailDicts = JSONResult?.value(forKey: "drinks") as? [AnyObject] {
                    completionHandler(true, arrayOfCocktailDicts, nil)
                } else {
                    completionHandler(false, nil, "No results from server.")
                }
            }
        }
    }
    
    func getCocktailsByCategory(_ cocktailCategory: String, completionHandler: @escaping (_ success: Bool, _ arrayOfCocktailDictionaies: [AnyObject]?, _ errorString: String?) -> Void) {
        
        let baseURL = CocktailsAPI.Constants.baseURL + CocktailsAPI.Constants.parseType + "/v" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.filterMethod + "?" + CocktailsAPI.Constants.categoryOption + "=" + cocktailCategory
        
        taskForGETMethod(baseURL) { JSONResult, error in
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(false, nil, error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                if let arrayOfCocktailDicts = JSONResult?.value(forKey: "drinks") as? [AnyObject] {
                    completionHandler(true, arrayOfCocktailDicts, nil)
                } else {
                    completionHandler(false, nil, "No results from server.")
                }
            }
        }
    }
    
    func getCocktailCategories(_ completionHandler: @escaping (_ success: Bool, _ arrayOfCategoriesDictionary: [AnyObject]?, _ errorString: String?) -> Void) {
        let baseURL = CocktailsAPI.Constants.baseURL + CocktailsAPI.Constants.parseType + "/v" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.listMethod + "?" + CocktailsAPI.Constants.categoryOption + "=" + CocktailsAPI.Constants.listValue
        
        taskForGETMethod(baseURL) { JSONResult, error in
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(false, nil, error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                if let arrayOfCategoriesDicts = JSONResult?.value(forKey: "drinks") as? [AnyObject] {
                    completionHandler(true, arrayOfCategoriesDicts, nil)
                } else {
                    completionHandler(false, nil, "No results from server.")
                }
            }
        }
    }
    
    func getCocktailById(_ idDrink: NSNumber, completionHandler: @escaping (_ success: Bool, _ arrayOfCocktailDictionary: [AnyObject]?, _ errorString: String?) -> Void) {
        
        let baseURL = CocktailsAPI.Constants.baseURL + CocktailsAPI.Constants.parseType + "/v" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.apiVersion + "/" + CocktailsAPI.Constants.lookupMethod + "?" + CocktailsAPI.Constants.lookupOption + "=" + String(describing: idDrink)
//        let baseURL = "https://192.168.0.102:8080/CocktailsAPI/cocktail/" + String(describing: idDrink)
//        let baseURL = "http://localhost:8080/CocktailsAPI/cocktail/" + String(describing: idDrink)
        print(baseURL)
        taskForGETMethod(baseURL) { JSONResult, error in
            if let error = error {
                // Set error string to localizedDescription in error
                completionHandler(false, nil, error.localizedDescription)
            } else {
                // parse the json response which looks like the following:
                if let arrayOfCocktailDicts = JSONResult?.value(forKey: "drinks") as? [AnyObject] {
                    completionHandler(true, arrayOfCocktailDicts, nil)
                } else {
                    completionHandler(false, nil, "No results from server.")
                }
            }
        }
    }
    
    func taskForImageDownload(_ photoURL: String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void) {
        let photoURL = photoURL.replacingOccurrences(of: "http:", with: "https:")
        taskForGetMethod(photoURL) { (data, error) in
            if let _ = error {
                completionHandler(nil, "Failed to download photo with url \(photoURL)")
            } else {
                completionHandler(data, nil)
            }
        }
    }
    
    func taskForGETMethod(_ baseUrl: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = URL(string: baseUrl.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request)  {data, response, downloadError in
            if let error = downloadError {
                let newError = CocktailsAPI.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                // success
                let returnData = data
                CocktailsAPI.parseJSONWithCompletionHandler(returnData!, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
    
    func taskForGetMethod(_ urlString: String, completionHandler:@escaping (_ data: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        
        //build and configure Get request
        //let urlString = urlString + escapedParameters(queryParameters!)
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        //make the request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if self.isSuccess(data, response: response, error: error as NSError?, completionHandler: completionHandler) {
                completionHandler(data, nil)
            }
        }
        
        //start the request
        task.resume()
        
        return task
    }
    
    func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError) -> NSError {
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        
        let parsedResult: Any?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(nil, error)
        } else {
            completionHandler(parsedResult as AnyObject?, nil)
        }
    }
    
    func isSuccess(_ data: Data?, response: URLResponse?, error: NSError?, completionHandler: (_ data: Data?, _ error: NSError?) -> Void) -> Bool {
        
        guard error == nil else {
            NSLog("There was an error with your request: \(String(describing: error))")
            completionHandler(nil, error)
            return false
        }
        
        guard let data = data else {
            let errorMessage = "No data was returned by the request!"
            NSLog(errorMessage)
            let userInfo = [NSLocalizedDescriptionKey : errorMessage]
            completionHandler(nil, NSError(domain: "isSuccess", code: 1, userInfo: userInfo))
            return false
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            var errorMessage : String
            if let response = response as? HTTPURLResponse {
                errorMessage = "Your request returned an invalid response! Status code \(response.statusCode)!"
            } else if let response = response {
                errorMessage = "Your request returned an invalid response! Response \(response)!"
            } else {
                errorMessage = "Your request returned an invalid response!"
            }
            
            NSLog(errorMessage)
            let userInfo = [NSLocalizedDescriptionKey : errorMessage]
            completionHandler(data, NSError(domain: "isSuccess", code: 1, userInfo: userInfo))
            return false
        }
        
        return true
    }
}
