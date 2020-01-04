//
//  UserSignUpViewController.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/31/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import UIKit

class UserSignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UserSignUpProtocol, UITextFieldDelegate{
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var cellPhoneTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var genderPickerView: UIPickerView!
    @IBOutlet weak var birthdayPickerView: UIDatePicker!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    let defaults = UserDefaults.standard
    let customAlert = CustomAlerts()
    var loadingView: UIView = UIView()
    var activeField: UITextField = UITextField()
    var password: String = String(), confirmPassword: String = String(), email: String = String(), firstName: String = String(), lastName: String = String(), city: String = String(), state: String = String()
    var genders: Array<String> = ["", "Male", "Female", "Other"]
    
    /*
     * Set the row values for the gender pickerview
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    /*
     * Set the number of components (columns) in the picker view
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /*
     * Set the number of items in the gender pickerview
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    /*
     * Handle the response from the user signing up
     */
    func userSignUp(success: Bool, response: String, userId: String) {
        self.loadingView.removeFromSuperview()

        if success == true{
            goToView()
        }else{
            explainFail(fail: response)
        }
    }
    
    /*
     * If signing up failed, explain why to the user.
     */
    func explainFail(fail: String){
        let alert = UIAlertController(title: "Error", message: fail, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
     * Go to the previous view controller
     */
    func goToView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Validate the required user inputs
     * Required: email, password, birthday, city, postal code, cellphone number
     */
    func validateInformation() -> Bool{
        
        if(emailAddressTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailAddressTextField.text!.isEmpty){
            return false
        }
        
        if(cellPhoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cellPhoneTextField.text!.isEmpty){
            return false
        }
        
        if(firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || firstNameTextField.text!.isEmpty){
            return false
        }
        
        if(lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text!.isEmpty){
            return false
        }
        
        if(cityTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cityTextField.text!.isEmpty){
            return false
        }
        
        if(postalCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || postalCodeTextField.text!.isEmpty){
            return false
        }
        
        if(passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text!.isEmpty || passwordTextField.text! != confirmPasswordTextField.text!){
            return false
        }
        
        return true
    }
    

    /*
     * Handle the sign up button on touch up inside
     */
    @IBAction func signUpAction(){
        if validateInformation() == true{
            let signUpModel: UserSignupModel = UserSignupModel()
            signUpModel.delegate = self
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let birthday = dateFormatter.string(from: birthdayPickerView.date)
            
            signUpModel.signUp(emailAddress: emailAddressTextField.text!, cellPhone: cellPhoneTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, city: cityTextField.text!, state: stateTextField.text!, postalCode: postalCodeTextField.text!, gender: genders[genderPickerView.selectedRow(inComponent: 0)], birthday: birthday, password: passwordTextField.text!)
        }else{
            let alert = UIAlertController(title: "Invalid Info", message: "Please check to make sure you entered all the required information.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Did begin editing")
        
        let top = textField.frame.origin.y - 40
        let point = CGPoint(x: 0, y: top)
        self.scrollView.setContentOffset(point, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.genderPickerView.delegate = self
        self.genderPickerView.dataSource = self
        
        self.contentView.sizeToFit()
        self.scrollView.contentSize.height = self.contentView.frame.size.height + 100
        
        print(self.contentView.frame.size)
        print(self.scrollView.contentSize)
        
        self.emailAddressTextField.becomeFirstResponder()
        
        self.confirmPasswordTextField.delegate = self
        self.passwordTextField.delegate = self
    }
}
