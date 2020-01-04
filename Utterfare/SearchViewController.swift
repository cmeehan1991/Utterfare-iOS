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


class SearchViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, SearchControllerProtocol, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    

    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var resultsTable: UITableView!
    @IBOutlet weak var searchDistancePickerView: UIPickerView!
    
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
    let distancesValue: Array<String> = ["1", "2", "5", "10", "15", "20", "25"]
    var distancesOptions: Array<String> = ["1 Mile", "2 Miles", "5 Miles", "10 Miles", "15 Miles", "20 Miles", "25 Miles"]
    func itemsDownloaded(hasResults: Bool, itemsId: Array<String>, itemsNames itemsName: Array<String>, restaurantsNames restaurantsName: Array<String>, itemsImages itemsImage: Array<String>, itemsShortDescription: Array<String>) {
                
        if hasResults == true && itemsId.count > 0{
            
            self.itemsId = itemsId
            self.itemsName = itemsName
            self.restaurantsName = restaurantsName
            self.itemsImage = itemsImage
            self.itemsShortDescription = itemsShortDescription
                        
            self.resultsTable.reloadData()
            self.resultsTable.isHidden = false
            self.activityIndicatorView.stopAnimating()
        }else{
            print("No results")
            handleNoResults()
        }
    }
    
    func handleNoResults(){
        let label = UILabel()
        label.text = "No Results\nTry something different"
        label.textAlignment = .center
        
        self.resultsTable.backgroundView = label
        self.resultsTable.separatorStyle = .none
        self.resultsTable.reloadData()
        self.resultsTable.isHidden = false
    }
      
    
    
    /*
     * Set the picker view values
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return distancesOptions[row]
    }
    
    /*
     * Set the number of rows in the distances picker view
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return distancesValue.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
        vc.itemId = self.itemsId[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateCurrentSearchLocation(location: String){
        self.searchLocation = location
        self.locationField.text = self.searchLocation
        
        self.locationText.replaceCharacters(in: NSRange(11..<(self.locationText.length)), with: NSAttributedString(string: self.searchLocation, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
        
        
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
        activityIndicatorView.isHidden = false
        
        self.offset = "0"
        self.page = "1"
        self.distance = self.distancesValue[self.searchDistancePickerView.selectedRow(inComponent: 0)]
        if self.resultsTable.isHidden == false{
            self.resultsTable.isHidden = true
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.isHidden = false
        }
        searchModel.doSearch(terms: self.searchTerms, distance: self.distance, location: self.searchLocation, offset: self.offset, page: self.page)
                
        return false
    }
    
    // Get the user's location
    func getUserLocation(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if error != nil{
                return
            }
            
            if (placemarks != nil) {
                if (placemarks?.count)! > 0{
                    let placemark = (placemarks?[0])! as CLPlacemark
                    
                    // Check if an exact address is available, if not then we just use the city/state
                    if placemark.subThoroughfare != nil{
                        self.currentLocation = placemark.subThoroughfare! + " " + placemark.thoroughfare! + ", " + placemark.locality! + ", " + placemark.administrativeArea! + ", " + placemark.postalCode!
                    }else{
                        self.currentLocation = placemark.locality! + ", " + placemark.administrativeArea! + ", " + placemark.postalCode!
                    }
                    
                    self.zip = placemark.postalCode!
                    self.city = placemark.subThoroughfare! + " " + placemark.thoroughfare! + ", " + placemark.locality!
                    self.state = placemark.administrativeArea!

                    self.currentLocation = self.city + ", " + self.state + " " + self.zip
                    let attributedCurrentLocation:NSAttributedString = NSAttributedString(string:self.currentLocation, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])

                    self.searchLocation = self.currentLocation
                    
                    self.locationText.append(attributedCurrentLocation)
                                        
                    self.locationField.attributedText = self.locationText
                    self.locationManager.stopUpdatingLocation()
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
        
        // Initialize the distance picker view
        self.searchDistancePickerView.delegate = self
        self.searchDistancePickerView.dataSource = self
        self.searchDistancePickerView.selectRow(3, inComponent: 0, animated: true)
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
