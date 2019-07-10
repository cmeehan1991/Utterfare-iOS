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
    func itemsDownloaded(hasResults: Bool, itemIds: Array<String>, dataTables: Array<String>, itemNames: Array<String>, restaurantNames: Array<String>, restaurantIds: Array<String>, itemImages: Array<String>)
}

class SearchModel: NSObject{
    weak var delegate: SearchControllerProtocol!
    var location : String = String(), terms : String = String(), offset : String = String(), distance : String = String()
    var jsonData : Data = Data()
    
    func doSearch(terms: String, distance: String, location: String, offset: String){
        let requestURL = URL(string: "https://www.utterfare.com/includes/php/ios-search.php")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        
        var parameters = "terms=" + terms
        parameters += "&distance=" + distance
        parameters += "&location=" + location
        parameters += "&offset=" + offset
        
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
            print(jsonResults)
            var haveResults: Bool = Bool()
            if jsonResults == nil {
                haveResults = false;
                return
            }else{
                haveResults = true;
            }
            if let results = jsonResults {
                var itemId : Array<String> = Array()
                var dataTable : Array<String> = Array()
                var itemImage : Array<String> = Array()
                var itemName : Array<String> = Array()
                var restaurantName : Array<String> = Array()
                var restaurantId : Array<String> = Array()
                
                for i in 0..<(results.count){
                    let result = results[i] as! NSDictionary
                    
                    itemId.append(result["ITEM_ID"] as! String)
                    dataTable.append(result["DATA_TABLE"] as! String)
                    itemImage.append(result["IMAGE_URL"] as! String)
                    itemName.append(result["NAME"] as! String)
                    restaurantName.append(result["COMPANY"] as! String)
                    restaurantId.append(result["COMPANY_ID"] as! String)
                }
                
                DispatchQueue.main.async {
                    if self.delegate != nil{
                        self.delegate.itemsDownloaded(hasResults: haveResults, itemIds: itemId, dataTables: dataTable, itemNames: itemName, restaurantNames: restaurantName, restaurantIds: restaurantId, itemImages: itemImage)
                    }
                }
            }
        }catch{
            DispatchQueue.main.async{
                self.delegate.itemsDownloaded(hasResults: false, itemIds: Array(), dataTables: Array(), itemNames: Array(), restaurantNames: Array(), restaurantIds: Array(), itemImages: Array())
            }
        }
        
    }
    
    
}
