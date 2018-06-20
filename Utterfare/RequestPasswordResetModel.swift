//
//  RequestPasswordResetModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/6/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation

protocol ResetPasswordRequestProtocol: class {
    func requestSubmitted(success: Bool, response: String)
}

class RequestPasswordResetModel: NSObject{
    weak var delegate: ResetPasswordRequestProtocol!
    
    func submitRequest(email: String){
        let requestUrl = URL(string: "https://www.utterfare.com/includes/mobile/users/Users.php")
        var request = URLRequest(url: requestUrl!)
        request.httpMethod = "post"
        
        var parameters = "action=" + "reset_password_request"
        parameters += "&email=" + email
        
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            if error != nil{
                print("Task Error", error!)
                return
            }
            self.parseJson(data: data!)
            
        }
        task.resume()
    }
    
    func parseJson(data: Data){
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            print(jsonResponse)
            delegate.requestSubmitted(success: jsonResponse["SUCCESS"] as! Bool, response: jsonResponse["RESPONSE"] as! String)
            print("submitted")
        }catch{
            print("JSON Error: \(error.localizedDescription)")
        }
    }
}
