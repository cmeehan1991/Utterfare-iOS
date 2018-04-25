//
//  PasswordResetCodeModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/6/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation

protocol PasswordResetCodeProtocol: class{
    func response(response: Bool, userId: String)
}

class PasswordResetCodeModel: NSObject{
    weak var delegate: PasswordResetCodeProtocol!
    
    func checkCode(code: String, username: String){
        let requestURL = URL(string:"https://www.utterfare.com/includes/mobile/users/Users.php")
        var urlRequest = URLRequest(url: requestURL!)
        urlRequest.httpMethod = "post"
        
        var params = "action=" + "verify_reset_code"
        params += "&username=" + username
        params += "&reset_code=" + code

        urlRequest.httpBody = params.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: urlRequest){
            data, response, error in
            if error != nil{
                print("Task Error: \(String(describing: error?.localizedDescription))")
                return
            }
            self.parseResponse(data: data!)
        }
        task.resume()
    }
    
    func parseResponse(data: Data){
        do{
            let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            print(jsonData);
            if jsonData.count > 0 {
                self.delegate.response(response: jsonData["RESPONSE"] as! Bool, userId: jsonData["ID"] as! String)
            }
        }catch{
            print("JSON Error: \(error.localizedDescription)")
        }
    }
}
