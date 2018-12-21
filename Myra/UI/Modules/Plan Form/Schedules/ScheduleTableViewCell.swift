//
//  ScheduleTableViewCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-05.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ScheduleTableViewCell: BaseFormCell {

    // MARK: Variables
    var parentReference: CreateNewRUPViewController?

    // MARK: Outlets
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var messageContainer: UIView!

    // MARK: Outlet Actions
    @IBAction func tooltipAction(_ sender: UIButton) {
        guard let parent = self.parentViewController as? CreateNewRUPViewController else {return}
        parent.showTooltip(on: sender, title: "Yearly Schedule", desc: InfoTips.yearlySchedule)
    }

    // MARK: Outlet Action
    @IBAction func addScheduleAction(_ sender: UIButton) {
        guard let p = parentReference else {return}
        guard let start = rup.planStartDate, let end = rup.planEndDate else {
            p.alert(with: "Missing prerequisites", message: "Please select plan start and end dates in the Plan Information section.")
            return
        }
        let vm = ViewManager()
        let picker = vm.datePicker

        let taken = RUPManager.shared.getScheduleYears(rup: rup)

        picker.setup(for: start, max: end, taken: taken) { (selection) in
            if RUPManager.shared.isNewScheduleYearValidFor(rup: self.rup, newYear: Int(selection)!) {
                let schedule = Schedule()
                schedule.year = Int(selection)!

                do {
                    let realm = try Realm()
                    let aRup = realm.objects(Plan.self).filter("localId = %@", self.rup.localId).first!
                    try realm.write {
                        aRup.schedules.append(schedule)
                        realm.add(schedule)
                    }
                    self.rup = aRup
                } catch _ {
                    fatalError()
                }
                self.updateTableHeight()
                p.showSchedule(object: schedule, completion: { (done) in
                    self.tableView.reloadData()
                })
            } else {
                p.alert(with: "Invalid year", message: "Please select a year within range of plan start and end dates")
            }
        }
        p.showPopOver(on: sender, vc: picker, height: picker.suggestedHeight, width: picker.suggestedWidth, arrowColor: Colors.primary)
    }

    // MARK: Setup
    func setup(mode: FormMode, rup: Plan, parentReference: CreateNewRUPViewController) {
        self.parentReference = parentReference
        self.rup = rup
        self.mode = mode
        
        switch mode {
        case .View:
            addButton.isEnabled = false
            addButton.alpha = 0
        case .Edit:
            addButton.isEnabled = true
            addButton.alpha = 1
        }

        if rup.getStatus() == .ClientDraft {
            messageContainer.alpha = 1
            styleSubHeader(label: message)
            tableHeight.constant = 100
            message.text = "Awaiting input from client"
        } else {
            tableHeight.constant = CGFloat( Double(rup.schedules.count) * ScheduleCellTableViewCell.cellHeight + 5.0)
            setUpTable()
        }
        style()
    }

    // MARK: Style
    func style() {
        styleHeader(label: sectionTitle, divider: divider)
        styleHollowButton(button: addButton)
        styleContainer(layer: tableView.layer)
    }

    // MARK: Dynamic Cell height
    func computeCellHeight() -> CGFloat {
        let padding: CGFloat = 5.0
        return CGFloat( CGFloat(rup.schedules.count) * CGFloat(ScheduleCellTableViewCell.cellHeight) + padding)
    }

    func updateTableHeight() {
        let parent = self.parentViewController as! CreateNewRUPViewController
        tableHeight.constant = computeCellHeight()
        parent.reload {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }
    
}

// MARK: Tableview
extension ScheduleTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        self.tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "ScheduleCellTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getScheduleCell(indexPath: IndexPath) -> ScheduleCellTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ScheduleCellTableViewCell", for: indexPath) as! ScheduleCellTableViewCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (rup.schedules.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getScheduleCell(indexPath: indexPath)
        cell.setup(mode: mode, rup: rup, schedule: (rup.schedules.sorted(by: { $0.year < $1.year })[indexPath.row]), parentReference: self)
        return cell
    }

}
