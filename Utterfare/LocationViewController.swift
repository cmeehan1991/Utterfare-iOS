//
//  LocationViewController.swift
//  Utterfare
//
//  Created by Connor Meehan on 12/13/19.
//  Copyright © 2019 Utterfare. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSAutocompleteViewControllerDelegate, GMSAutocompleteResultsViewControllerDelegate{

    @IBOutlet weak var currentLocationTableView: UITableView!

    var mainViewController: SearchViewController!
    var placesClient: GMSPlacesClient!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    var currentLocationSelected: Bool = false
    var currentLocation:  String = String()
    var selectedLocation : String = String()
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        self.currentLocationSelected = false
        self.selectedLocation = place.formattedAddress ?? self.currentLocation
        self.searchController?.searchBar.text = self.selectedLocation
        
        self.currentLocationTableView.reloadData()
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = currentLocationTableView.dequeueReusableCell(withIdentifier: "CurrentLocationCell") as! LocationTableviewCellController
        cell.currentLocationLabel.text = currentLocation
        
        if #available(iOS 13.0, *) {
            if(currentLocationSelected == true){
                cell.selectedImageView.image = UIImage(systemName: "largecircle.fill.circle")
            }else{
                cell.selectedImageView.image = UIImage(systemName: "circle")
            }
        }else{
            cell.selectedImageView.image = UIImage()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected")
        let cell = currentLocationTableView.dequeueReusableCell(withIdentifier: "CurrentLocationCell") as! LocationTableviewCellController
        
        if(currentLocationSelected){
            if #available(iOS 13.0, *){
                cell.selectedImageView.image = UIImage(systemName: "circle")
            }
        }else{
            if #available(iOS 13.0, *) {
                cell.selectedImageView.image = UIImage(systemName: "largecircle.fill.circle")
            }
        }
    }
    
    @IBAction func sendLocationBack(){
        mainViewController.updateCurrentSearchLocation(location: self.selectedLocation)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showLocationAutocomplete(){
        print("Show location autocomplete")
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        // Specify a filter
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    // Handle the user's selection
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place: \(place)")
        dismiss(animated: true, completion: nil)
    }
    
    // Handle errors
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // Handle was cancelled
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func getCurrentPlace(){
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList{
                let place = placeLikelihoodList.likelihoods.first?.place
                
                if let place = place{
                    self.currentLocation = place.formattedAddress?.components(separatedBy: ", ").joined(separator: ", ") as! String
                    self.currentLocationTableView.reloadData()
                    self.currentLocationSelected = true
                    self.searchController?.searchBar.text = self.currentLocation
                    
                    
                }
            }
        })
    }
        
    override func viewDidLoad(){
        
        
        self.currentLocationTableView.delegate = self
        self.currentLocationTableView.dataSource = self
        
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar
        searchController?.searchBar.sizeToFit()
        //navigationItem.titleView = searchController?.searchBar
        self.currentLocationTableView.tableHeaderView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up in the chain
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        placesClient = GMSPlacesClient.shared()
        
        getCurrentPlace()
    }
}
