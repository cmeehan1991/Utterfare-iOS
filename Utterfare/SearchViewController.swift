//
//  SearchViewController.swift
//  Utterfare
//
//  Created by Connor Meehan on 1/6/17.
//  Copyright © 2017 CBM Web Development. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage


class SearchViewController: UIViewController,CLLocationManagerDelegate, UITextFieldDelegate{

    @IBOutlet weak var searchInput: UISearchBar!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    let locationText = NSMutableAttributedString(string: "Location - ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
    
    var explorerItems: ExplorerItems!
    var searchLocation: String = String()
    var jsonData : Data = Data()
    var displayDistance = ["1 mi.", "2 mi.", "5 mi.", "10 mi.", "15 mi.", "20 mi.", "25 mi."]
    var distances = ["1","2","5", "10", "15", "20", "25"]
    var distance : String = String(), searchTerms : String = String(), offset: String = String()
    var latitude : CLLocationDegrees = CLLocationDegrees()
    var longitude : CLLocationDegrees = CLLocationDegrees()
    let locationManager = CLLocationManager()
    var manualLocation : Bool = Bool()
    var zip : String = String(), city: String = String(), state : String = String(), currentLocation : String = String()
    var itemIds: NSArray = NSArray(), itemImages: NSArray = NSArray()
    
    func updateCurrentSearchLocation(location: String){
        self.searchLocation = location
        self.locationField.text = self.searchLocation
        
        self.locationText.replaceCharacters(in: NSRange(11..<(self.locationText.length)), with: NSAttributedString(string: self.searchLocation))
        
        self.locationField.attributedText = self.locationText
        
    }
    
    @IBAction func changeSearchLocation(){
        self.locationField.resignFirstResponder()
        
        let locationVc = storyboard?.instantiateViewController(withIdentifier: "Location View Controller") as! LocationViewController
        locationVc.mainViewController = self
        
        self.navigationController?.pushViewController(locationVc, animated: true)
    }
    
    /*
     * Do the search on submit
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        self.searchTerms = (searchInput.text)!
        
        activityIndicatorView.startAnimating()
        
        let searchModel = SearchModel()
        //searchModel.delegate = self
        self.offset = "0"
        searchModel.doSearch(terms: self.searchTerms, distance: self.distance, location: self.currentLocation, offset: self.offset)
        return false
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
                    self.currentLocation = String(describing: placemark.location?.coordinate.latitude as! Double) + ":" +  String(describing: placemark.location?.coordinate.longitude as! Double)
                    
                    let attributedCurrentLocation:NSAttributedString = NSAttributedString(string: self.city + ", " + self.state + " " + self.zip, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                                        
                    let locationText = NSMutableAttributedString(string: "Location - ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
                    
                    locationText.append(attributedCurrentLocation)
                                        
                    self.locationField.attributedText = locationText
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

        //UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        //self.navigationController?.navigationBar.tintColor = UIColor(red: 0.01, green: 0.66, blue: 0.96, alpha: 1.0)
        
        //activityIndicatorView.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //self.locationField.isUserInteractionEnabled = false
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
