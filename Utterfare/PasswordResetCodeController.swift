//
//  PasswordResetCodeController.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/6/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation
import UIKit

class PasswordResetCodeController: UIViewController, UITextFieldDelegate, PasswordResetCodeProtocol{
    @IBOutlet weak var firstNumberTextField: UITextField!
    @IBOutlet weak var secondNumberTextField: UITextField!
    @IBOutlet weak var thirdNumberTextField: UITextField!
    @IBOutlet weak var fourthNumberTextField: UITextField!
    
    let customAlert: CustomAlerts = CustomAlerts()
    var loadingAlert: UIView = UIView()
    var passwordResetCode: PasswordResetCodeModel = PasswordResetCodeModel()
    let defaults = UserDefaults.standard
    
    func response(response: Bool, userId: String) {
        print("Response: \(response) & UserID: \(userId)")
        DispatchQueue.main.async {
            self.parseResponse(response: response, userId: userId)
        }
    }
    
    func parseResponse(response: Bool, userId: String){
        self.loadingAlert.removeFromSuperview()
        if response {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewPasswordController") as! NewPasswordController
            vc.userId = userId
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let alert: UIAlertController = customAlert.errorAlert(title: "Incorrect Code", message: "The code you entered does not match what we have on record. Please try again.")
            self.present(alert, animated: true, completion: {
                self.firstNumberTextField.text = nil
                self.secondNumberTextField.text = nil
                self.thirdNumberTextField.text = nil
                self.fourthNumberTextField.text = nil
            })
        }
    }
    
    func submitResetCode(){
        let resetCode = firstNumberTextField.text! + secondNumberTextField.text! + thirdNumberTextField.text! + fourthNumberTextField.text!
        self.passwordResetCode.checkCode(code: resetCode, username: defaults.string(forKey: "USERNAME")!)
    }
    
    @IBAction func popNavigation(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitResetCodeAction(){
        self.loadingAlert = customAlert.loadingAlert(uiView: self.view)
        self.view.addSubview(self.loadingAlert)
        submitResetCode()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch(textField){
        case firstNumberTextField:
            self.firstNumberTextField.resignFirstResponder()
            self.secondNumberTextField.becomeFirstResponder()
        case secondNumberTextField:
            self.secondNumberTextField.resignFirstResponder()
            self.thirdNumberTextField.becomeFirstResponder()
        case thirdNumberTextField:
            self.thirdNumberTextField.resignFirstResponder()
            self.fourthNumberTextField.becomeFirstResponder()
        case fourthNumberTextField:
            self.fourthNumberTextField.resignFirstResponder()
            view.endEditing(true)
            submitResetCode()
        default:
            break;
        }
        return true
    }
    

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.count == 1{
            switch (textField){
            case firstNumberTextField:
                self.firstNumberTextField.resignFirstResponder()
                self.secondNumberTextField.becomeFirstResponder()
            case secondNumberTextField:
                self.secondNumberTextField.resignFirstResponder()
                self.thirdNumberTextField.becomeFirstResponder()
            case thirdNumberTextField:
                self.thirdNumberTextField.resignFirstResponder()
                self.fourthNumberTextField.becomeFirstResponder()
            default: break
            }
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firstNumberTextField.delegate = self
        self.secondNumberTextField.delegate = self
        self.thirdNumberTextField.delegate = self
        self.fourthNumberTextField.delegate = self
        
        self.passwordResetCode.delegate = self
    }
}
