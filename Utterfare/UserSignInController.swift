//
//  UserSignInController.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/29/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class UserSignInController: UIViewController, UserSignInProtocol, UITextFieldDelegate, LoginButtonDelegate{
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let defaults = UserDefaults.standard
    let customAlert: CustomAlerts = CustomAlerts()
    var loadingView: UIView = UIView()
    let backToItem: Bool = Bool()
    var username: String = String(), password: String = String()
    var userInformationVC: UserInformationController!
    var userItemsVC: MyItemsViewController!
    
    /*
     * Handle the user sign in protocol
     */
    func userSignIn(isSignedIn: Bool, userId: String) {
        print(userId)
        defaults.set(isSignedIn, forKey: "IS_LOGGED_IN")
        defaults.set(userId, forKey: "USER_ID")
        if isSignedIn{
            self.loadingView.removeFromSuperview()
            self.dismiss(animated: true, completion: {
                if self.userItemsVC != nil{
                    self.userItemsVC.getItems()
                }else{
                    self.userInformationVC.getUserInformation()
                }
            })
        }else{
            self.loadingView.removeFromSuperview()
            
            let alert = UIAlertController(title: "Sign In Error", message: "The username and password combination did not match what we have on file. Please try again.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: {alert in
                self.passwordTextField.text! = ""
                self.usernameTextField.becomeFirstResponder()
                self.view.isUserInteractionEnabled = true

            })
            
            alert.addAction(dismissAction)
        
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /*
     * Sign in action
     * This is called by both the @IBAction and button touch
     */
    func signIn(){
        self.view.isUserInteractionEnabled = false
        self.view.addSubview(loadingView)
        
        let signInModel = UserSignInModel()
        signInModel.delegate = self
        signInModel.signIn(username: username, password: password)
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

    /*
     * Handle the Facebook login button response
     */
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if result!.isCancelled {
            print("Cancelled")
            return
        }

        let connection = GraphRequestConnection()
        
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields":"id, email, name"])) { httpResponse, result, error  in
        
            if error != nil{
                print("Graph Error: \(error?.localizedDescription)")
                return
            }
            
            let result = result as? [String:String]
            let fbid: String = result!["id"]!
            let email: String = result!["email"]!
            let name: String = result!["name"]!
            
            self.handleFacebookUser(fbid: fbid, email: email, name: name)
            
        }
        connection.start()
        
    }
    
    /*
     * Sign the user in or sign them up after logging in with Facebook
     */
    func handleFacebookUser(fbid:String, email: String, name: String){
        
        let signInModel = UserSignInModel()
        signInModel.delegate = self
        signInModel.signInFacebook(fbid: fbid, email: email, name: name)
    }
    
    /*
     * Handle the Facebook Logout
     */
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        self.defaults.set(nil, forKey: "FB_USER_ID")
        self.defaults.set(nil, forKey: "USER_ID")
        self.defaults.set(false, forKey: "IS_LOGGED_IN")
    }
    
    @IBAction func signInButtonAction(){
        username = usernameTextField.text!
        password = passwordTextField.text!
        
        self.signIn()
    }
     
    @IBAction func forgotUsernamePasswordButtonAction(){
        let alert = UIAlertController(title: "Forgot Username/Password", message: "Choose One", preferredStyle: .actionSheet)
        
        let passwordAction = UIAlertAction(title: "Reset my password", style:.default, handler: {(alert: UIAlertAction!) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestPasswordResetController") as! RequestPasswordResetController
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style:.destructive, handler: nil)
        
        alert.addAction(passwordAction)
        alert.addAction(cancelAction)
        

        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonAction(){
        print("Sign Up")
        let vc: UserSignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserSignUpViewController") as! UserSignUpViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.dismiss(animated: false, completion: nil)
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        self.navigationController?.viewControllers = [self]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
         self.loadingView = customAlert.loadingAlert(uiView: self.view)
        
        // Set the textfield delegate to self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        if let accessToken = AccessToken.current{
            
            self.defaults.set(accessToken.userID, forKey: "FB_USER_ID")
            self.defaults.set(true, forKey: "IS_LOGGED_IN")
            
            self.dismiss(animated: true, completion: nil)
        }
        
        // Create the Facebook login button
        let fbLoginButton: FBLoginButton = FBLoginButton()
        fbLoginButton.center = self.view.center
        fbLoginButton.delegate = self
        
        fbLoginButton.frame = CGRect(x: self.loginButton.frame.origin.x, y: self.loginButton.frame.origin.y + self.loginButton.frame.size.height + 8, width: self.loginButton.frame.width, height: self.loginButton.frame.height)
        
        self.view.addSubview(fbLoginButton)
        
        // Set the requested permissions
        fbLoginButton.permissions = ["email", "public_profile"]
        
        // Disable interaction with the navigation controller
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        // Dismiss keyboard on swipe
        scrollView.keyboardDismissMode = .interactive
        
    }
    
    override func loadView(){
        super.loadView()
        let isLoggedIn: Bool = defaults.bool(forKey: "IS_LOGGED_IN")
        if isLoggedIn {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyItemsViewController") as! MyItemsViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
}
