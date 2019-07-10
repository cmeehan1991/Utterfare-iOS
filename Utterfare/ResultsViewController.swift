//
//  ResultsViewController.swift
//  Utterfare
//
//  Created by Connor Meehan on 1/6/17.
//  Copyright © 2017 CBM Web Development. All rights reserved.
//

import UIKit
import SDWebImage

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchControllerProtocol {
    
    @IBOutlet weak var resultsTable : UITableView!
    @IBOutlet weak var back: UIBarButtonItem!
    
    var offset : Int = Int(), selectedRow: Int = Int()
    var doingSearch : Bool = false;
    var terms: String = String(), distance: String = String(), location: String = String()
    var itemIds : Array<String> = Array(), dataTables : Array<String> = Array(), itemNames :  Array<String> = Array(), restaurantNames : Array<String> = Array(), restaurantIds : Array<String> = Array(), itemImages : Array<String> = Array()
    let spinner = UIActivityIndicatorView()
    
    @IBAction func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func itemsDownloaded(hasResults: Bool, itemIds: Array<String>, dataTables: Array<String>, itemNames: Array<String>, restaurantNames: Array<String>, restaurantIds: Array<String>, itemImages: Array<String>) {
        doingSearch = false;
        if hasResults == true{
            self.itemIds.append(contentsOf: itemIds)
            self.dataTables.append(contentsOf: dataTables)
            self.itemNames.append(contentsOf: itemNames)
            self.restaurantNames.append(contentsOf: restaurantNames)
            self.restaurantIds.append(contentsOf: restaurantIds)
            self.itemImages.append(contentsOf: itemImages)
            
            // Reload the data
            if resultsTable.tableFooterView?.isHidden == false{
                resultsTable.tableFooterView?.isHidden = true
                spinner.stopAnimating()
            }
            resultsTable.reloadData()
            
        }else{
            print("No more")
            //let message = MDCSnackbarMessage()
            //message.text = "There are no more items"
            //MDCSnackbarManager.show(message)
        }
    }
    
    func indexPath()->[IndexPath]{
        let indexPath = [IndexPath(item: resultsTable.numberOfRows(inSection: resultsTable.numberOfSections - 1)-1, section: resultsTable.numberOfSections-1)]
        return indexPath
    }
    
    /**
     * Set up the tableview
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "ResultCell") as! ResultCellViewController
        myCell.itemName.text = itemNames[indexPath.row]
        myCell.restaurantName.text = restaurantNames[indexPath.row]
        let itemImageUrl = itemImages[indexPath.row]
        myCell.itemImage.sd_setImage(with: URL(string: itemImageUrl), placeholderImage: UIImage(named:"placeholder.png"))
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewItemController") as? ViewItemController
        
        self.selectedRow = indexPath.row
        print(itemIds[indexPath.row])
        vc?.itemId = itemIds[indexPath.row]
        vc?.dataTable = dataTables[indexPath.row]
        
        
        self.navigationController?.pushViewController(vc!, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == resultsTable{
            if (!doingSearch && itemNames.count % 10 == 0 && scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height*0.90){
                offset += 10
                let searchModel = SearchModel()
                searchModel.delegate = self
                doingSearch = true;
                print("Loading more")
                searchModel.doSearch(terms: self.terms, distance: self.distance, location: self.location, offset: String(offset))
                
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
    @objc func refreshTableResults(_ sender: Any){
        offset += 10
        let searchModel = SearchModel()
        searchModel.delegate = self
        doingSearch = true;
        print("Loading more")
        searchModel.doSearch(terms: self.terms, distance: self.distance, location: self.location, offset: String(offset))
    }
    
    
    override func loadView(){
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Utterfare"
        
        self.resultsTable.dataSource = self
        self.resultsTable.delegate = self
        
        self.offset = 0;
    }
}
