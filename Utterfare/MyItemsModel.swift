//
//  MyItemsModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/30/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation

protocol GetItemsProtocol: class{
    func getItemsProtocol(hasItems: Bool, itemIds: Array<String>, dataTabes: Array<String>, itemNames: Array<String>, itemImages: Array<String>)
}

protocol RemoveItemsProtocol: class{
    func removeItemsProtocol(status: Bool, response: String)
}

protocol AddItemProtocol: class{
    func addItemProtocol(status: Bool, response: String)
}

class MyItemsModel: NSObject{
    weak var delegateGetItems: GetItemsProtocol!
    weak var delegateRemoveItem: RemoveItemsProtocol!
    weak var delegateAddItem: AddItemProtocol!
    let requestUrl = URL(string: "https://www.utterfare.com/includes/mobile/items/UserItems.php")

    /*
    * Add an item to the user's saved items
    */
    func addItem(userId: String, itemId: String, itemName: String, dataTable: String, itemImageUrl: String){
        var request: URLRequest = URLRequest(url: requestUrl!)
        request.httpMethod = "post"
        
        var parameters = "action=" + "add_item"
        parameters += "&user_id=" + userId
        parameters += "&item_id=" + itemId
        parameters += "&item_name=" + itemName
        parameters += "&data_table=" + dataTable
        parameters += "&item_image_url=" + itemImageUrl
        
        print(parameters)
        
        print(parameters)
        
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            if error != nil{
                print("Task Error: \(String(describing: error?.localizedDescription))")
                return
            }
            self.parseAddItem(data: data!)
        }
        task.resume()
    }
    
    /*
    * Get the user's saved items
    */
    func getItems(userId: String){
        var urlRequest: URLRequest = URLRequest(url: requestUrl!)
        urlRequest.httpMethod = "post"
        
        var parameters = "action=" + "get_items"
        parameters += "&user_id=" + userId
        
        print(parameters)
        
        urlRequest.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: urlRequest){
            data, response, error in
            if error != nil{
                print("Task Error \(String(describing: error?.localizedDescription))")
                return
            }
            self.parseGetItems(data: data!)
        }
        task.resume()
    }
    
    /*
    * Remove the selected item
    */
    func removeItem(userId: String, itemId: String, dataTable: String){
        var request: URLRequest = URLRequest(url: requestUrl!)
        request.httpMethod = "post"
        
        var parameters = "action=" + "remove_item"
        parameters += "&user_id=" + userId
        parameters += "&item_id=" + itemId
        parameters += "&data_table=" + dataTable
        
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            if error != nil{
                print("Task Error: \(String(describing: error?.localizedDescription))")
                return
            }
            self.parseRemoveItem(data: data!)
        }
        task.resume()
    }
    
    /*
    * Handle the response from the server when adding an item to the user's favorites
    */
    func parseAddItem(data: Data){
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            DispatchQueue.main.async {
                self.delegateAddItem.addItemProtocol(status: jsonResponse["STATUS"] as! Bool, response: jsonResponse["RESPONSE"] as! String)
            }
        }catch{
            print("JSON Error \(error.localizedDescription)")
        }
    }
    
    /*
    * Parse the data returned from the requested user's items
    */
    private func parseGetItems(data: Data){
        print(String.init(data: data, encoding: .utf8))
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSArray
            if let results = jsonResponse{
                var itemIds: Array<String> = Array()
                var dataTables: Array<String> = Array()
                var itemNames: Array<String> = Array()
                var itemImages: Array<String> = Array()
                for i in 0..<(results.count){
                    let item = results[i] as! NSDictionary

                    itemIds.append(item["ITEM_ID"] as! String)
                    dataTables.append(item["ITEM_DATA_TABLE"] as! String)
                    itemNames.append(item["ITEM_NAME"] as! String)
                    itemImages.append(item["ITEM_IMAGE_URL"] as! String)
                }
                DispatchQueue.main.async {
                    self.delegateGetItems.getItemsProtocol(hasItems: results.count > 0, itemIds: itemIds, dataTabes: dataTables, itemNames: itemNames, itemImages: itemImages)
                }
            }
        }catch{
            print("JSON Error: \(error.localizedDescription)")
        }
    }
    
    /*
    * Parse the response after removing the item
    */
    private func parseRemoveItem(data: Data){
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            
            let status = jsonResponse["STATUS"] as! Bool
            let response = jsonResponse["RESPONSE"] as! String
            DispatchQueue.main.async {
                self.delegateRemoveItem.removeItemsProtocol(status: status, response: response)
            }
        }catch{
            DispatchQueue.main.async {
                self.delegateRemoveItem.removeItemsProtocol(status: false, response: error.localizedDescription)
            }
            print("JSON Error: \(error.localizedDescription)")
        }
    }
}
