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
    
    /*
     * Handle errors with the places location controller
     */
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    /*
     * Set the number of rows in the table.
     * There is only going to be 1 row, which will be the current location selectable row.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    /*
     * Set the content for the table view cell
     */
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
    
    /*
     * Handle the row selection.
     * This just determines if we are using the current location
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = currentLocationTableView.dequeueReusableCell(withIdentifier: "CurrentLocationCell") as! LocationTableviewCellController
                
        if #available(iOS 13.0, *) {
            if(currentLocationSelected == true){
                currentLocationSelected = false
                self.searchController?.searchBar.text = ""
                cell.selectedImageView.image = UIImage(systemName: "circle")
            }else{
                currentLocationSelected = true
                self.selectedLocation = self.currentLocation
                self.searchController?.searchBar.text = self.selectedLocation
                cell.selectedImageView.image = UIImage(systemName: "largecircle.fill.circle")
            }
        }else{
            cell.selectedImageView.image = UIImage()
        }
        self.currentLocationTableView.reloadData()
    }
    
    /*
     * Handle the save button being tapped
     * Passing the data back to the main view controller then popping the current view controller
     */
    @objc func saveLocationAction(){
        mainViewController.updateCurrentSearchLocation(location: self.selectedLocation)
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
     * Show the places autocomplete table
     */
    @objc func showLocationAutocomplete(){
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
        self.currentLocationSelected = false
        self.selectedLocation = place.formattedAddress!
        self.searchController?.searchBar.text = self.selectedLocation
        self.currentLocationTableView.reloadData()
        
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
                    self.selectedLocation = self.currentLocation
                    self.currentLocationTableView.reloadData()
                    self.currentLocationSelected = true
                    self.searchController?.searchBar.text = self.currentLocation

                }
            }
        })
    }
        
    func addNavigationItems(){
        let backButtonItem = UIButton(type: .custom)
        
       
        backButtonItem.setTitle("Back", for: .normal)
        backButtonItem.addTarget(self, action: Selector("backNavigation"), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButtonItem)
        
        let saveLocationButtonItem = UIButton(type: .custom)
        
        saveLocationButtonItem.setTitle("Save", for: .normal)
        saveLocationButtonItem.addTarget(self, action: Selector("saveLocationAction"), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveLocationButtonItem)
    }
    
    /*
     * Handl the back navigation.
     * Just popping the view controller
     */
    @objc func backNavigation(){
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad(){
        
        // Set up the navigation bac
       addNavigationItems()
        
        //self.navigationController?.navigationBar.backItem = barBackItem
        
        // Set up the location table view
        self.currentLocationTableView.delegate = self
        self.currentLocationTableView.dataSource = self
        self.currentLocationTableView.allowsSelection = true
        
        // Instantiate the results view controller for the Google Places search
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        self.currentLocationTableView.tableHeaderView = searchController?.searchBar
        
        self.searchController?.searchBar.frame.origin.y = 0
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up in the chain
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        placesClient = GMSPlacesClient.shared()
        
        getCurrentPlace()
    }
}
