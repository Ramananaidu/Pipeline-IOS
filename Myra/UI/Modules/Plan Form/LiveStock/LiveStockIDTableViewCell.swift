//
//  LiveStockIDTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-26.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class LiveStockIDTableViewCell: BaseFormCell {

    // Mark: Constants
    let cellHeight = 45
    
    // Mark: Variables

    // Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // Mark: Outlet Actions
    @IBAction func addLiveStockAction(_ sender: Any) {
        do {
            let realm = try Realm()
            try realm.write {
                self.rup.liveStockIDs.append(LiveStockID())
            }
        } catch _ {
            fatalError()
        }
        updateTableHeight()
    }

    // Mark: Functions
    override func setup(mode: FormMode, rup: Plan) {
        self.mode = mode
        self.rup = rup
        setUpTable()
    }

    func computeHeight() -> CGFloat {
        let padding: CGFloat = 5.0
        return CGFloat(CGFloat((self.rup.liveStockIDs.count)) * CGFloat(LiveStockTableViewCell.cellHeight) + padding)
    }

    func updateTableHeight() {
        let parent = self.parentViewController as! CreateNewRUPViewController
        tableViewHeight.constant = computeHeight()
        parent.reload {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }

}
extension LiveStockIDTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "LiveStockTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getLiveStockCell(indexPath: IndexPath) -> LiveStockTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "LiveStockTableViewCell", for: indexPath) as! LiveStockTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getLiveStockCell(indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rup.liveStockIDs.count
    }

}