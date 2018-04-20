//
//  UserInformationModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/18/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation


protocol GetUserInformationProtocol: class{
    func getUserInformationProtocol(status: Bool, response: String, firstName: String, lastName: String, city: String, state: String, emailAddress: String)
}

protocol SetUserInformationProtocol: class{
    func setUserInformationProtocol(status: Bool, response: String)
}

protocol RemoveUserProtocol: class{
    func removeUserProtocol(status: Bool, response: String)
}

protocol UpdatePasswordProtocol: class{
    func updatePassword(status: Bool, response: String)
}


class UserInformationModel: NSObject{
    weak var delegateGetUser: GetUserInformationProtocol!
    weak var delegateSetUser: SetUserInformationProtocol!
    weak var delegateRemoveUser: RemoveUserProtocol!
    weak var delegateUpdatePassword: UpdatePasswordProtocol!
    
    /**
     * Handles the request & task
     * Actions: get_user, set_user, remove_user, update_password
     */
    func userInformation(action: String, userId: String, firstName: String, lastName: String, city: String, state: String, emailAddress: String, password: String){
        let requestUrl = URL(string: "https://www.utterfare.com/includes/mobile/users/Users.php")
        var request = URLRequest(url: requestUrl!)
        request.httpMethod = "post"
        
        var parameters = "action=" + action
        parameters += "&user_id=" + userId
        parameters += "&first_name=" + firstName
        parameters += "&last_name=" + lastName
        parameters += "&city=" + city
        parameters += "&state=" + state
        parameters += "&email_address=" + emailAddress
        parameters += "&password=" + password
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            if error != nil{
                print("Task Error: \(String(describing: error?.localizedDescription))")
                return
            }
            switch(action){
            case "get_user":
                self.parseGetUserInformation(data: data!)
                break
            case "set_user":
                self.parseSetUserInformation(data: data!)
                break
            case "remove_user":
                self.parseRemoveUser(data: data!)
                break
            case "update_password":
                self.parseUpdatePassword(data: data!)
                break
            default: break
            }
        }
        task.resume()
    }

    /**
    * Parse user information and send it back to the controller
    */
    private func parseGetUserInformation(data: Data){
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            
            if jsonResponse["SUCCESS"] as! Bool {
                let firstName: String = jsonResponse["FIRST_NAME"] as! String
                let lastName: String = jsonResponse["LAST_NAME"] as! String
                let city: String = jsonResponse["CITY"] as! String
                let state: String = jsonResponse["STATE"] as! String
                let emailAddress: String = jsonResponse["EMAIL"] as! String
                print(jsonResponse)
                DispatchQueue.main.async {
                    self.delegateGetUser.getUserInformationProtocol(status: true, response: jsonResponse["RESPONSE"] as! String, firstName: firstName, lastName: lastName, city: city, state: state, emailAddress: emailAddress)
                }
            }
        }catch{
            DispatchQueue.main.async {
                self.delegateGetUser.getUserInformationProtocol(status: false, response: error.localizedDescription, firstName: "", lastName: "", city: "", state: "", emailAddress: "")
            }
            print("JSON Error: \(error.localizedDescription)")
        }
    }
    
    /**
     * Parse response from setting the user information and send it back to the controller
     */
    private func parseSetUserInformation(data: Data){
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            
            if(jsonResponse["SUCCESS"]) as! Bool{
                DispatchQueue.main.async {
                    self.delegateSetUser.setUserInformationProtocol(status: true, response: jsonResponse["RESPONSE"] as! String)
                }
            }
        }catch{
            DispatchQueue.main.async {
                self.delegateSetUser.setUserInformationProtocol(status: false, response: error.localizedDescription)
            }
            print("JSON Error: \(error.localizedDescription)")
        }
    }
    
    /**
     * Parse response when removing the user and send it back to the controller
     */
    private func parseRemoveUser(data: Data){
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            
            if(jsonResponse["SUCCESS"]) as! Bool{
                DispatchQueue.main.async {
                    self.delegateRemoveUser.removeUserProtocol(status: true, response: jsonResponse["RESPONSE"] as! String)
                }
            }
        }catch{
            DispatchQueue.main.async {
                self.delegateRemoveUser.removeUserProtocol(status: false, response: error.localizedDescription)
            }
            print("JSON Error: \(error.localizedDescription)")
        }
    }
    
    /**
     * Parse response when removing the user and send it back to the controller
     */
    private func parseUpdatePassword(data: Data){
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            print(jsonResponse)
            if(jsonResponse["SUCCESS"]) as! Bool{
                DispatchQueue.main.async {
                    self.delegateUpdatePassword.updatePassword(status: true, response: "Successfully changed password")
                }
            }
        }catch{
            DispatchQueue.main.async {
                self.delegateUpdatePassword.updatePassword(status: false, response: error.localizedDescription)
            }
            print("JSON Error: \(error.localizedDescription)")
        }
    }
}
