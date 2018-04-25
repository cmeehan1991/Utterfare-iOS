//
//  UserSignInModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/29/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation

protocol UserSignInProtocol: class {
    func userSignIn(isSignedIn: Bool, userId: String)
}
class UserSignInModel: NSObject{
    weak var delegate: UserSignInProtocol!

    func signIn(username: String, password: String){
        let url = URL(string: "https://www.utterfare.com/includes/mobile/users/Users.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        var parameters = "username=" + username
        parameters += "&password=" + password
        parameters += "&action=" + "log_in"

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
            let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            print(jsonData)
            if jsonData["RESPONSE"] as? String != "FAIL"{
                let userId = jsonData["ID"] as? String
                delegate.userSignIn(isSignedIn: true, userId: userId!)
            }else{
                delegate.userSignIn(isSignedIn: false, userId: "N/A")
            }
        }catch{
            print("JSON Error: ", error.localizedDescription)
        }
    }
}
