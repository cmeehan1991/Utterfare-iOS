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

    func signInFacebook(fbid: String, email: String, name: String){
        let url = URL(string: "https://www.utterfare.com/includes/php/Users.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        var parameters = "action=fb_log_in"
        parameters += "&fb_id=" + fbid
        parameters += "&email=" + email
        parameters += "&name=" + name
        
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            if error != nil{
                print("Task error: \(error?.localizedDescription)")
                return
            }
            
            self.parseData(data: data!)
        }
        task.resume()
    }
    
    func signIn(username: String, password: String){
        let url = URL(string: "https://www.utterfare.com/includes/php/Users.php")
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

            DispatchQueue.main.async{
                if jsonData["RESPONSE"] as? String != "FAIL"{
                    let userId = jsonData["user_id"] as? String
                    self.delegate.userSignIn(isSignedIn: true, userId: userId!)
                }else{
                    self.delegate.userSignIn(isSignedIn: false, userId: "N/A")
                }
            }
        }catch{
            print("JSON Error: ", error.localizedDescription)
        }
    }
}
