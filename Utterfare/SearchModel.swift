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
    func itemsDownloaded(hasResults: Bool, itemsId: Array<String>, itemsNames: Array<String>, restaurantsNames: Array<String>, itemsImages: Array<String>, itemsShortDescription: Array<String>)
}

class SearchModel: NSObject{
    weak var delegate: SearchControllerProtocol!
    var location : String = String(), terms : String = String(), offset : String = String(), distance : String = String()
    var jsonData : Data = Data()
    
    func doSearch(terms: String, distance: String, location: String, offset: String, page: String){
        let requestURL = URL(string: "https://www.utterfare.com/includes/php/search.php")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        
        var parameters = "terms=" + terms
        parameters += "&distance=" + distance
        parameters += "&location=" + location
        parameters += "&offset=" + offset
        parameters += "&page=" + page
        parameters += "&limit=" + "25"
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
                var itemsId : Array<String> = Array()
                var itemsImage : Array<String> = Array()
                var itemsName : Array<String> = Array()
                var restaurantsName : Array<String> = Array()
                var itemsShortDescription : Array<String> = Array()
                
                for i in 0..<(results.count){
                    let result = results[i] as! NSDictionary
                    
                    print(result["item_id"] as! String)
                    
                    itemsId.append(result["item_id"] as! String)
                    itemsImage.append(result["primary_image"] as! String)
                    itemsName.append(result["item_name"] as! String)
                    restaurantsName.append(result["vendor_name"] as! String)
                    itemsShortDescription.append(result["item_short_description"] as! String)
                }
                print(itemsId)
                DispatchQueue.main.async {
                    print(itemsId.count)
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
