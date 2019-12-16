//
//  ExplorerModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 12/12/19.
//  Copyright © 2019 Utterfare. All rights reserved.
//

import Foundation

protocol ExplorerItemsProtocol{
    func downloadExplorerItems(itemIds: NSArray, itemImages: NSArray)
}

class ExplorerItems: NSObject{
    
    var delegate: ExplorerItemsProtocol!
    let requestUrl = URL(string: "https://www.utterfare.com/includes/php/search.php")
    
    func getExplorerItems(currentLocation: String){
        var request = URLRequest(url: requestUrl!)
        request.httpMethod = "POST"
        
        var parameters = "action=getExplorerItems"
        parameters += "&location=" + currentLocation

        request.httpBody = parameters.data(using: .utf8)
                
        let task = URLSession.shared.dataTask(with: request){
            data, reponse, error in
            
            if error != nil{
                print("Task error")
                print(error?.localizedDescription)
                return
            }
            
            self.parseJson(data: data!)
        }
        task.resume()
    }
    
    func parseJson(data: Data){
        do{
            let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
            
            if response.count > 0{
                let itemIds: NSMutableArray = NSMutableArray()
                let itemImages: NSMutableArray = NSMutableArray()
                
                for i in 0..<(response.count){
                    let item = response[i] as! NSDictionary
                    
                    itemIds.add(item["item_id"] as! String)
                    itemImages.add(item["primary_image"] as! String)
                }
                
                DispatchQueue.main.async {
                    self.delegate.downloadExplorerItems(itemIds: itemIds, itemImages: itemImages)
                }
            }
        }catch{
            let str = String(data: data, encoding: .utf8)
            print("JSON Error")
            print(error.localizedDescription)
            
            print("Response")
            print(str)
        }
    }
    
}
