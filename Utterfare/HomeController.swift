//
//  Home Controller.swift
//  Utterfare
//
//  Created by Connor Meehan on 7/11/19.
//  Copyright © 2019 Utterfare. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import CoreLocation

class HomeController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, HomeItemsProtocol{

    @IBOutlet weak var topItemsCollectionView: UICollectionView!
    @IBOutlet weak var topPicksCollectionView: UICollectionView!
    @IBOutlet weak var nearbyPicksCollectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    let manualLocationTextField: UITextField = UITextField()
    var locationManager: CLLocationManager = CLLocationManager()
    var latitude : CLLocationDegrees = CLLocationDegrees()
    var longitude : CLLocationDegrees = CLLocationDegrees()
    var address: String = String()
    var gotAddress: Bool = false
    
    var topItemsIds: NSArray = NSArray(), topPicksIds: NSArray = NSArray(), nearbyItemsIds: NSArray = NSArray(), topItemsImages: NSArray = NSArray(), topPicksImages: NSArray = NSArray(), nearbyItemsImages: NSArray = NSArray(), topItemsNames: NSArray = NSArray(), topPicksNames: NSArray = NSArray(), nearbyItemsNames: NSArray = NSArray()
    
    func downloadTopItems(itemIds: NSArray, itemNames: NSArray, itemImages: NSArray) {
        self.topItemsIds = itemIds
        self.topItemsImages = itemImages
        self.topItemsNames = itemNames
        
        self.topItemsCollectionView.reloadData()
    }
    
    func downloadTopPicks(itemIds: NSArray, itemNames: NSArray, itemImages: NSArray) {
    
        if itemIds.count > 0{
            self.topPicksIds = itemIds
            self.topPicksImages = itemImages
            self.topPicksNames = itemNames
            
            self.topPicksCollectionView.reloadData()
        }else{
            self.handleNoResults(collectionView: self.topPicksCollectionView)

        }
    }
    
    func downloadLocalPicks(itemIds: NSArray, itemNames: NSArray, itemImages: NSArray) {

        if itemIds.count > 0{
            self.nearbyItemsIds = itemIds
            self.nearbyItemsImages = itemImages
            self.nearbyItemsNames = itemNames
            
            self.nearbyPicksCollectionView.reloadData()
            
            scrollView.isHidden = false
            activityIndicator.stopAnimating()
        }else{
            self.handleNoResults(collectionView: self.nearbyPicksCollectionView)
        }
    }
    
    func handleNoResults(collectionView: UICollectionView){
        let label = UILabel()
        label.text = "There are no items nearby"
        label.textAlignment = .center
        
        collectionView.backgroundView = label
        //collectionView.separatorStyle = .none
        collectionView.reloadData()
        collectionView.isHidden = false
        
        activityIndicator.stopAnimating()
        scrollView.isHidden = false
    }
    
    /*
    * Set the number of items in the collection view
    */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.topItemsCollectionView{
            return topItemsIds.count
        }
        
        if collectionView == self.topPicksCollectionView{
            return topPicksIds.count
        }
        
        if collectionView == self.nearbyPicksCollectionView{
            return nearbyItemsIds.count
        }
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.topItemsCollectionView{
            let cell = topItemsCollectionView.dequeueReusableCell(withReuseIdentifier: "topItemsCell", for: indexPath) as! CollectionViewCellController
            cell.itemTitle.text = self.topItemsNames[indexPath.row] as? String
            cell.itemImage.sd_setImage(with: URL(string: self.topItemsImages[indexPath.row] as! String))
            return cell
        }
        
        if collectionView == self.topPicksCollectionView{
            let cell = topPicksCollectionView.dequeueReusableCell(withReuseIdentifier: "topPicksCell", for: indexPath) as! CollectionViewCellController
            cell.itemTitle.text = self.topPicksNames[indexPath.row] as? String
            cell.itemImage.sd_setImage(with: URL(string: self.topPicksImages[indexPath.row] as! String))
            return cell
        }
        
        if collectionView == self.nearbyPicksCollectionView{
            let cell = nearbyPicksCollectionView.dequeueReusableCell(withReuseIdentifier: "nearbyItemsCell", for: indexPath) as! CollectionViewCellController
            cell.itemTitle.text = self.nearbyItemsNames[indexPath.row] as? String
            cell.itemImage.sd_setImage(with: URL(string: self.nearbyItemsImages[indexPath.row] as! String))
            return cell
        }
        
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedItemId: String = String()
        if collectionView == self.topItemsCollectionView{
            selectedItemId = self.topItemsIds[indexPath.row] as! String
        }else if collectionView == self.topPicksCollectionView{
            selectedItemId = self.topPicksIds[indexPath.row] as! String
        }else if collectionView == self.nearbyPicksCollectionView{
            selectedItemId = self.nearbyItemsIds[indexPath.row] as! String
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewItemController") as? ViewItemController
        
        vc?.itemId = selectedItemId
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func handleManualLocation(alertAction: UIAlertAction!){
        self.address = self.manualLocationTextField.text ?? "6 Kent Ct., Hilton Head Island, SC 29926"
    }
    
    func manualLocationConfigurationHandler(textField: UITextField!){
        if textField != nil{
            self.manualLocationTextField.text = textField.text
            self.address = textField.text ?? "6 Kent Ct., Hilton Head Island, SC 29926"
        }
    }
    
    func getUserLocation(){
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }else{
            let locationAlert = UIAlertController(title: "Location Required", message: "You must add a location to use this application.", preferredStyle: .alert)
            
            locationAlert.addTextField(configurationHandler: manualLocationConfigurationHandler)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: handleManualLocation)
            locationAlert.addAction(okAction)
            
            self.present(locationAlert, animated: true, completion: nil)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latitude = (locationManager.location?.coordinate.latitude)!
        self.longitude = (locationManager.location?.coordinate.longitude)!
        self.getAddress()
        locationManager.stopUpdatingLocation()
    }
    
    func getHomeItems(address: String){
        
        let homeItems = HomeItems()
        homeItems.delegate = self
        
        homeItems.getTopItems()
        homeItems.getRecommendations(address: self.address)
        homeItems.getLocalItems(address: self.address)
    }
    /**
     * Get the user's location
     */
    func getAddress(){
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if error != nil{
                print(error ?? "Get location error not available")
                return
            }
            if (placemarks != nil && self.gotAddress == false) {
                if (placemarks?.count)! > 0{
                    
                    self.gotAddress = true
                    
                    let placemark = (placemarks?[0])! as CLPlacemark
                    
                    // Check if an exact address is available, if not then we just use the city/state
                    if placemark.subThoroughfare != nil{
                        self.address = placemark.subThoroughfare! + " " + placemark.thoroughfare! + ", " + placemark.locality! + ", " + placemark.administrativeArea! + ", " + placemark.postalCode!
                    }else{
                        self.address = placemark.locality! + ", " + placemark.administrativeArea! + ", " + placemark.postalCode!
                    }
                    self.getHomeItems(address: self.address)
                }
            }
        })
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    override func viewDidLoad(){
        getUserLocation()
        
        self.topItemsCollectionView.dataSource = self
        self.topItemsCollectionView.delegate = self
        self.topPicksCollectionView.dataSource = self
        self.topPicksCollectionView.delegate = self
        self.nearbyPicksCollectionView.dataSource = self
        self.nearbyPicksCollectionView.delegate = self
        
        contentView.sizeToFit()
        
        scrollView.isHidden = true
        activityIndicator.startAnimating()
        scrollView.isScrollEnabled = true

        scrollView.contentSize = contentView.frame.size
    }
    
    
}
