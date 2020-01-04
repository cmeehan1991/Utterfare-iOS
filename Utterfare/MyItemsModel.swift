//
//  MyItemsModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/30/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation

protocol GetItemsProtocol: class{
    func getItemsProtocol(hasItems: Bool, userItemsId: Array<String>, itemsId: Array<String>, itemsName: Array<String>, itemsShortDescription: Array<String>, itemsImage: Array<String>, itemsVendorName: Array<String>)
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
    let requestUrl = URL(string: "https://www.utterfare.com/includes/php/UsersItems.php")

    /*
    * Add an item to the user's saved items
    */
    func addItem(userId: String, itemId: String){
        var request: URLRequest = URLRequest(url: requestUrl!)
        request.httpMethod = "post"
        
        var parameters = "action=" + "add_item"
        parameters += "&user_id=" + userId
        parameters += "&item_id=" + itemId
        
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
    func removeItem(userId: String, itemId: String, userItemId: String){
        var request: URLRequest = URLRequest(url: requestUrl!)
        request.httpMethod = "post"
        
        var parameters = "action=" + "remove_item"
        parameters += "&user_id=" + userId
        parameters += "&item_id=" + itemId
        parameters += "&user_item_id=" + userItemId
                
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
        let str = String(data: data, encoding: .utf8)
        print(str)
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSArray
            if let results = jsonResponse{
                var userItemsId: Array<String> = Array()
                var itemsId: Array<String> = Array()
                var itemsName: Array<String> = Array()
                var itemsShortDescription: Array<String> = Array()
                var itemsImage: Array<String> = Array()
                var itemsVendorName: Array<String> = Array()
                
                for i in 0..<(results.count){
                    let item = results[i] as! NSDictionary
                    
                    userItemsId.append(item["user_item_id"] as! String)
                    itemsId.append(item["item_id"] as! String)
                    itemsName.append(item["item_name"] as! String)
                    itemsShortDescription.append(item["item_short_description"] as! String)
                    itemsImage.append(item["primary_image"] as! String)
                    itemsVendorName.append(item["vendor_name"] as! String)
                }
                DispatchQueue.main.async {
                    self.delegateGetItems.getItemsProtocol(hasItems: results.count > 0, userItemsId: userItemsId, itemsId: itemsId, itemsName: itemsName, itemsShortDescription: itemsShortDescription, itemsImage: itemsImage, itemsVendorName: itemsVendorName)
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
        let str = String(data: data, encoding: .utf8)
        print(str)
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
