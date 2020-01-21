//
//  HomeProtocol.swift
//  Utterfare
//
//  Created by Connor Meehan on 7/11/19.
//  Copyright © 2019 Utterfare. All rights reserved.
//

import Foundation

protocol HomeItemsProtocol{
    func downloadHomeItems(itemIds: NSArray, itemNames: NSArray, itemImages: NSArray)
}

class HomeItems: NSObject{
    var delegate: HomeItemsProtocol!
    //let requestUrl = URL(string: "https://www.utterfare.com/includes/php/search.php")
    let requestUrl = URL(string: "http://localhost/utterfare/includes/php/search.php")
    
    func getHomeItems(address: String, numberOfItems: String, page: String){
        var request = URLRequest(url: requestUrl!)
        request.httpMethod = "POST"
        
        var parameters = "action=getMobileHomeFeedItems"
        parameters += "&location=" + address
        parameters += "&num_items=" + numberOfItems
        parameters += "&page=" + page
                
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, reponse, error in
            if error != nil {
                return
            }
            self.parseJson(data: data!)
        }
        task.resume()
    }
    
    
    func parseJson(data: Data){

        do{
            let results = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray

            if results.count > 0 {
                
                let itemIds: NSMutableArray = NSMutableArray()
                let itemNames: NSMutableArray = NSMutableArray()
                let itemImageUrls: NSMutableArray = NSMutableArray()
                
                for i in 0..<(results.count){
                    let result = results[i] as! NSDictionary
                    
                    itemIds.add(result["item_id"] as! String)
                    itemNames.add(result["item_name"] as! String)
                    itemImageUrls.add(result["primary_image"] as? String ?? "https://www.utterfare.com/favicon.ico")
                    
                }
                          
                DispatchQueue.main.async{
                    self.delegate.downloadHomeItems(itemIds: itemIds, itemNames: itemNames, itemImages: itemImageUrls)
                }

            }else{
                DispatchQueue.main.async{
                    self.delegate.downloadHomeItems(itemIds: NSArray(), itemNames: NSArray(), itemImages: NSArray())
                }
            }
        }catch{
            print("JSON Error: ", error.localizedDescription )
        }
    }
}



