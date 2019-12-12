//
//  UserSignInController.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/29/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation
import UIKit

class UserSignInController: UIViewController, UserSignInProtocol, UITextFieldDelegate{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let defaults = UserDefaults.standard
    let customAlert: CustomAlerts = CustomAlerts()
    var loadingView: UIView = UIView()
    let backToItem: Bool = Bool()
    var username: String = String(), password: String = String()
    var activeField: UITextField = UITextField()

    
    func userSignIn(isSignedIn: Bool, userId: String) {
        DispatchQueue.main.async {
            self.handleResponse(isSignedIn: isSignedIn, userId: userId)
        }
    }
    
    func handleResponse(isSignedIn: Bool, userId: String){
        defaults.set(isSignedIn, forKey: "IS_LOGGED_IN")
        defaults.set(userId, forKey: "USER_ID")
        if isSignedIn{
            self.goToView()
            self.loadingView.removeFromSuperview()
        }else{
            self.loadingView.removeFromSuperview()
            self.showErrorAlert()
        }
    }
    
    func showErrorAlert(){
        
    }
    
    func goToView(){
        let vcs = self.navigationController?.viewControllers
        if (vcs?.count)! > 1{
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyItemsViewController") as! MyItemsViewController
            self.navigationController?.pushViewController(vc, animated: true)        }

    }
    
    func signIn(){
        self.view.isUserInteractionEnabled = false
        self.view.addSubview(loadingView)
        
        let signInModel = UserSignInModel()
        signInModel.signIn(username: username, password: password)
    }
    
    func loadingIndicatorView() -> UIActivityIndicatorView{
        let loadingIndicator : UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        loadingIndicator.startAnimating()
        
        return loadingIndicator
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
        
        //self.present(loadingAlert, animated: true, completion: nil)
        let signInModel = UserSignInModel()
        signInModel.delegate = self
        signInModel.signIn(username: username, password: password)
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
        let vc: UserSignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserSignUpViewController") as! UserSignUpViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeField = textField
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            let aRect = self.view.frame
            if !aRect.contains(self.activeField.frame.origin){
                self.scrollView.scrollRectToVisible(aRect, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("View will appear")
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
        
        // Set the facebook login button
       
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
}
