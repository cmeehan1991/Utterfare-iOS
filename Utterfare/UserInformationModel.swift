//
//  UserInformationModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/18/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation


protocol GetUserInformationProtocol: class{
    func getUserInformationProtocol(status: Bool, firstName: String, lastName: String, primaryAddress: String, secondaryAddress: String, city: String, state: String, postalCode: String, emailAddress: String, birthday: String, cellPhone: String, gender: String)
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
    let requestUrl = URL(string: "https://www.utterfare.com/includes/php/Users.php")
    
    func updatePassword(userId: String, password: String){
        
    }
    
    /*
     * Remove the user
     */
    func removeUser(userId: String){
        
    }
    
    /*
     * Save the User's information
     */
    func saveUserInformation(firstName: String, lastName: String, primaryAddress: String, secondaryAddress: String, city: String, state: String, postalCode: String, email: String, cellPhone: String, birthday: String, gender: String, userId: String){
        var request = URLRequest(url: requestUrl!)
        request.httpMethod = "post"
        
        var parameters = "action=set_user"
        parameters += "&user_id=" + userId
        parameters += "&first_name=" + firstName
        parameters += "&last_name=" + lastName
        parameters += "&primary_address=" + primaryAddress
        parameters += "&secondary_address=" + secondaryAddress
        parameters += "&city=" + city
        parameters += "&state=" + state
        parameters += "&postal_code=" + postalCode
        parameters += "&email=" + email
        parameters += "&telephone_number=" + cellPhone
        parameters += "&gender=" + gender
        parameters += "&birthday=" + birthday
        
        print(parameters)
        
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            if error != nil{
                print("Task error \(error?.localizedDescription ?? "No message")")
                return
            }
            
            self.parseSetUserInformation(data: data!)
        }
        
        task.resume()
    }
    
    /**
     * Handles the request & task
     * Actions: get_user, set_user, remove_user, update_password
     */
    func getUserInformation(userId: String){

        var request = URLRequest(url: requestUrl!)
        request.httpMethod = "post"
        
        var parameters = "action=get_user"
        parameters += "&user_id=" + userId
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            if error != nil{
                print("Task Error: \(String(describing: error?.localizedDescription))")
                return
            }
            self.parseGetUserInformation(data: data!)
                
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
                let firstName: String = jsonResponse["first_name"] as? String ?? ""
                let lastName: String = jsonResponse["last_name"] as? String ?? ""
                let primaryAddress = jsonResponse["primary_address"] as? String ?? ""
                let secondaryAddress = jsonResponse["secondary_address"] as? String ?? ""
                let city: String = jsonResponse["city"] as? String ?? ""
                let state: String = jsonResponse["state"] as? String ?? ""
                let postalCode = jsonResponse["postal_code"] as? String ?? ""
                let emailAddress: String = jsonResponse["email"] as? String ?? ""
                let cellPhone = jsonResponse["cell_phone"] as? String ?? ""
                let gender = jsonResponse["gender"] as? String ?? "N/A"
                let birthday = jsonResponse["birthday"] as? String ?? "1991-06-30"
                
                
                DispatchQueue.main.async {
                    self.delegateGetUser.getUserInformationProtocol(status: true, firstName: firstName, lastName: lastName, primaryAddress: primaryAddress, secondaryAddress: secondaryAddress, city: city, state: state, postalCode: postalCode, emailAddress: emailAddress, birthday: birthday, cellPhone: cellPhone, gender: gender)
                }
            }
        }catch{
            print("JSON Error: \(error.localizedDescription)")
        }
    }
    
    /**
     * Parse response from setting the user information and send it back to the controller
     */
    private func parseSetUserInformation(data: Data){
        let str = String(data: data, encoding: .utf8)
        print(str)
        
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
