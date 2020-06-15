//
//  FavoritePlaceListVC.swift
//  FindWay_Manpreet
//
//  Created by  user175413 on 14/06/20.
//  Copyright © 2020 user175413. All rights reserved.
//

import UIKit
import MapKit

class placesTVC: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    
}



class FavoritePlaceListVC: UIViewController , UITableViewDelegate, UITableViewDataSource {

    
    var favoritePlaceArr = [MKPlacemark]()
    
    
    // cell reuse id (cells that scroll out of view can be reused)
       let cellReuseIdentifier = "cell"

       // don't forget to hook this up from the storyboard
       @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let favArr = UserDefaults.standard.object(forKey:"FavPlaces") {
            self.favoritePlaceArr = favArr as! [MKPlacemark];
            
            self.tableView.reloadData()
            
            
        }
    }

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoritePlaceArr.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell:placesTVC = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! placesTVC 

        // set the text from the data model
       // cell.textLabel?.text = self.animals[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }

}
