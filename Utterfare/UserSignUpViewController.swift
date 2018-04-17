//
//  UserSignUpViewController.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/31/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import UIKit

class UserSignUpViewController: UIViewController, UserSignUpProtocol{
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    let defaults = UserDefaults.standard
    var password: String = String(), confirmPassword: String = String(), email: String = String(), firstName: String = String(), lastName: String = String(), city: String = String(), state: String = String()
    
    func userSignUp(success: Bool, response: String, userId: String) {
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
        let signUpModel: UserSignupModel = UserSignupModel()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
