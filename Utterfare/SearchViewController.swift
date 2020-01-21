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
    var distance : String = String("10"), searchTerms : String = String(), page: Int = 1
    var updating: Bool = false
    let locationManager = CLLocationManager()
    var zip : String = String(), city: String = String(), state : String = String(), currentLocation : String = String()
    
    var itemsId: NSMutableArray = NSMutableArray(), itemsName: NSMutableArray = NSMutableArray(), restaurantsName: NSMutableArray = NSMutableArray(), itemsImage: NSMutableArray = NSMutableArray(), itemsShortDescription: NSMutableArray = NSMutableArray()
   
    let distancesValue: Array<String> = ["1", "2", "5", "10", "15", "20", "25"]
    var distancesOptions: Array<String> = ["1 Mile", "2 Miles", "5 Miles", "10 Miles", "15 Miles", "20 Miles", "25 Miles"]
    
    func itemsDownloaded(hasResults: Bool, itemsId: NSArray, itemsNames: NSArray, restaurantsNames: NSArray, itemsImages: NSArray, itemsShortDescription: NSArray) {
                
        if hasResults == true && itemsId.count > 0{
            if updating == false {
                self.itemsId = itemsId as! NSMutableArray
                self.itemsName = itemsNames as! NSMutableArray
                self.restaurantsName = restaurantsNames as! NSMutableArray
                self.itemsImage = itemsImages as! NSMutableArray
                self.itemsShortDescription = itemsShortDescription as! NSMutableArray
            }else{
                self.itemsId.addObjects(from: itemsId as! [String])
                self.itemsName.addObjects(from: itemsNames as! [String])
                self.restaurantsName.addObjects(from: restaurantsName as! [String])
                self.itemsImage.addObjects(from: itemsImages as! [String])
                self.itemsShortDescription.addObjects(from: itemsShortDescription as! [String])
                updating = false
            }
            
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
     * Load more items
     */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (yOffset > (contentHeight - scrollView.frame.size.height - 250) && self.itemsId.count % 10 == 0 && updating == false){
            self.page = self.page + 1
            searchModel.doSearch(terms: self.searchTerms, distance: self.distance, location: self.searchLocation, page: String(describing: page))
            updating = true
        }
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.distance = distancesValue[row]
        self.page = 1
        
        if !self.searchTerms.isEmpty{
            searchModel.doSearch(terms: searchTerms, distance: self.distance, location: self.searchLocation, page: "1")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = resultsTable.dequeueReusableCell(withIdentifier: "ResultCell") as! ResultCellViewController
        cell.itemName.text = self.itemsName[indexPath.row] as? String
        cell.restaurantName.text = self.restaurantsName[indexPath.row] as? String
        cell.itemImage.sd_setImage(with: URL(string: self.itemsImage[indexPath.row] as! String),  placeholderImage: UIImage(named: "Utterfare Base Logo - No Background") )
        cell.itemShortDescription.text = self.itemsShortDescription[indexPath.row] as? String
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
        
        self.page = 1
        self.distance = self.distancesValue[self.searchDistancePickerView.selectedRow(inComponent: 0)]
        if self.resultsTable.isHidden == false{
            self.resultsTable.isHidden = true
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.isHidden = false
        }
        searchModel.doSearch(terms: self.searchTerms, distance: self.distance, location: self.searchLocation, page: String(describing:self.page))
                
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
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else{
            return false
        }

        let alert = UIAlertController(title: "Request Location", message: "Please allow Utterfare to access your location. Your location will be used to provide more accurate search results and will be displayed on the search window. Your location will not be shared with other users or vendors.", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title:"Cancel", style: .cancel, handler:{_ in
            approved = false
        })
        let approveAction = UIAlertAction(title:"Settings", style: .default, handler: {_ in
            UIApplication.shared.open(settingsUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:nil )
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
