//
//  NewPasswordModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/6/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation


protocol NewPasswordProtocol: class{
    func verifyChange(verifyChange: Bool)
}

class NewPasswordModel: NSObject{
    weak var delegate: NewPasswordProtocol!
    
    func changePassword(password: String, userId: String){
        let requestUrl = URL(string: "https://www.utterfare.com/includes/mobile/users/Users.php")
        var urlRequest = URLRequest(url: requestUrl!)
        urlRequest.httpMethod = "post"
        
        var params = "action=" + "set_new_password"
        params += "&user_id=" + userId
        params += "&password=" + password
        
        urlRequest.httpBody = params.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: urlRequest){
            data, response, error in
            if error != nil{
                print("Task error: \(error?.localizedDescription)")
            }
            self.parseResponse(data: data!)
        }
        task.resume()
    }
    
    func parseResponse(data: Data){
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            self.delegate.verifyChange(verifyChange: jsonResponse["SUCCESS"] as! Bool)
        }catch{
            print("JSON Error: \(error.localizedDescription)")
        }
    }
}
