//
//  UserSignInController.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/29/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin

class UserSignInController: UIViewController, UserSignInProtocol, UITextFieldDelegate{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var facebookLoginButton: LoginButton!
    
    let defaults = UserDefaults.standard
    let backToItem: Bool = Bool()
    var username: String = String(), password: String = String()
    var loadingAlert: UIAlertController = UIAlertController()
    var loadingIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    
    func userSignIn(isSignedIn: Bool, userId: String) {
        defaults.set(isSignedIn, forKey: "IS_LOGGED_IN")
        defaults.set(userId, forKey: "USER_ID")
        self.loadingAlert.dismiss(animated: true, completion: {
            if isSignedIn{
                self.goToView()
            }else{
                self.showErrorAlert()
            }
        })
    }
    
    func showErrorAlert(){
        
    }
    
    func goToView(){
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func signIn(){
        let signInModel = UserSignInModel()
        signInModel.signIn(username: username, password: password)
    }
    
    func loadingIndicatorView() -> UIActivityIndicatorView{
        let loadingIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        loadingIndicator.startAnimating()
        
        return loadingIndicator
    }
    
    func loadingAlertController ()->UIAlertController{
        let loadingAlert : UIAlertController = UIAlertController(title: "Loading", message: "Please wait...", preferredStyle: .alert)
        loadingAlert.view.addSubview(loadingIndicator)
        return loadingAlert
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField{
            usernameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }
        
        if textField == passwordTextField{
            self.username = usernameTextField.text!
            self.password = passwordTextField.text!
            
            passwordTextField.resignFirstResponder()
            self.signIn()
        }
        return true
    }
    
    @IBAction func signInButtonAction(){
        username = usernameTextField.text!
        password = passwordTextField.text!
        self.present(loadingAlert, animated: true, completion: nil)
        let signInModel = UserSignInModel()
        signInModel.delegate = self
        signInModel.signIn(username: username, password: password)
    }
    
    @IBAction func signInWithFacebookButtonAction(){
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self){ loginResult in
            
            switch loginResult{
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print(grantedPermissions)
                print("Logged in!")
            }
        }
    }
    
    @IBAction func forgotUsernamePasswordButtonAction(){
        let alert = UIAlertController(title: "Forgot Username/Password", message: "Choose One", preferredStyle: .actionSheet)
        let usernameAction = UIAlertAction(title: "Forgot my username", style: .default, handler: {(alert: UIAlertAction!) in
            print("Reset Username")
        })
        
        let passwordAction = UIAlertAction(title: "Reset my password", style:.default, handler: {(alert: UIAlertAction!) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestPasswordResetController") as! RequestPasswordResetController
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        alert.addAction(usernameAction)
        alert.addAction(passwordAction)
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonAction(){
        let vc: UserSignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserSignUpViewController") as! UserSignUpViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the textfield delegate to self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Set the facebook login button
        facebookLoginButton = LoginButton(readPermissions: [.publicProfile, .email])
        
        // Initialize the alert controller and indicator
        loadingAlert = self.loadingAlertController()
        loadingIndicator = self.loadingIndicatorView()
        
        // Disable interaction with the navigation controller
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
}
