//
//  RequestPasswordResetController.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/6/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import UIKit

class RequestPasswordResetController: UIViewController, ResetPasswordRequestProtocol, UITextFieldDelegate{
    @IBOutlet weak var emailTextField: UITextField!
    let passwordResetRequest: RequestPasswordResetModel = RequestPasswordResetModel()
    let customAlert: CustomAlerts = CustomAlerts()
    var loadingAlert: UIView = UIView()
    let defaults = UserDefaults.standard
   
    func requestSubmitted(success: Bool, response: String) {
        DispatchQueue.main.async {
            self.requestFinished(success: success, response: response)
        }
    }
    
    func requestFinished(success: Bool, response: String){
        self.loadingAlert.removeFromSuperview()
        if success == true{
            self.defaults.set(self.emailTextField.text, forKey: "USERNAME")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PasswordResetCodeController") as! PasswordResetCodeController
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let error: UIAlertController = self.customAlert.errorAlert(title: "Code Error", message: "Error generating the reset code:\n \(response)")
            self.present(error, animated: true, completion: nil)
        }
    }
    
    func requestReset(){
        self.loadingAlert = customAlert.loadingAlert(uiView: self.view)
        self.view.addSubview(self.loadingAlert)
        self.passwordResetRequest.submitRequest(email: self.emailTextField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func popNavigation(){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func requestResetCodeAction(){
        requestReset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordResetRequest.delegate = self
        self.emailTextField.delegate = self
    }
    
    
}
