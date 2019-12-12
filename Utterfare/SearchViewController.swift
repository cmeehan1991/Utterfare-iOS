//
//  SearchViewController.swift
//  Utterfare
//
//  Created by Connor Meehan on 1/6/17.
//  Copyright © 2017 CBM Web Development. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, SearchControllerProtocol, UITextFieldDelegate{

    
    
    @IBOutlet weak var searchTermsInput: UITextField!
    @IBOutlet weak var searchDistancePicker: UIPickerView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var searchButton : UIButton!
    
    var jsonData : Data = Data()
    var displayDistance = ["1 mi.", "2 mi.", "5 mi.", "10 mi.", "15 mi.", "20 mi.", "25 mi."]
    var distances = ["1","2","5", "10", "15", "20", "25"]
    var distance : String = String(), searchTerms : String = String(), offset: String = String()
    var latitude : CLLocationDegrees = CLLocationDegrees()
    var longitude : CLLocationDegrees = CLLocationDegrees()
    let locationManager = CLLocationManager()
    var manualLocation : Bool = Bool()
    var zip : String = String(), city: String = String(), state : String = String(), currentLocation : String = String()
    var itemName : NSArray = NSArray(), itemImages : NSArray = NSArray(), restaurantNames : NSArray = NSArray(), itemDescriptions : NSArray = NSArray(), restaurantURLs : NSArray = NSArray(), restaurantDistances : NSArray = NSArray(), restaurantPhones : NSArray = NSArray(), restaurantAddresses : NSArray = NSArray()
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    /**
     * Allow the user to manually input their location.
     * When the user taps the button an alert will present itself, which will have a textfield allowing the user to input their own location.
     */
    @IBAction func changeLocationButtonPressed(_ sender: Any) {
        let changeLocationAction = UIAlertController(title: "Change Location", message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {
            alert-> Void in
            self.locationManager.stopUpdatingLocation()
            self.currentLocation = (changeLocationAction.textFields?.first!.text)!
            self.locationButton.setTitle(self.currentLocation, for: .normal)
            self.manualLocation = true
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        changeLocationAction.addTextField(configurationHandler: {(locationTextField) -> Void in
            if self.manualLocation == true{
                locationTextField.text = self.currentLocation
            }else{
                locationTextField.text = self.city + ", " + self.state
            }
            locationTextField.placeholder = "Zip Code or City, St"
        })
        changeLocationAction.addAction(defaultAction)
        changeLocationAction.addAction(cancelAction)
        self.present(changeLocationAction, animated: true, completion: nil)
    }
    
    /**
     * Get the downloaded items and assign them to their class variables
     */
    func itemsDownloaded(hasResults: Bool, itemIds: Array<String>, dataTables: Array<String>, itemNames: Array<String>, restaurantNames: Array<String>, restaurantIds: Array<String>, itemImages: Array<String>) {
        if hasResults == true{
            let vc = storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
            vc.terms = self.searchTerms
            vc.distance = self.distance
            vc.location = self.currentLocation
            vc.itemIds = itemIds
            vc.dataTables = dataTables
            vc.itemNames = itemNames
            vc.restaurantNames = restaurantNames
            vc.restaurantIds = restaurantIds
            vc.itemImages = itemImages
            
            activityIndicatorView.stopAnimating()
            self.navigationController?.pushViewController(vc, animated: true);
            
        }else{
            let alert = UIAlertController(title: "No Results", message: "Let's try something else. It looks like your search didn't return any results", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated:true, completion: nil)
            
            activityIndicatorView.stopAnimating()
        }
    }
    
    /*
     * The search button was tapped.
     * This will initiate the search
     */
    @IBAction func performSearchButtonPressed(_ sender: Any) {
        
        self.view.endEditing(true);
        self.searchTerms = (searchTermsInput.text)!
        
        activityIndicatorView.startAnimating()
        let searchModel = SearchModel()
        searchModel.delegate = self
        self.offset = "0";
        searchModel.doSearch(terms: self.searchTerms, distance: self.distance, location: self.currentLocation, offset: "0")
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        self.searchTerms = (searchTermsInput.text)!
        
        activityIndicatorView.startAnimating()
        
        let searchModel = SearchModel()
        searchModel.delegate = self
        self.offset = "0"
        searchModel.doSearch(terms: self.searchTerms, distance: self.distance, location: self.currentLocation, offset: self.offset)
        return false
    }
    
    /*
     * Set up the picker views
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return distances.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return displayDistance[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.distance = distances[row]
    }
        
    // Get the user's location
    func getUserLocation(){
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }else{
            self.locationButton.setTitle("Set Your Location", for: .normal)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latitude = (locationManager.location?.coordinate.latitude)!
        self.longitude = (locationManager.location?.coordinate.longitude)!
        getAddress()
    }
    
    /**
    * Get the user's location
    */
    func getAddress(){
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if error != nil{
                return
            }
            if (placemarks != nil) {
                if (placemarks?.count)! > 0{
                    let placemark = (placemarks?[0])! as CLPlacemark
                    self.zip = placemark.postalCode!
                    self.city = placemark.subThoroughfare! + " " + placemark.thoroughfare! + ", " + placemark.locality!
                    self.state = placemark.administrativeArea!
                    self.locationButton.setTitle(self.city + ", " + self.state, for: UIControl.State.normal)
                    self.currentLocation = String(describing: placemark.location?.coordinate.latitude as! Double) + ":" +  String(describing: placemark.location?.coordinate.longitude as! Double)
                }
            }
        })
    }
    
    func requestLocation()->Bool{
        var approved = false
        let locationURL = URL(string: "App-Prefs:root=Privacy&path=LOCATION")
        let alert = UIAlertController(title: "Request Location", message: "Please allow Utterfare to access your location. Your location will be used to provide more accurate search results and will be displayed on the search window. Your location will not be shared with other users or vendors.", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title:"Cancel", style: .cancel, handler:{_ in
            approved = false
        })
        let approveAction = UIAlertAction(title:"Settings", style: .default, handler: {_ in
            UIApplication.shared.open(locationURL!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:nil)
            approved = true
        })
        alert.addAction(cancelAction)
        alert.addAction(approveAction)
        self.present(alert, animated:true, completion:nil)
        return approved
    }
    
    override func loadView(){
        super.loadView()
       // self.activityIndicatorView.hidesWhenStopped = true
        getUserLocation()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        title = "Utterfare"
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.01, green: 0.66, blue: 0.96, alpha: 1.0)
       // activityIndicatorView.hidesWhenStopped = true
        //self.searchButton.layer.cornerRadius = 2
        //self.searchDistancePicker.delegate = self
        //self.searchDistancePicker.dataSource = self
        //self.searchTermsInput.delegate = self
        
        //self.distance = distances[0]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
