//
//  MyItemsViewController.swift
//  Utterfare
//
//  Created by Connor Meehan on 3/30/18.
//  Copyright © 2018 Utterfare. All rights reserved.
//

import Foundation
import UIKit

class MyItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var itemsTableView: UITableView!
    
    let itemIds: Array<String> = Array<String>(), itemNames: Array = Array<String>(), itemImages: Array = Array<String>()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemsCell: MyItemsTableCellController = itemsTableView.dequeueReusableCell(withIdentifier: "ItemCell") as! MyItemsTableCellController
        itemsCell.itemName.text = itemNames[indexPath.row]
        return itemsCell
    }
    
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isLoggedIn = defaults.bool(forKey: "IS_LOGGED_IN")
        if isLoggedIn == false{
            let vc : UserSignInController = self.storyboard?.instantiateViewController(withIdentifier: "UserSignInController") as! UserSignInController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        self.itemsTableView.delegate = self
        self.itemsTableView.dataSource = self
        
    }
}
