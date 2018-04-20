//
//  UserInformationController.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/18/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import UIKit

class UserInformationController: UIViewController, GetUserInformationProtocol, SetUserInformationProtocol, RemoveUserProtocol{
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    let defaults = UserDefaults()
    let customAlert: CustomAlerts = CustomAlerts()
    let userInformationModel: UserInformationModel = UserInformationModel()
    var loadingView: UIView = UIView()
    var firstName: String = String(), lastName: String = String(), city: String = String(), state: String = String(), emailAddress: String = String()
    
    func setVariables(){
        self.firstName = firstNameTextField.text!
        self.lastName = lastNameTextField.text!
        self.city = cityTextField.text!
        self.state = stateTextField.text!
        self.emailAddress = emailAddressTextField.text!
    }
    
    func setUserInformationProtocol(status: Bool, response: String){
        self.loadingView.removeFromSuperview()
        if status{
           let alert = customAlert.successAlert(title: "User Updated", message: "Your information has been successfully updated.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getUserInformationProtocol(status: Bool, response: String, firstName: String, lastName: String, city: String, state: String, emailAddress: String){
        self.view.isUserInteractionEnabled = true
        self.loadingView.removeFromSuperview()
        if status{
            firstNameTextField.text = firstName
            lastNameTextField.text = lastName
            cityTextField.text = city
            stateTextField.text = state
            emailAddressTextField.text = emailAddress
        }
    }
    
    func removeUserProtocol(status: Bool, response: String){
        self.loadingView.removeFromSuperview()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
        self.navigationController?.dismiss(animated: true, completion: {
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    func getUserInformation(){
        self.view.isUserInteractionEnabled = false
        self.view.addSubview(loadingView)
        self.userInformationModel.delegateGetUser = self
        userInformationModel.userInformation(action: "get_user", userId: defaults.string(forKey: "USER_ID")!, firstName: firstName, lastName: lastName, city: city,  state: state, emailAddress: emailAddress, password: String())
    }
    
    func setUserInformation(){
        setVariables()
        self.view.isUserInteractionEnabled = false
        self.view.addSubview(loadingView)
        self.userInformationModel.delegateSetUser = self
        userInformationModel.userInformation(action: "set_user", userId: defaults.string(forKey: "USER_ID")!, firstName: firstName, lastName: lastName, city: city, state: state, emailAddress: emailAddress, password: String())
    }
    
    func removeUserAccount(){
        let alert = UIAlertController(title: "Permanently Delete Account", message: "Are you sure you want to permanently delete your account. All of your data will be removed and CANNOT be recovered once you do this.", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Delete My Account", style: .destructive, handler: {(alert: UIAlertAction!) in
            self.view.isUserInteractionEnabled = false
            self.view.addSubview(self.loadingView)
            self.userInformationModel.delegateRemoveUser = self
            self.userInformationModel.userInformation(action: "remove_user", userId: self.defaults.string(forKey: "USER_ID")!, firstName: String(), lastName: String(), city: String(), state: String(), emailAddress: String(), password: String())
        })
        let cancelAction = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        self.navigationController?.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func upNavigation(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveUserInformation(){
        setUserInformation()
    }
    
    @IBAction func updatePasswordAction(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UpdatePasswordController") as! UpdatePasswordController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteAccountAction(){
        removeUserAccount()
    }
    
    @IBAction func logOutAction(){
        defaults.set(nil, forKey: "USER_ID")
        defaults.set(false, forKey: "IS_LOGGED_IN")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the loading view
        loadingView = customAlert.loadingAlert(uiView: self.view)
        
        // Get the user's information
        getUserInformation()
    }
    
}