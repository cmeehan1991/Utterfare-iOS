//
//  ViewItemModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/14/18.
//  Copyright © 2018 CBM Web Development. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

protocol ViewItemControllerProtocol: class{
    func itemsDownloaded(companyName: String, address: String, phone: String, link: String, itemName: String, itemDescription: String, itemImage: String)
}

class ViewItemModel: NSObject{
    weak var delegate: ViewItemControllerProtocol!
    var companyName: String = String(), address: String = String(), phone: String = String(), link: String = String(), itemName: String = String(), itemDescription: String = String(), itemImage: String = String()
    
    func doSearch(itemId: String){
        let requestURL = URL(string: "https://www.utterfare.com/includes/php/search.php")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        
        var parameters = "item_id=" + itemId
        parameters += "&action=getSingleItem"
        
        
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            if error != nil{
                return
            }
            self.parseData(data: data!)
        }
        task.resume()
    }
    
    func parseData(data: Data){
        let str = String(decoding: data, as: UTF8.self)
        print("decoded")
        print(str)
        
        do{
            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary

            let companyName = result!["vendor_name"] as! String
            
            let address = try JSONSerialization.jsonObject(with: Data((result!["address"] as! String).utf8), options: .allowFragments) as? NSDictionary
            
            var fullAddress = address!["_primary_address"] as! String
            
            if address!["_secondary_address"] as? String != ""{
                fullAddress += ", " + String(address!["_secondary_address"] as! String)
            }
            
            fullAddress += ", " + String(address!["_city"] as! String)
            fullAddress += ", " + String(address!["_state"] as! String)
            fullAddress += ", " + String(address!["postal_code"] as! String)
            
            let phone = result!["telephone"] as! String
            let link = "Link"//result["URL"] as! String
            let itemName = result!["item_name"] as! String
            let itemDescription = result!["item_description"] as! String
            let itemImage = result!["primary_image"] as! String
            if self.delegate != nil{
                DispatchQueue.main.async{
                    self.delegate.itemsDownloaded(companyName: companyName, address: fullAddress, phone: phone, link: link, itemName: itemName, itemDescription: itemDescription, itemImage: itemImage)
                }
            }
        }catch{
            print("Error")
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.delegate.itemsDownloaded(companyName: "", address: "", phone: "", link: "", itemName: "", itemDescription: "", itemImage: "")

            }
        }
        
    }
}
