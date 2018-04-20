//
//  UpdatePasswordController.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/19/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation
import UIKit

class UpdatePasswordController: UIViewController, UITextFieldDelegate, UpdatePasswordProtocol{
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    @IBOutlet weak var submitNewPasswordButton: UIButton!
    
    let defaults = UserDefaults()
    let customAlert: CustomAlerts = CustomAlerts()
    var loadingView: UIView = UIView()
    var newPassword: String = String(), confirmNewPassword: String = String()
    
    /*
    * Performs when the return button is tapped on the keyboard
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch(textField){
        case newPasswordTextField:
            self.newPasswordTextField.resignFirstResponder()
            self.confirmNewPasswordTextField.becomeFirstResponder()
            break
        case confirmNewPasswordTextField:
            self.confirmNewPasswordTextField.resignFirstResponder()
            self.submitNewPasswordUpdate()
            break
        default: break
        }
        return true
    }
    
    @IBAction func upNavigation(){
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    * Submits new password on button touch
    */
    @IBAction func submitNewPasswordUpdate(){
        let userInformationModel: UserInformationModel = UserInformationModel()
        userInformationModel.delegateUpdatePassword = self
        self.assignValues()
        userInformationModel.userInformation(action: "update_password", userId: defaults.string(forKey: "USER_ID")!, firstName: String(), lastName: String(), city: String(), state: String(), emailAddress: String(), password: self.newPassword)
        self.loadingView = customAlert.loadingAlert(uiView: self.view)
        self.view.addSubview(self.loadingView)
    }
    
    /*
     * Response protocol
     */
    func updatePassword(status: Bool, response: String) {
        self.loadingView.removeFromSuperview()
        if status{
            goToView()
        }else{
            notifyUserFail(status: status, response: response)
        }
    }
    
    // Notify the user if the update failed
    func notifyUserFail(status: Bool, response: String){
        let alert = customAlert.errorAlert(title: "Error Updating Password", message: response)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Notify the user if the update succeeded then go back to the last screen
    func goToView(){
        let alert = UIAlertController(title: "Password Updated", message: "Your password was successfully updated.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Assign the textfield values to their variables
    func assignValues(){
        newPassword = newPasswordTextField.text!
        confirmNewPassword = confirmNewPasswordTextField.text!
    }
    
    // Performs the validation on the passwords
    func validatePassword()->Bool{
        var isValid = true
        
        if newPassword.count > 8{
            isValid = false
        }
        
        if newPassword != confirmNewPassword{
            isValid = false
        }
        
        return isValid
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newPasswordTextField.delegate = self
        self.confirmNewPasswordTextField.delegate = self
        
    }
    
    
}
