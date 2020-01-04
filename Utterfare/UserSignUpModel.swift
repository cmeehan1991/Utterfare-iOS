//
//  UserSignUpModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/31/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation

protocol UserSignUpProtocol: class {
    func userSignUp(success: Bool, response: String, userId: String)
}

class UserSignupModel: NSObject{
    weak var delegate: UserSignUpProtocol!
    func signUp(emailAddress: String, cellPhone: String, firstName: String, lastName: String, city: String, state: String, postalCode: String,gender: String, birthday: String, password: String){
        let url = URL(string: "https://www.utterfare.com/includes/php/Users.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        var parameters = "action=" + "new_user"
        parameters += "&email=" + emailAddress
        parameters += "&cell_phone=" + cellPhone
        parameters += "&first_name=" + firstName
        parameters += "&last_name=" + lastName
        parameters += "&city=" + city
        parameters += "&state=" + state
        parameters += "&postal_code=" + postalCode
        parameters += "&gender=" + gender
        parameters += "&birthday=" + birthday
        parameters += "&password=" + password
        
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
        let str = String(data: data, encoding: .utf8)
        
        print(str)
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            let success: Bool = jsonResponse["success"] as! Bool
            let response = jsonResponse["response"] as! String
            let userId = jsonResponse["user_id"] as! String
            
            DispatchQueue.main.async{
                self.delegate.userSignUp(success: success, response: response, userId: userId)
            }
        }catch{
            DispatchQueue.main.async{
                self.delegate.userSignUp(success: false, response: error.localizedDescription, userId: String())
            }
            print("JSON Error: ", error.localizedDescription)
        }
    }
    
}
