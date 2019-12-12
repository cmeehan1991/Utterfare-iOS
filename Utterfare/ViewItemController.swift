//
//  ViewItemController.swift
//  Utterfare
//
//  Created by Connor Meehan on 1/6/17.
//  Copyright © 2017 CBM Web Development. All rights reserved.
//

import UIKit
import SDWebImage

class ViewItemController: UIViewController, ViewItemControllerProtocol, AddItemProtocol{
   
    // Outlets
    @IBOutlet weak var itemDescriptionTextArea: UITextView!
    @IBOutlet weak var restaurantURLButton: UIButton!
    @IBOutlet weak var restaurantPhoneNumberButton: UIButton!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var restaurantNameButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    // Initialize the variables
    var itemId: String = String(), dataTable: String = String(), itemName : String = String(), itemImage : String = String(), itemDescription : String = String(), companyName : String = String(), url : String = String(), phone: String = String(), address : String = String(), restaurantDistance : String = String()
    let customAlert: CustomAlerts = CustomAlerts()
    let defaults: UserDefaults = UserDefaults()
    let viewItemModel = ViewItemModel()
    var myItems: MyItemsModel = MyItemsModel()
    var loadingView: UIView = UIView()
    
    /*
    * Handle the response from adding the item to the user's saved items list
    */
    func addItemProtocol(status: Bool, response: String) {
        self.loadingView.removeFromSuperview()
        if status{
            let alert = UIAlertController(title: "Item Added", message: "", preferredStyle: .actionSheet)
            self.navigationController?.present(alert, animated: true, completion: nil)
            let delay = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: delay, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }else{
            let alert = customAlert.errorAlert(title: "Save Item Failed", message: response)
            self.present(alert, animated: true)
        }
    }
    
    /*
    * Handle the response from retreiving the single item.
    */
    func itemsDownloaded(companyName: String, address: String, phone: String, link: String, itemName: String, itemDescription: String, itemImage: String) {
        self.itemName = itemName
        self.companyName = companyName
        self.address = address
        self.phone = phone
        self.url = link
        self.itemDescription = itemDescription
        self.itemImage = itemImage
        
        loadItemView()
    }
    
    /*
    * Open Maps if the location is tapped.
    */
    @IBAction func openMap(){
        let selectApp = UIAlertController(title: "Select Maps App", message: "Which App would you like to use?", preferredStyle: .actionSheet)
        let wazeURL = URL(string:"waze://")
        let gMapsURL = URL(string:"comgooglemaps://")
        
        if UIApplication.shared.canOpenURL(wazeURL!){
            let wazeAction = UIAlertAction(title: "Waze", style: .default, handler: {(alert: UIAlertAction!) in
                let directionsUrlString = "waze://ul?q=" + self.address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let directionsUrl = URL(string: directionsUrlString)
                UIApplication.shared.open(directionsUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            })
            selectApp.addAction(wazeAction)
        }
        
        if UIApplication.shared.canOpenURL(gMapsURL!){
            let gMapsAction = UIAlertAction(title: "Google Maps", style: .default, handler:{(alert: UIAlertAction!) in
                let directionsUrlString = "comgooglemaps://?daddr=" + self.address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let directionsUrl = URL(string: directionsUrlString)
                UIApplication.shared.open(directionsUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            })
            selectApp.addAction(gMapsAction)
        }
        
        let appleMapsAction = UIAlertAction(title: "Maps", style: .default, handler: {(alert: UIAlertAction!) in
            let directionsUrlString =  "http://maps.apple.com/?daddr=" + self.address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let directionsUrl = URL(string: directionsUrlString)
            UIApplication.shared.open(directionsUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        })
        selectApp.addAction(appleMapsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        selectApp.addAction(cancelAction)
        
        self.navigationController?.present(selectApp, animated: true, completion: nil)
        
    }
    
    @IBAction func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backToResultsButtonTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func goToURL(){
        let confirmationAlert = UIAlertController(title: "Open URL", message: "Do you want to go to \(self.url)?", preferredStyle: .alert)
        let openBrowser = UIAlertAction(title: "Go to URL", style: .default, handler: {
        alert -> Void in
            if let url = URL(string:"http://\(self.url)"){
                UIApplication.shared.open(url)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        confirmationAlert.addAction(openBrowser)
        confirmationAlert.addAction(cancelAction)
        self.present(confirmationAlert, animated: true, completion: nil)
    }
    
    @IBAction func callNumber(){
        let url = URL(string: "tel://\(self.phone)")
        if #available(iOS 10, *){
            UIApplication.shared.open(url!)
        }else{
            UIApplication.shared.openURL(url!)
        }
    }
    
    func loadItemView(){
        
        self.itemNameLabel.text = self.itemName
        self.restaurantNameButton.setTitleColor(UIColor.black, for: .normal)
        self.restaurantNameButton.setTitle(self.companyName, for: .normal)
        //self.restaurantURLButton.setTitle(self.url, for: .normal)
        //self.restaurantPhoneNumberButton.setTitle(self.phone, for: UIControlState.normal)
        self.itemImageView.sd_setImage(with: URL(string: self.itemImage))
        self.itemDescriptionTextArea.text = self.itemDescription
        self.title = "Utterfare"
        
        
        // Hide the loading indicator
        activityIndicator.stopAnimating()
        self.scrollView.isHidden = false;
    }
    
    func saveItem(){
        self.loadingView = customAlert.loadingAlert(uiView: self.view)
        self.view.addSubview(loadingView)
        self.myItems.delegateAddItem = self
        self.myItems.addItem(userId: self.defaults.string(forKey: "USER_ID")!, itemId: self.itemId, itemName: self.itemName, dataTable: self.dataTable, itemImageUrl: self.itemImage)
    }
    
    @objc func saveItemAction(){
        let isSignedIn = defaults.bool(forKey: "IS_LOGGED_IN")
        if isSignedIn{
            let alert = UIAlertController(title: "Save Item", message: "Save this item to your favorites.", preferredStyle: .actionSheet)
            let saveItemAction = UIAlertAction(title: "Save", style: .default, handler: {action in
                self.saveItem()
            })
            alert.addAction(saveItemAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(cancelAction)
            
            self.navigationController?.present(alert, animated: true, completion: nil)
        }else{
            let alert = customAlert.errorAlert(title: "Not Signed In", message: "You must be signed in to use this feature.")
            self.present(alert, animated:true)
        }
    }
    
    func saveItemButton() -> UIBarButtonItem{
        let item = UIBarButtonItem(barButtonSystemItem: .action, target: self, action:#selector(saveItemAction))
        item.tintColor = UIColor.white
        return item
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
       
        viewItemModel.delegate = self
        viewItemModel.doSearch(itemId: itemId)

        self.navigationItem.rightBarButtonItem = saveItemButton()
        
        activityIndicator.startAnimating()
        scrollView.isHidden = true
    }    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
