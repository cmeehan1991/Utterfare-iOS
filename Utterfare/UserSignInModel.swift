//
//  UserSignInModel.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/29/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation

protocol UserSignInProtocol {
    func userSignIn(isSignedIn: Bool, userId: String)
}
class UserSignInModel: NSObject{
    var delegate: UserSignInProtocol!

    func signIn(username: String, password: String){
        let url = URL(string: "https://www.utterfare.com/includes/php/mobileUserSignIn.php")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var parameters = "username=" + username
        parameters += "&password="
    }
    
    func parseData(data: Data){
        
    }
}
