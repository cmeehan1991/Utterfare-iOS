//
//  MyItemsViewController.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/30/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class MyItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GetItemsProtocol, RemoveItemsProtocol{
    
    @IBOutlet weak var itemsTableView: UITableView!
    
    let defaults = UserDefaults.standard
    var itemsModel: MyItemsModel = MyItemsModel()
    var itemIds: Array<String> = Array<String>(), itemNames: Array = Array<String>(), itemImages: Array = Array<String>(), itemDatatables: Array = Array<String>()
    let customAlert: CustomAlerts = CustomAlerts()
    var indexToRemove: IndexPath = IndexPath()
    var loadingView: UIView = UIView()
    
    /*
    * Open the user profile view controller
    */
    @IBAction func userProfileAction(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserInformationController") as! UserInformationController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    * Get items protocol
    */
    func getItemsProtocol(hasItems: Bool, itemIds: Array<String>, dataTabes: Array<String>, itemNames: Array<String>, itemImages: Array<String>) {
        if hasItems{
            self.itemIds = itemIds
            self.itemImages = itemImages
            self.itemNames = itemNames
            self.itemDatatables = dataTabes
            self.itemsTableView.reloadData()
        }
        self.loadingView.removeFromSuperview()
    }
    
    /*
    * Remove items protocol
    */
    func removeItemsProtocol(status: Bool, response: String) {
        self.loadingView.removeFromSuperview()
        if status{
            self.itemsTableView.deleteRows(at: [self.indexToRemove], with: .fade)
        }else{
            let alert = customAlert.errorAlert(title: "Failed to Delete Item", message: response)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /*
    * Dynamically loads the correct number of rows in the table
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemIds.count
    }
    
    /*
    * Load the tableview items
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemsCell: MyItemsTableCellController = itemsTableView.dequeueReusableCell(withIdentifier: "ItemCell") as! MyItemsTableCellController
        itemsCell.itemName.text = itemNames[indexPath.row]
        let itemImageUrl = itemImages[indexPath.row]
        itemsCell.itemImage.sd_setImage(with: URL(string: itemImageUrl), placeholderImage: UIImage(named:"placeholder.png"))
        return itemsCell
    }
    
    /*
    * Set the rows editable so items can be removed
    */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /*
    * Add the delete editing style
    */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            self.indexToRemove = indexPath
            self.removeItem()
        }
    }
    
    /*
    * Handle the item removal.
    * Before we just remove the item we are going to confirm with the user
    * that they actually want tot delete that item.
    */
    func removeItem(){
        let removeConfirm = UIAlertController(title: "Delete Item", message: "Are you sure you want to permanently delete \(itemNames[indexToRemove.row]) from your saved items? This action cannot be undone.", preferredStyle: .actionSheet)
        let confirmRemoval = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteItem)
        let cancelRemoval = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        removeConfirm.addAction(confirmRemoval)
        removeConfirm.addAction(cancelRemoval)
        
        self.navigationController?.present(removeConfirm, animated: true, completion: nil)
    }
    
    /*
    * Handle the item remove if the user confirms they want to delete the item from their list
    * of saved items.
    */
    func handleDeleteItem(alertAction: UIAlertAction!)->Void{
        self.view.addSubview(loadingView)
        self.itemsModel.delegateRemoveItem = self
        
        let indexPath = self.indexToRemove.row
        
        let userId = self.defaults.string(forKey: "USER_ID")
        let itemId = self.itemIds[indexPath]
        let dataTable = self.itemDatatables[indexPath]
        
        self.itemsModel.removeItem(userId: userId!, itemId: itemId, dataTable: dataTable)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if the user is logged in.
        // If not we are going to redirect them to the login page.
        let isLoggedIn = defaults.bool(forKey: "IS_LOGGED_IN")
        if isLoggedIn == false{
            let vc : UserSignInController = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        // Deletagate and set the datasource for the items table.
        self.itemsTableView.delegate = self
        self.itemsTableView.dataSource = self
        
        // Initialize the loading view
        self.loadingView = customAlert.loadingAlert(uiView: self.view)
        
        // Load the items and add the loading subview
        self.view.addSubview(self.loadingView)
        
        self.itemsModel.delegateGetItems = self
        self.itemsModel.getItems(userId: defaults.string(forKey: "USER_ID")!)
    }
}