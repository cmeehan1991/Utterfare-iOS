//
//  ViewItemModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/14/18.
//  Copyright © 2018 CBM Web Development. All rights reserved.
//

import Foundation
import UIKit

protocol ViewItemControllerProtocol: class{
    func itemsDownloaded(companyName: String, address: String, phone: String, link: String, itemName: String, itemDescription: String, itemImage: String)
}

class ViewItemModel: NSObject{
    weak var delegate: ViewItemControllerProtocol!
    var companyName: String = String(), address: String = String(), phone: String = String(), link: String = String(), itemName: String = String(), itemDescription: String = String(), itemImage: String = String()
    
    func doSearch(itemId: String, dataTable: String){
        let requestURL = URL(string: "https://www.utterfare.com/includes/php/single-item.php")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        
        var parameters = "item_id= " + itemId
        parameters += "&data_table=" + dataTable
        
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
        do{
            let results = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSArray

            let result = results![0] as! NSDictionary;

            let companyName = result["COMPANY_NAME"] as! String
            let address = result["ADDRESS"] as! String
            let phone = result["TEL"] as! String
            let link = result["URL"] as! String
            let itemName = result["ITEM_NAME"] as! String
            let itemDescription = result["DESCRIPTION"] as! String
            let itemImage = result["IMAGE_URL"] as! String
            if self.delegate != nil{
                DispatchQueue.main.async{
                    self.delegate.itemsDownloaded(companyName: companyName, address: address, phone: phone, link: link, itemName: itemName, itemDescription: itemDescription, itemImage: itemImage)
                }
            }
        }catch{
            DispatchQueue.main.async {
                self.delegate.itemsDownloaded(companyName: "", address: "", phone: "", link: "", itemName: "", itemDescription: "", itemImage: "")

            }
        }
        
    }
}
