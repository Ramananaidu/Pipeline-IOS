//
//  PlantCommunityViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-07-04.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class PlantCommunityViewController: BaseViewController {

    // MARK: Variables
    var completion: ((_ done: Bool) -> Void)?
    var plantCommunity: PlantCommunity?
    var pasture: Pasture?
    var mode: FormMode = .View
//    var popupContainerTag = 200
//    var popover: UIPopoverPresentationController?

    // MARK: Outlets
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var navbar: UIView!
    @IBOutlet weak var statusbar: UIView!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var navbarTitle: UILabel!

    @IBOutlet weak var bannerLabel: UILabel!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    @IBOutlet weak var banner: UIView!

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        setTitle()
        setSubtitle()
        style()
    }

    // MARK: Outlet Actions
    @IBAction func backAction(_ sender: UIButton) {
//        if let pc = self.plantCommunity {
//            RealmRequests.updateObject(pc)
//        }

        self.dismiss(animated: true, completion: {
            if let callback = self.completion {
                return callback(true)
            }
        })
    }

    // MARK: Setup
    func setup(mode: FormMode, pasture: Pasture, plantCommunity: PlantCommunity, completion: @escaping (_ done: Bool) -> Void) {
        self.pasture = pasture
        self.mode = mode
        self.plantCommunity = plantCommunity
        self.completion = completion

        setUpTable()
        setTitle()
        setSubtitle()

        /*
        self.realmNotificationToken = schedule.observe { (change) in
            switch change {
            case .error(_):
                print("Error in rup change")
            case .change(_):
                self.validate()
            case .deleted:
                print("RUP deleted")
            }
        }
        */
    }

    func setTitle() {
        if self.pageTitle == nil {return}
        guard let community = self.plantCommunity else {return}
        self.pageTitle.text = "Plant Community: \(community.name)"
    }

    func setSubtitle() {
        if self.subtitle == nil { return }
        guard let p = self.pasture else {return}
        self.subtitle.text = p.name
    }

    func reload() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    // MARK: Styles
    func style() {
        styleNavBar(title: navbarTitle, navBar: navbar, statusBar: statusbar, primaryButton: backbutton, secondaryButton: deleteButton, textLabel: nil)
        styleHeader(label: pageTitle)
        styleFooter(label: subtitle)
        styleDivider(divider: divider)
        styleHollowButton(button: saveButton)
    }

    // MARK: Banner
    func openBanner(message: String) {
        UIView.animate(withDuration: shortAnimationDuration, animations: {
            self.bannerLabel.textColor = Colors.primary
            self.banner.backgroundColor = Colors.secondaryBg.withAlphaComponent(1)
            self.bannerHeight.constant = 50
            self.bannerLabel.text = message
            self.view.layoutIfNeeded()
        }) { (done) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                UIView.animate(withDuration: self.mediumAnimationDuration, animations: {
                    self.bannerLabel.textColor = Colors.primaryConstrast
                    self.view.layoutIfNeeded()
                })
            })
        }
    }

    func closeBanner() {
        self.bannerHeight.constant = 0
        animateIt()
    }

    func showTextEntry(vc: UIViewController) {
        let whiteScreen = getWhiteScreen()
        let inputContainer = getInputViewContainer()
        whiteScreen.addSubview(inputContainer)
        self.view.addSubview(whiteScreen)
        addChildViewController(vc)
        vc.view.frame = inputContainer.frame
        vc.view.center.x = self.view.center.x
        vc.view.center.y = self.view.center.y
//        vc.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
//        vc.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        self.view.addSubview(vc.view)
//        vc.view.center.x = self.view.center.x
//        vc.view.center.y = self.view.center.y
        vc.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        vc.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        vc.didMove(toParentViewController: self)
    }
}

// MARK: Tableview
extension PlantCommunityViewController:  UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self
        
        registerCell(name: "PlanCommunityBasicInfoTableViewCell")
        registerCell(name: "PlantCommunityMonitoringAreasTableViewCell")
        registerCell(name: "PlantCommunityPastureActionsTableViewCell")

        let nib = UINib(nibName: "CustomSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "CustomSectionHeader")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getBasicInfoCell(indexPath: IndexPath) -> PlanCommunityBasicInfoTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PlanCommunityBasicInfoTableViewCell", for: indexPath) as! PlanCommunityBasicInfoTableViewCell
    }

    func getMonitoringAreasCell(indexPath: IndexPath) -> PlantCommunityMonitoringAreasTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PlantCommunityMonitoringAreasTableViewCell", for: indexPath) as! PlantCommunityMonitoringAreasTableViewCell
    }

    func getPastureActionsCell(indexPath: IndexPath) -> PlantCommunityPastureActionsTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PlantCommunityPastureActionsTableViewCell", for: indexPath) as! PlantCommunityPastureActionsTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let community = self.plantCommunity else {return getBasicInfoCell(indexPath: indexPath)}
        switch indexPath.section {
        case 0:
            let cell = getBasicInfoCell(indexPath: indexPath)
            cell.setup(mode: mode, plantCommunity: community)
            return cell
        case 1:
            let cell = getMonitoringAreasCell(indexPath: indexPath)
            cell.setup(plantCommunity: community, mode: mode, parentReference: self)
            return cell
        case 2:
            let cell = getPastureActionsCell(indexPath: indexPath)
            cell.setup(plantCommunity: community, mode: mode, parentReference: self)
            return cell
        default:
            return getBasicInfoCell(indexPath: indexPath)
        }
    }

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return ""
//        case 1:
//            return "Monitoring Areas"
//        case 3:
//            return "PastureActions"
//        default:
//            return ""
//        }
//    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionTitle = ""
        switch section {
        case 0:
            sectionTitle =  "Basic Plant Community Information"
        case 1:
            sectionTitle =  "Monitoring Areas"
        case 2:
            sectionTitle =  "Pasture Actions"
        default:
            sectionTitle =  ""
        }
        
        // Dequeue with the reuse identifier
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomSectionHeader")
        let header = cell as! CustomSectionHeader
        header.setup(title: sectionTitle)

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}