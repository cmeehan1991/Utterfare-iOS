//
//  ResultsModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 12/21/16.
//  Copyright © 2016 CBM Web Development. All rights reserved.
//

import Foundation

class ResultsModel: NSObject {
    // Properties
    
    var itemName: String?, itemAddress: String?, itemDescription: String?, itemImageURL: String?, itemURL: String?, itemPhone: String?
    
    // empty constructor
    
    override init(){
        
    }
    
    // construct with all parameters
    init(itemName: String, itemAddress: String, itemDescription: String, itemImageURL: String, itemURL: String, itemPhone: String){
        self.itemName = itemName
        self.itemAddress = itemAddress
        self.itemDescription = itemDescription
        self.itemImageURL = itemImageURL
        self.itemURL = itemURL
        self.itemPhone = itemPhone
    }
    
}
