//
//  HomeProtocol.swift
//  Utterfare
//
//  Created by Connor Meehan on 7/11/19.
//  Copyright © 2019 Utterfare. All rights reserved.
//

import Foundation

protocol HomeItemsProtocol{
    func downloadTopItems(itemIds: NSArray, itemNames: NSArray, itemImages: NSArray)
    func downloadTopPicks(itemIds: NSArray, itemNames: NSArray, itemImages: NSArray)
    func downloadLocalPicks(itemIds: NSArray, itemNames: NSArray, itemImages: NSArray)
}

class HomeItems: NSObject{
    var delegate: HomeItemsProtocol!
    let requestUrl = URL(string: "https://www.utterfare.com/includes/php/search.php")
    
    func getTopItems(){
        var request = URLRequest(url: requestUrl!)
        request.httpMethod = "POST"
        
        let parameters = "action=get_top_items"
        
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, reponse, error in
            if error != nil {
                return
            }
            self.parseJson(data: data!, section: "topItems")
        }
        task.resume()
    }
    
    func getRecommendations(address: String){
        var request = URLRequest(url: requestUrl!)
        request.httpMethod = "POST"
        
        var parameters = "action=get_recommendations"
        parameters += "&location=" + address
        
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, reponse, error in
            if error != nil {
                return
            }
            self.parseJson(data: data!, section: "topPicks")
        }
        task.resume()
    }
    
    func getLocalItems(address: String){
        var request = URLRequest(url: requestUrl!)
        request.httpMethod = "POST"
        
        var parameters = "action=get_local_items"
        parameters += "&location=" + address
        
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, reponse, error in
            if error != nil {
                return
            }
            self.parseJson(data: data!, section: "localItems")
        }
        task.resume()
    }
    
    func parseJson(data: Data, section: String){

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
                                
                if section == "topPicks" {
                    DispatchQueue.main.async{
                        self.delegate.downloadTopPicks(itemIds: itemIds, itemNames: itemNames, itemImages: itemImageUrls)
                    }
                }
                
                if section == "topItems"{
                    DispatchQueue.main.async{
                        self.delegate.downloadTopItems(itemIds: itemIds, itemNames: itemNames, itemImages: itemImageUrls)
                    }
                }
                
                if section == "localItems"{
                    DispatchQueue.main.async{
                        self.delegate.downloadLocalPicks(itemIds: itemIds, itemNames: itemNames, itemImages: itemImageUrls)
                    }
                }
            }
        }catch{
            print("JSON Error: ", error.localizedDescription )
            let str = String(data: data, encoding: .utf8)
            print(str)
        }
    }
}



