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


class SearchViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, SearchControllerProtocol, UITextFieldDelegate{

    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var resultsTable: UITableView!
    
    var searchModel: SearchModel!
    let locationText = NSMutableAttributedString(string: "Location - ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
    var explorerItems: ExplorerItems!
    var searchLocation: String = String()
    var latitude: CLLocationDegrees = CLLocationDegrees(), longitude: CLLocationDegrees = CLLocationDegrees()
    var jsonData : Data = Data()
    var distance : String = String("10"), searchTerms : String = String(), offset: String = String(), page: String = String()
    let locationManager = CLLocationManager()
    var zip : String = String(), city: String = String(), state : String = String(), currentLocation : String = String()
    var itemsId: Array<String> = Array(), itemsName: Array<String> = Array(), restaurantsName: Array<String> = Array(), itemsImage: Array<String> = Array(), itemsShortDescription: Array<String> = Array()
    
    func itemsDownloaded(hasResults: Bool, itemsId: Array<String>, itemsNames itemsName: Array<String>, restaurantsNames restaurantsName: Array<String>, itemsImages itemsImage: Array<String>, itemsShortDescription: Array<String>) {
                
        if hasResults == true{
            
            self.itemsId = itemsId
            self.itemsName = itemsName
            self.restaurantsName = restaurantsName
            self.itemsImage = itemsImage
            self.itemsShortDescription = itemsShortDescription
                        
            self.resultsTable.reloadData()
            self.resultsTable.isHidden = false
            self.activityIndicatorView.stopAnimating()
        }else{
            handleNoResults()
        }
    }
    
    func handleNoResults(){
        print("No results")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = resultsTable.dequeueReusableCell(withIdentifier: "ResultCell") as! ResultCellViewController
        cell.itemName.text = self.itemsName[indexPath.row]
        cell.restaurantName.text = self.restaurantsName[indexPath.row]
        cell.itemImage.sd_setImage(with: URL(string: self.itemsImage[indexPath.row]))
        cell.itemShortDescription.text = self.itemsShortDescription[indexPath.row]
        cell.itemShortDescription.textContainer.lineBreakMode = .byWordWrapping
        cell.itemShortDescription.sizeToFit()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsId.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewItemController") as! ViewItemController
        vc.itemId = self.itemsId[indexPath.row] as! String
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
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
                
        self.searchTerms = searchInput.text!
        
        activityIndicatorView.startAnimating()

        self.offset = "0"
        self.page = "1"
        

        searchModel.doSearch(terms: self.searchTerms, distance: self.distance, location: self.currentLocation, offset: self.offset, page: self.page)
        
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

                    self.currentLocation = self.city + ", " + self.state + " " + self.zip
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
       
        // Initialize the results table
        self.resultsTable.isHidden = true
        self.resultsTable.delegate = self
        self.resultsTable.dataSource = self
        
        // Initialize the textfield
        self.searchInput.delegate = self
        
    
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        activityIndicatorView.stopAnimating()
        
        // Instantiate the search model
        self.searchModel = SearchModel()
        self.searchModel.delegate = self
        getUserLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
