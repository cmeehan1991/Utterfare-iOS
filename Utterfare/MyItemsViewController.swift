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
    var userItemsId: Array<String> = Array(), itemsId: Array<String> = Array(), itemsName: Array<String> = Array(), itemsImage: Array<String> = Array(), itemsShortDescription: Array<String> = Array(), itemsVendorName: Array<String> = Array()
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
    func getItemsProtocol(hasItems: Bool, userItemsId: Array<String>, itemsId: Array<String>, itemsName: Array<String>, itemsShortDescription: Array<String>, itemsImage: Array<String>, itemsVendorName: Array<String>) {
        if hasItems{
            self.userItemsId = userItemsId
            self.itemsId = itemsId
            self.itemsName = itemsName
            self.itemsShortDescription = itemsShortDescription
            self.itemsImage = itemsImage
            self.itemsVendorName = itemsVendorName
            
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
            self.userItemsId.remove(at: self.indexToRemove.row)
            self.itemsId.remove(at: self.indexToRemove.row)
            self.itemsName.remove(at: self.indexToRemove.row)
            self.itemsShortDescription.remove(at: self.indexToRemove.row)
            self.itemsImage.remove(at: self.indexToRemove.row)
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
        return itemsId.count
    }
    
    /*
    * Load the tableview items
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemsCell: MyItemsTableCellController = itemsTableView.dequeueReusableCell(withIdentifier: "ItemCell") as! MyItemsTableCellController
        
        itemsCell.itemName.text = itemsName[indexPath.row]
        itemsCell.vendorName.text = itemsVendorName[indexPath.row]
        itemsCell.shortDescription.text = itemsShortDescription[indexPath.row]
        itemsCell.itemImage.sd_setImage(with: URL(string: itemsImage[indexPath.row]), placeholderImage: UIImage(named:"placeholder.png"))
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            self.indexToRemove = indexPath
            self.removeItem()
        }
    }
    
    /*
    * Show single item when selected
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewItemController") as! ViewItemController
        vc.itemId = self.itemsId[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    * Handle the item removal.
    * Before we just remove the item we are going to confirm with the user
    * that they actually want tot delete that item.
    */
    func removeItem(){
        let removeConfirm = UIAlertController(title: "Delete Item", message: "Are you sure you want to permanently delete \(itemsName[indexToRemove.row]) from your saved items? This action cannot be undone.", preferredStyle: .actionSheet)
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
        let itemId = self.itemsId[indexPath]
        let userItemId = self.userItemsId[indexPath]
        
        self.itemsModel.removeItem(userId: userId!, itemId: itemId, userItemId: userItemId)
    }
    
    func getItems(){
        // Initialize the loading view
        self.loadingView = customAlert.loadingAlert(uiView: self.view)
        
        // Load the items and add the loading subview
        self.view.addSubview(self.loadingView)
        
        self.itemsModel.delegateGetItems = self
        self.itemsModel.getItems(userId: defaults.string(forKey: "USER_ID")!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.loadingView.isDescendant(of: self.view){
            self.loadingView.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let loggedIn: Bool = defaults.bool(forKey: "IS_LOGGED_IN")
        if loggedIn{
            getItems()
        }else{
            let vc : UserSignInController = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
            //self.navigationController?.pushViewController(vc, animated: true)
            vc.userItemsVC = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Deletagate and set the datasource for the items table.
        self.itemsTableView.delegate = self
        self.itemsTableView.dataSource = self
        self.itemsTableView.allowsSelection = true
    }
    
    override func loadView(){
        super.loadView()
    }
}
