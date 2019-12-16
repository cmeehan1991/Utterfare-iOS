//
//  ExplorerViewController.swift
//  Utterfare
//
//  Created by Connor Meehan on 12/16/19.
//  Copyright © 2019 Utterfare. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ExplorerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ExplorerItemsProtocol{
    
    @IBOutlet weak var explorerCollectionView: UICollectionView!
    
    var itemIds: NSArray = NSArray(), itemImagesUrl: NSArray = NSArray()
    var currentLocation: String = "6 Kent Ct., Hilton Head Island, SC 29926"
    
    /*
     * Download the items and add them to the explorer view
     */
    func downloadExplorerItems(itemIds: NSArray, itemImages: NSArray) {
        // Add some code here to handle the downloaded items
    }
    
    /*
     * Set the cell content
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = explorerCollectionView.dequeueReusableCell(withReuseIdentifier: "explorerCollectionViewCell ", for: indexPath) as! ExplorerCollectionViewCellController
        
        return cell
    }
    
    /*
     * Set the number of cells in the view controller
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemIds.count
    }
    
    override func loadView() {
        self.explorerCollectionView.delegate = self
        self.explorerCollectionView.dataSource = self
        
        let explorerItems: ExplorerItems = ExplorerItems()
        
        explorerItems.delegate = self
        explorerItems.getExplorerItems(currentLocation: currentLocation)
    }

}
