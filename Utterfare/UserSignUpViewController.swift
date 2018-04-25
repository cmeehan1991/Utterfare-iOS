//
//  UserSignUpViewController.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/31/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import UIKit

class UserSignUpViewController: UIViewController, UITextFieldDelegate, UserSignUpProtocol{
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet var keyboardHeighLayoutConstraint: NSLayoutConstraint?
    @IBOutlet weak var scrollView: UIScrollView!
    
    let defaults = UserDefaults.standard
    let customAlert = CustomAlerts()
    var loadingView: UIView = UIView()
    var activeField: UITextField = UITextField()
    var password: String = String(), confirmPassword: String = String(), email: String = String(), firstName: String = String(), lastName: String = String(), city: String = String(), state: String = String()
    
    func userSignUp(success: Bool, response: String, userId: String) {
        self.loadingView.removeFromSuperview()
        if success{
            defaults.set(userId, forKey: "USER_ID")
            defaults.set(true, forKey: "IS_LOGGED_IN")
            goToView()
        }else{
            explainFail(fail: response)
        }
    }
    
    func explainFail(fail: String){
        let alert = UIAlertController(title: "Error", message: fail, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func goToView(){
        let vc: MyItemsViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyItemsViewController") as! MyItemsViewController
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func signUp(){
        self.loadingView = customAlert.loadingAlert(uiView: self.view)
        self.view.addSubview(self.loadingView)
        let signUpModel: UserSignupModel = UserSignupModel()
        signUpModel.delegate = self
        signUpModel.signUp(password: password, email: email, firstName: firstName, lastName: lastName, city: city, state: state)
    }
    
    func validateInformation() -> Bool{
        if email.isEmpty{
            return false
        }
        if password.isEmpty{
            return false
        }
        if password != confirmPassword {
            return false
        }
        
        return true
    }
    
    @IBAction func signUpAction(){
        password = self.passwordTextField.text!
        confirmPassword = self.confirmPasswordTextField.text!
        email = self.emailAddressTextField.text!
        firstName = self.firstNameTextField.text!
        lastName = self.lastNameTextField.text!
        city = self.cityTextField.text!
        state = self.stateTextField.text!
        if validateInformation() {
            signUp()
        }else{
            let alert = UIAlertController(title: "Invalid Info", message: "Please check to make sure you entered all the required information.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch(textField){
        case firstNameTextField:
            self.firstNameTextField.resignFirstResponder()
            self.lastNameTextField.becomeFirstResponder()
            break
        case lastNameTextField:
            self.lastNameTextField.resignFirstResponder()
            self.cityTextField.becomeFirstResponder()
            break
        case cityTextField:
            self.cityTextField.resignFirstResponder()
            self.stateTextField.becomeFirstResponder()
            break
        case stateTextField:
            self.stateTextField.resignFirstResponder()
            self.emailAddressTextField.becomeFirstResponder()
            break
        case emailAddressTextField:
            self.emailAddressTextField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
            break
        case passwordTextField:
            self.passwordTextField.resignFirstResponder()
            self.confirmPasswordTextField.becomeFirstResponder()
            break
        case confirmPasswordTextField:
            self.confirmPasswordTextField.resignFirstResponder()
            self.view.endEditing(true)
            self.signUpAction()
            break
        default: break
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeField = textField
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
    @objc func keyboardNotification(notification: NSNotification){
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeighLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeighLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            print("Animate")
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set textfields delegate
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.cityTextField.delegate = self
        self.stateTextField.delegate = self
        self.emailAddressTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
}
