//
//  PlantCommunityPastureActionsTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class PlantCommunityPastureActionsTableViewCell: BaseTableViewCell {

    // MARK: Variables
    var mode: FormMode = .View
    var plantCommunity: PlantCommunity?
    var parentReference: PlantCommunityViewController?

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var headerText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func addAction(_ sender: UIButton) {
        guard let p = self.plantCommunity else {return}

        do {
            let realm = try Realm()
            let temp = realm.objects(PlantCommunity.self).filter("localId = %@", p.localId).first!
            try realm.write {
                temp.pastureActions.append(PastureAction())
            }
            self.plantCommunity = temp
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
        updateTableHeight()
    }

    // MARK: Setup
    func setup(plantCommunity: PlantCommunity, mode: FormMode, parentReference: PlantCommunityViewController) {
        self.plantCommunity = plantCommunity
        self.mode = mode
        self.parentReference = parentReference
        self.height.constant = computeHeight()
        setUpTable()
        style()
        autofill()
    }

    func autofill() {
        guard let pc = self.plantCommunity else {return}
        self.headerText.text = "Actions to \(pc.purposeOfAction)"
    }

    func refreshPlantCommunityObject() {
        guard let p = self.plantCommunity else {return}

        do {
            let realm = try Realm()
            let temp = realm.objects(PlantCommunity.self).filter("localId = %@", p.localId).first!
            self.plantCommunity = temp
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseReadFailure)
        }
    }

    func computeHeight() -> CGFloat {
        guard let p = self.plantCommunity else {return 0.0}
        return CGFloat(p.pastureActions.count) * CGFloat(PlantCommunityActionTableViewCell.cellHeight)
    }

    func updateTableHeight() {
        refreshPlantCommunityObject()
        guard let parent = self.parentReference else {return}
        self.height.constant = computeHeight()
        parent.reload {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }

    // MARK: Styles
    func style() {
        styleHollowButton(button: addButton)
        styleSubHeader(label: headerText)
        switch mode {
        case .View:
            addButton.alpha = 0
        case .Edit:
            addButton.alpha = 1
        }
    }
}

extension PlantCommunityPastureActionsTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "PlantCommunityActionTableViewCell")
    }
    @objc func doThisWhenNotify() { return }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getActionCell(indexPath: IndexPath) -> PlantCommunityActionTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PlantCommunityActionTableViewCell", for: indexPath) as! PlantCommunityActionTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getActionCell(indexPath: indexPath)
        if let pc = self.plantCommunity, let parent = self.parentReference {
            cell.setup(mode: self.mode, action: pc.pastureActions[indexPath.row], parentReference: parent, parentCellRefenrece: self)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let p = self.plantCommunity {
            return p.pastureActions.count
        } else {
            return 0
        }
    }
}
