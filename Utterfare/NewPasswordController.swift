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
    var loadingAlert: UIView = UIView()
    
    var userId: String = String(), newPassword: String = String(), confirmNewPassword: String = String()
    
    func verifyChange(verifyChange: Bool) {
        DispatchQueue.main.async {
            self.handleResponse(verifyChange: verifyChange)
        }
       
    }
    
    func handleResponse(verifyChange: Bool){
        self.loadingAlert.removeFromSuperview()
        if verifyChange{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
            self.navigationController?.pushViewController(vc, animated: true)

        }else{
            let error: UIAlertController = self.customAlert.errorAlert(title: "Error Resetting Password", message: "There was an error with resetting your password. Please try again.")
            self.present(error, animated: true, completion: nil)
        }
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
    
    @IBAction func popNavigation(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitNewPasswordAction(){
        let newPasswordModel = NewPasswordModel()
        newPasswordModel.delegate = self;
        newPasswordModel.changePassword(password: newPassword, userId: userId)
        self.loadingAlert = customAlert.loadingAlert(uiView: self.view)
        self.view.addSubview(self.loadingAlert)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
