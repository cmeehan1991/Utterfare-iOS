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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var restaurantNameButton: UIButton!

    
    // Initialize the variables
    var itemId: String = String(), dataTable: String = String(), itemName : String = String(), itemImage : String = String(), itemDescription : String = String(), companyName : String = String(), url : String = String(), phone: String = String(), address : String = String(), restaurantDistance : String = String()
    let customAlert: CustomAlerts = CustomAlerts()
    let defaults: UserDefaults = UserDefaults()
    var myItems: MyItemsModel = MyItemsModel()
    var loadingView: UIView = UIView()
    
    func addItemProtocol(status: Bool, response: String) {
        self.loadingView.removeFromSuperview()
        if status{
            let alert = UIAlertController(title: "Item Added", message: "", preferredStyle: .actionSheet)
            self.navigationController?.present(alert, animated: true, completion: nil)
            let delay = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: delay, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }else{
            let alert = customAlert.errorAlert(title: "Save Item Failed", message: response)
            self.present(alert, animated: true)
        }
    }
    
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
    @IBAction func openMap(){
        let directionsUrlString =  "http://maps.apple.com/?daddr=" + address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let directionsUrl = URL(string: directionsUrlString)
        UIApplication.shared.open(directionsUrl!, options: [:], completionHandler: nil)
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
        self.restaurantURLButton.setTitle(self.url, for: .normal)
        self.restaurantPhoneNumberButton.setTitle(self.phone, for: UIControlState.normal)
        self.itemImageView.sd_setImage(with: URL(string: self.itemImage))
        self.itemDescriptionTextArea.text = self.itemDescription
        self.title = "Utterfare"
        
        
        // Hide the loading indicator
        self.scrollView.isHidden = false;
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.isHidden = true
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let viewItemModel = ViewItemModel()
        viewItemModel.delegate = self
        viewItemModel.doSearch(itemId: itemId, dataTable: dataTable)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.loadingIndicator.startAnimating();
        
        self.navigationItem.rightBarButtonItem = saveItemButton()
    }
    
}
