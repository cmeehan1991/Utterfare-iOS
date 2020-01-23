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

class HomeController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, HomeItemsProtocol{

    @IBOutlet weak var homeMasonryCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    let manualLocationTextField: UITextField = UITextField()
    var locationManager: CLLocationManager = CLLocationManager()
    var latitude : CLLocationDegrees = CLLocationDegrees()
    var longitude : CLLocationDegrees = CLLocationDegrees()
    var address: String = String()
    var gotAddress: Bool = false
    private let refreshControl = UIRefreshControl()
    var page: Int = 1;
    var updating: Bool = false
    
    var homeItemsIds: NSMutableArray = NSMutableArray(), homeItemsNames: NSMutableArray = NSMutableArray(), homeItemsImages: NSMutableArray = NSMutableArray()
    
    func downloadHomeItems(itemIds: NSArray, itemNames: NSArray, itemImages: NSArray) {
        if(itemIds.count == 0){
            self.handleNoResults(collectionView: self.homeMasonryCollectionView)
            return
        }
        if updating == false || self.homeItemsIds.count == 0 {

            
            self.homeItemsIds = itemIds as! NSMutableArray
            self.homeItemsNames = itemNames as! NSMutableArray
            self.homeItemsImages = itemImages as! NSMutableArray
        }else{
            
            self.homeItemsIds.addObjects(from: itemIds as! [String])
            self.homeItemsNames.addObjects(from: itemNames as! [String])
            self.homeItemsImages.addObjects(from: itemImages as! [String])

        }
        self.homeMasonryCollectionView.reloadData()
        self.homeMasonryCollectionView.isHidden = false
        
        if self.activityIndicator.isAnimating{
            self.activityIndicator.stopAnimating()
        }
        
        if self.updating == true{
            self.updating = false
        }
        
        if self.refreshControl.isRefreshing{
            self.refreshControl.endRefreshing()
        }
    }
        
    func handleNoResults(collectionView: UICollectionView){
        let label = UILabel()
        label.text = "There are no items nearby"
        label.textAlignment = .center
        
        collectionView.backgroundView = label
        collectionView.reloadData()
        collectionView.isHidden = false
        
        activityIndicator.stopAnimating()
        
        if self.refreshControl.isRefreshing{
            self.refreshControl.endRefreshing()
        }
        
        if self.updating == true{
            self.updating = false
        }
    }
        
    /*
    * Set the number of items in the collection view
    */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.homeItemsIds.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = homeMasonryCollectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! CollectionViewCellController
        
        cell.itemTitle.text = self.homeItemsNames[indexPath.item] as? String
        cell.itemImage.sd_setImage(with: URL(string: self.homeItemsImages[indexPath.row] as! String), placeholderImage: UIImage(named: "Utterfare Base Logo - No Background"))
        cell.itemImage.frame.size = CGSize(width: cell.frame.size.width, height: cell.frame.size.width)
        
        
        cell.frame.size = CGSize(width: (collectionView.contentSize.width/2)-12, height: collectionView.contentSize.width/2 - 12)
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        //let flowLayout = collectionView as? UICollectionViewFlowLayout
        //let space: CGFloat = (flowLayout?.minimumInteritemSpacing ?? 0.0) + (flowLayout?.sectionInset.left ?? 0.0) + (flowLayout?.sectionInset.right ?? 0.0)
        
        //let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        
        let padding: CGFloat = 50
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedItemId: String = String()

        selectedItemId = self.homeItemsIds[indexPath.row] as! String
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewItemController") as? ViewItemController
        
        vc?.itemId = selectedItemId
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if(offsetY > (contentHeight - scrollView.frame.size.height - 500) && updating == false){
            self.page = self.page + 1
            self.getHomeItems(address: self.address, page: String(describing: page))
            updating = true
        }
        
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
    
    func getHomeItems(address: String, page: String){
        
        let homeItems = HomeItems()
        homeItems.delegate = self
        
        homeItems.getHomeItems(address: self.address, numberOfItems: "25", page: page)
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
                    
                    self.getHomeItems(address: self.address, page: "1")
                }
            }
        })
    }
    
    @objc func refreshHomeView(sender: Any){
        self.getHomeItems(address: self.address, page: "1")
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.homeMasonryCollectionView.allowsSelection = true
        
    }
    override func viewDidLoad(){
        super.viewDidLoad()

        getUserLocation()
        
        self.homeMasonryCollectionView.dataSource = self
        self.homeMasonryCollectionView.delegate = self
        
        // Add refresh control to the collectionview
        self.homeMasonryCollectionView.refreshControl = self.refreshControl
        
        
        self.refreshControl.addTarget(self, action: #selector(self.refreshHomeView(sender:)), for: .valueChanged)
        let color = UIColor(displayP3Red: 0.25, green: 0.72, blue: 0.85, alpha: 1.0)
        let attributes = [NSAttributedString.Key.foregroundColor: color]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Fetching Items..", attributes: attributes)
        self.refreshControl.tintColor = color
        
        activityIndicator.startAnimating()
        
        
    }
}
/*
extension HomeController: MasonryLayoutDelegate{
    func collectionView(_ collectionView: UICollectionView, heightForObjectAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        let imageUrl: String = homeItemsImages[indexPath.item] as! String
        let url = URL(string: imageUrl)
        var image: UIImage = UIImage()
        if let data = try? Data(contentsOf: url!){
            image = UIImage(data: data)!
        }
        
        var cellSize = image.size.height
        if image.size.height > collectionView.frame.size.width/2 || cellSize == 0{
            let imageSize = collectionView.frame.size.width/2 - 24
            cellSize = imageSize
        }
                
        return cellSize
    }
    
    func theNumberOfItemsInCollectionView() -> Int {
        return homeItemsIds.count
    }
}*/
