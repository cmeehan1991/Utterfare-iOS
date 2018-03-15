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
    func itemsDownloaded(hasResults: Bool, itemNames: NSArray, restaurantNames: NSArray, itemImages: [UIImage], itemDescriptions: NSArray, restaurantURLs: NSArray, restaurantDistances: NSArray, restaurantPhones: NSArray, restaurantAddresses: NSArray)
}

class SearchController: NSObject{
    weak var delegate: SearchControllerProtocal!
    var location : String = String(), terms : String = String(), offset : String = String(), distance : String = String()
    var jsonData : Data = Data()
    
    func doSearch(terms: String, distance: String, location: String, offset: String){
        let requestURL = URL(string: "https://www.utterfare.com/ufdev/includes/php/ios-search.php");
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
                print("Task Error: \(error)")
            }else{
                self.jsonData = data!
                self.parseJSON();
            }
        }
        task.resume()
    }
    
    func parseJSON(){
        do{
            let jsonResults = try JSONSerialization.jsonObject(with: self.jsonData, options: .allowFragments) as? NSArray
            var haveResults: Bool = Bool()
            if jsonResults == nil {
                haveResults = false;
            }else{
                haveResults = true;
            }
            if let results = jsonResults {
                let itemName : NSMutableArray = NSMutableArray()
                let restaurantName: NSMutableArray = NSMutableArray()
                var itemImage: Array<UIImage> = Array<UIImage>()
                let itemDescription : NSMutableArray = NSMutableArray()
                let restaurantURL : NSMutableArray = NSMutableArray()
                let restaurantDistance : NSMutableArray = NSMutableArray()
                let restaurantContact : NSMutableArray = NSMutableArray()
                let restaurantAddress : NSMutableArray = NSMutableArray()
                
                
                for i in 0..<(results.count){
                    let result = results[i] as! NSDictionary
                    
                    // Convert the image url to a UIImage and add to the itemImage array
                    let itemImageURL = result["image_url"] as! String
                    let url = URL(string: itemImageURL)!
                    let imageData = NSData(contentsOf: url)
                    let image = UIImage(data: imageData as! Data)
                    itemImage.append(image!);
                    
                    
                    itemName.add(result["NAME"] as! String)
                    restaurantName.add(result["COMPANY"] as! String)
                    itemDescription.add(result["DESCRIPTION"] as! String)
                    restaurantURL.add(result["LINK"] as! String)
                    restaurantDistance.add(result["DISTANCE"] as! String)
                    restaurantContact.add(result["PHONE"] as! String)
                    restaurantAddress.add(result["ADDRESS"] as! String)
                    
                }
                
                
                DispatchQueue.main.async {
                    self.delegate.itemsDownloaded(hasResults: haveResults, itemNames: itemName, restaurantNames: restaurantName, itemImages: itemImage, itemDescriptions: itemDescription, restaurantURLs: restaurantURL, restaurantDistances: restaurantDistance, restaurantPhones: restaurantContact, restaurantAddresses: restaurantAddress)
                }
            }
        }catch{
            print(error)
        }
        
    }
    
    
}
