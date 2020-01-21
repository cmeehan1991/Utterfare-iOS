//
//  SearchController.swift
//  Utterfare
//
//  Created by Connor Meehan on 1/8/17.
//  Copyright © 2017 CBM Web Development. All rights reserved.
//

import Foundation
import UIKit

protocol SearchControllerProtocol: class{
    func itemsDownloaded(hasResults: Bool, itemsId: NSArray, itemsNames: NSArray, restaurantsNames: NSArray, itemsImages: NSArray, itemsShortDescription: NSArray)
}

class SearchModel: NSObject{
    weak var delegate: SearchControllerProtocol!
    var jsonData : Data = Data()
    
    func doSearch(terms: String, distance: String, location: String, page: String){
        let requestURL = URL(string: "https://www.utterfare.com/includes/php/search.php")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        
        var parameters = "terms=" + terms
        parameters += "&distance=" + distance
        parameters += "&location=" + location
        parameters += "&page=" + page
        parameters += "&limit=" + "10"
        parameters += "&action=search"
            
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            if error != nil{
                return
            }
            self.jsonData = data!
            self.parseJSON();
            
        }
        task.resume()
    }
    
    func parseJSON(){

        do{
            let jsonResults = try JSONSerialization.jsonObject(with: self.jsonData, options: .allowFragments) as? NSArray
            var haveResults: Bool = Bool()
            if jsonResults == nil {
                haveResults = false;
                return
            }else{
                haveResults = true;
            }
            if let results = jsonResults {
                let itemsId : NSMutableArray = NSMutableArray()
                let itemsImage : NSMutableArray = NSMutableArray()
                let itemsName : NSMutableArray = NSMutableArray()
                let restaurantsName : NSMutableArray = NSMutableArray()
                let itemsShortDescription : NSMutableArray = NSMutableArray()
                
                for i in 0..<(results.count){
                    let result = results[i] as! NSDictionary
                                        
                    itemsId.add(result["item_id"] as! String)
                    itemsImage.add(result["primary_image"] as! String)
                    itemsName.add(result["item_name"] as! String)
                    restaurantsName.add(result["vendor_name"] as! String)
                    itemsShortDescription.add(result["item_short_description"] as! String)
                }
                DispatchQueue.main.async {
                    self.delegate.itemsDownloaded(hasResults: haveResults, itemsId: itemsId, itemsNames: itemsName, restaurantsNames: restaurantsName, itemsImages: itemsImage, itemsShortDescription: itemsShortDescription)

                }
            }
        }catch{
            print("JSON Error")
            print(error.localizedDescription)
            
            let str = String(data: self.jsonData, encoding: .utf8)
            print("JSON Data")
            print(str)
        }
        
    }
    
    
}
