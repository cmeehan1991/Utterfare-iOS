//
//  UserInformationController.swift
//  Utterfare
//
//  Created by Connor Meehan on 4/18/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class UserInformationController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, GetUserInformationProtocol, SetUserInformationProtocol, RemoveUserProtocol{
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var primaryAddressField: UITextField!
    @IBOutlet weak var secondaryAddressField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var cellPhoneTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var genderPickerView: UIPickerView!
    @IBOutlet weak var birthdayPickerView: UIDatePicker!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var loadingView: UIView!
    let formatter = DateFormatter()
    let defaults = UserDefaults()
    let customAlert: CustomAlerts = CustomAlerts()
    let userInformationModel: UserInformationModel = UserInformationModel()
    
    var activeField: UITextField = UITextField()
    var genders: Array<String> = ["N/A", "Male", "Female", "Other"]
    
    func getUserInformationProtocol(status: Bool, firstName: String, lastName: String, primaryAddress: String, secondaryAddress: String, city: String, state: String, postalCode: String, emailAddress: String, birthday: String, cellPhone: String, gender: String) {
        
        firstNameTextField.text = firstName
        lastNameTextField.text = lastName
        primaryAddressField.text = primaryAddress
        secondaryAddressField.text = secondaryAddress
        cityTextField.text = city
        stateTextField.text = state
        postalCodeTextField.text = postalCode
        emailAddressTextField.text = emailAddress
        cellPhoneTextField.text = cellPhone
        genderPickerView.selectRow(genders.firstIndex(of: gender)!, inComponent: 0, animated: true)
        
        
        let formattedBirthday = formatter.date(from: birthday)
        birthdayPickerView.date = formattedBirthday!
        
        
        //self.loadingView.removeFromSuperview()
       // self.view.isUserInteractionEnabled = true
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func setUserInformationProtocol(status: Bool, response: String){
        //self.loadingView.removeFromSuperview()
        //self.view.isUserInteractionEnabled = true
        if status{
           let alert = customAlert.successAlert(title: "User Updated", message: "Your information has been successfully updated.")
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func removeUserProtocol(status: Bool, response: String){
        //self.loadingView.removeFromSuperview()
        if status{
            defaults.set(false, forKey: "IS_LOGGED_IN")
            defaults.set("", forKey:"USER_ID")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let errorAlert = customAlert.errorAlert(title: "Failed to Remove User", message: response)
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    func getUserInformation(){
        //self.view.isUserInteractionEnabled = true
        //self.view.addSubview(loadingView)
        self.userInformationModel.delegateGetUser = self

        userInformationModel.getUserInformation(userId: defaults.string(forKey: "USER_ID")!)
    }

    
    func removeUserAccount(){
        let alert = UIAlertController(title: "Permanently Delete Account", message: "Are you sure you want to permanently delete your account. You will not be able to access your account data and your CANNOT be recovered once you do this.", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Delete My Account", style: .destructive, handler: {(alert: UIAlertAction!) in
            self.view.isUserInteractionEnabled = false
            self.view.addSubview(self.loadingView)
            self.userInformationModel.delegateRemoveUser = self
            self.userInformationModel.removeUser(userId: self.defaults.string(forKey:"USER_ID")!)
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
        //self.view.isUserInteractionEnabled = false
        //self.view.addSubview(loadingView)
        self.userInformationModel.delegateSetUser = self
        
        // Format the birthday date to string
        let birthday = formatter.string(from: birthdayPickerView.date)
        
        
        userInformationModel.saveUserInformation(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, primaryAddress:primaryAddressField.text!, secondaryAddress: secondaryAddressField.text!, city: cityTextField.text!, state: stateTextField.text!, postalCode: postalCodeTextField.text!, email: emailAddressTextField.text!, cellPhone: cellPhoneTextField.text!, birthday: birthday, gender: genders[genderPickerView.selectedRow(inComponent: 0)], userId: self.defaults.string(forKey: "USER_ID")!)
    }
    
    @IBAction func updatePasswordAction(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UpdatePasswordController") as! UpdatePasswordController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteAccountAction(){
        removeUserAccount()
    }
    
    @IBAction func logOutAction(){
        defaults.set(String(), forKey: "USER_ID")
        defaults.set(false, forKey: "IS_LOGGED_IN")
        defaults.set("", forKey: "USER_FB_ID")
        if AccessToken.current != nil{
            let loginManager = LoginManager()
            loginManager.logOut()
        }
        
        self.loadView()
         let vc : UserSignInController = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
                   vc.userInformationVC = self
                   self.present(vc, animated: true, completion: nil)
    }

    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the loading view
        //loadingView = customAlert.loadingAlert(uiView: self.view)

        
        self.genderPickerView.delegate = self
        self.genderPickerView.dataSource = self
        
        self.contentView.sizeToFit()
        self.scrollView.contentSize.height = self.contentView.frame.size.height
        
        
        formatter.dateFormat = "yyyy-MM-dd"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let isLoggedIn = defaults.bool(forKey: "IS_LOGGED_IN")
        if !isLoggedIn{
            let vc : UserSignInController = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
            vc.userInformationVC = self
            self.present(vc, animated: true, completion: nil)
            
        }else{
            // Get the user's information
            getUserInformation()

            self.contentView.sizeToFit()
            self.scrollView.contentSize.height = self.contentView.frame.size.height
        }
        
    }
    
    override func loadView() {
        super.loadView()
        // Check if the user is logged in.
        // If not we are going to redirect them to the login page.
        
    }
    
}
