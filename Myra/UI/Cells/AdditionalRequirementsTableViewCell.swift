//
//  AdditionalRequirementsTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-10-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class AdditionalRequirementsTableViewCell: BaseFormCell {

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!

    @IBAction func addAction(_ sender: UIButton) {
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpTable()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func setup(mode: FormMode, rup: RUP) {
        self.mode = mode
        self.rup = rup
        style()
        autoFill()
    }

    func autoFill() {

    }

    func style() {
        switch self.mode {
        case .View:
            self.addButton.alpha = 0
        case .Edit:
            styleHollowButton(button: addButton)
        }
    }

    /*
    func updateTableHeight(newAdded: Bool? = false) {
        let parent = self.parentViewController as! CreateNewRUPViewController
        tableHeight.constant = computeHeight()
        parent.reload {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }

    func computeHeight() -> CGFloat {
        /*
         Height of Pastures cell =
         */
        let padding: CGFloat = 5
        var h: CGFloat = 0.0
        for pasture in (rup.pastures) {
            h = h + computePastureHeight(pasture: pasture) + padding
        }
        return h
    }
     */
}


extension AdditionalRequirementsTableViewCell:  UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "AdditionalRequirementTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getAdditionalRequirementCell(indexPath: IndexPath) -> AdditionalRequirementTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "AdditionalRequirementTableViewCell", for: indexPath) as! AdditionalRequirementTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getAdditionalRequirementCell(indexPath: indexPath)
        cell.setup(mode: mode, object: self.rup.additionalRequirements[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rup.additionalRequirements.count
    }
}

