//
//  NewPasswordController.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/6/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation
import UIKit

class NewPasswordController: UIViewController, UITextFieldDelegate, NewPasswordProtocol{
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    
    let customAlert: CustomAlerts = CustomAlerts()
    var loadingAlert: UIAlertController = UIAlertController()
    
    var userId: String = String(), newPassword: String = String(), confirmNewPassword: String = String()
    
    func verifyChange(verifyChange: Bool) {
        self.loadingAlert.dismiss(animated: true, completion: {
            if verifyChange{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
                self.navigationController?.popToViewController(vc, animated: true)
            }else{
                let error: UIAlertController = self.customAlert.errorAlert(title: "Error Resetting Password", message: "There was an error with resetting your password. Please try again.")
                self.present(error, animated: true, completion: nil)
            }
        })
    }
    
    func validatePassword()->Bool{
        var isValid: Bool = false
        newPassword = newPasswordTextField.text!
        confirmNewPassword = confirmNewPasswordTextField.text!
        
        if newPassword == confirmNewPassword && newPassword.count >= 8{
            isValid = true
        }
        
        return isValid
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch(textField){
        case newPasswordTextField:
            newPasswordTextField.resignFirstResponder()
            confirmNewPasswordTextField.becomeFirstResponder()
        case confirmNewPasswordTextField:
            confirmNewPasswordTextField.resignFirstResponder()
            view.endEditing(true)
            self.submitNewPasswordAction()
        default: break;
        }
        
        return true
    }
    
    @IBAction func submitNewPasswordAction(){
        let newPasswordModel = NewPasswordModel()
        newPasswordModel.delegate = self;
        newPasswordModel.changePassword(password: newPassword, userId: userId)
        self.loadingAlert = customAlert.loadingAlert(title: "Resetting Password", message: "Please wait")
        self.present(loadingAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
