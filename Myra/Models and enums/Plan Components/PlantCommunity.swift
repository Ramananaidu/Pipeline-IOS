//
//  PlantCommunity.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-02-22.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyJSON

class PlantCommunity: Object, MyraObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    // if remoteId == -1, it has not been "synced"
    @objc dynamic var remoteId: Int = -1

    @objc dynamic var approvedByMinister: Bool = false
    @objc dynamic var name: String = ""
    @objc dynamic var aspect: String = ""
    @objc dynamic var elevation: String = ""
    @objc dynamic var notes: String = ""
    @objc dynamic var communityURL: String = ""
    @objc dynamic var purposeOfAction: String = "Clear"
    @objc dynamic var readinessDay: Int = -1
    @objc dynamic var readinessMonth: Int = -1
    @objc dynamic var readinessNotes: String = ""
    @objc dynamic var shrubUse: Double = 0
    var rangeReadiness = List<IndicatorPlant>()
    var stubbleHeight = List<IndicatorPlant>()
    var monitoringAreas = List<MonitoringArea>()
    var pastureActions = List<PastureAction>()

    // MARK: Initializations
    convenience init(json: JSON) {
        self.init()
        if let id = json["id"].int {
            self.remoteId = id
        }

        if let name = json["name"].string {
            self.name = name
        }
        
        if let sUse = json["shrubUse"].double {
            self.shrubUse = sUse
        }

        if let notes = json["notes"].string {
            self.notes = notes
        }

        if let aspect = json["aspect"].string {
            self.aspect = aspect
        }

        if let url = json["url"].string {
            self.communityURL = url
        }

        if let approved = json["approved"].bool {
            self.approvedByMinister = approved
        }

        if let rangeReadinessMonth = json["rangeReadinessMonth"].int {
            self.readinessMonth = rangeReadinessMonth
        }

        if let rangeReadinessDay = json["rangeReadinessDay"].int {
            self.readinessDay = rangeReadinessDay
        }

        if let purposeAction = json["purposeOfAction"].string {
            if purposeAction.lowercased().contains("establish") {
                self.purposeOfAction = "Establish Plant Community"
            } else if purposeAction.lowercased().contains("maintain") {
                self.purposeOfAction = "Maintain Plant Community"
            } else {
                self.purposeOfAction = "Clear"
            }
        }

        if let elevationJSON = json["elevation"].dictionaryObject, let elevationName = elevationJSON["name"] as? String {
            elevation = elevationName
        }

        let indicatorPlants = json["indicatorPlants"]
        for indicatorPlant in indicatorPlants {
            if let criteria = indicatorPlant.1["criteria"].string {
                if criteria.lowercased() == "rangereadiness" {
                    self.rangeReadiness.append(IndicatorPlant(json: indicatorPlant.1))
                } else if criteria.lowercased() == "stubbleheight" {
                    self.stubbleHeight.append(IndicatorPlant(json: indicatorPlant.1))
                } else if criteria.lowercased() == "shrubuse" {
                    // TODO: Store Shrub Use
                }
            }
        }

        let plantCommunityActions = json["plantCommunityActions"]
        for action in plantCommunityActions {
            pastureActions.append(PastureAction(json: action.1))
        }

        let monitoringAreasJSON = json["monitoringAreas"]
        for element in monitoringAreasJSON {
            self.monitoringAreas.append(MonitoringArea(json: element.1))
        }
    }

    // MARK: Deletion
    func deleteSubEntries() {
        for element in self.rangeReadiness {
            RealmRequests.deleteObject(element)
        }
        for element in self.stubbleHeight {
            RealmRequests.deleteObject(element)
        }

        for element in self.monitoringAreas {
            RealmRequests.deleteObject(element)
        }

        for element in pastureActions {
            RealmRequests.deleteObject(element)
        }
    }

    // MARK: Getters
    func getIndicatorPlants() -> [IndicatorPlant] {
        var indicatorPlants: [IndicatorPlant] = [IndicatorPlant]()
        indicatorPlants.append(contentsOf: rangeReadiness)
        indicatorPlants.append(contentsOf: stubbleHeight)
        return indicatorPlants
    }

    // MARK: Setters
    func setRemoteId(id: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                remoteId = id
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func setShrubUse(to value: Double) {
        do {
            let realm = try Realm()
            try realm.write {
                self.shrubUse = value
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func clearPurposeOfAction() {
        do {
            let realm = try Realm()
            try realm.write {
                self.purposeOfAction = "Clear"
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
        for action in self.pastureActions {
            RealmRequests.deleteObject(action)
        }
    }

    func addIndicatorPlant(type: IndicatorPlantSection) {
        do {
            let realm = try Realm()
            try realm.write {
                switch type {
                case .RangeReadiness:
                    rangeReadiness.append(IndicatorPlant(criteria: "\(type)"))
                case .StubbleHeight:
                    stubbleHeight.append(IndicatorPlant(criteria: "\(type)"))
                }
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func importRangeReadiness(from pc: PlantCommunity) {
        do {
            let realm = try Realm()
            try realm.write {
                self.readinessDay = pc.readinessDay
                self.readinessMonth = pc.readinessMonth
                self.readinessNotes = pc.readinessNotes

                /*
                 This safely handles the case where
                 user tries to import from the
                 same plant community
                 */

                // Cache new content
                let cache = List<IndicatorPlant>()
                for indicatorPlant in pc.rangeReadiness {
                    cache.append(indicatorPlant.copy())
                }

                // Delete current content
                for element in self.rangeReadiness {
                    realm.delete(element)
                }

                // Save new elements.
                self.rangeReadiness.append(objectsIn: cache)
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func importStubbleHeight(from pc: PlantCommunity) {

        do {
            let realm = try Realm()
            try realm.write {

                /*
                 This safely handles the case where
                 user tries to import from the
                 same plant community
                 */

                // Cache new content
                let cache = List<IndicatorPlant>()
                for indicatorPlant in pc.stubbleHeight {
                    cache.append(indicatorPlant.copy())
                }
                // Delete current content
                for element in self.stubbleHeight {
                    realm.delete(element)
                }

                // Save new elements.
                self.stubbleHeight.append(objectsIn: cache)
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    func importShrubUse(from pc: PlantCommunity) {
        if self.shrubUse == pc.shrubUse {return}
        do {
            let realm = try Realm()
            try realm.write {
                self.shrubUse = pc.shrubUse
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }
    
    func addMonitoringArea(cloneFrom object: MonitoringArea? = nil, withName monitoringAreaName: String) {
        do {
            let realm = try Realm()
            try realm.write {
                if let origin = object {
                    let newMA = origin.clone()
                    newMA.name = monitoringAreaName
                    monitoringAreas.append(newMA)
                } else {
                    let newMA = MonitoringArea()
                    newMA.name = monitoringAreaName
                    monitoringAreas.append(newMA)
                }
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databaseWriteFailure)
        }
    }

    // MARK: Validations
    func requiredFieldsAreFilled() -> Bool {
        if self.name.isEmpty || self.elevation.isEmpty || self.description.isEmpty {
            return false
        } else {
            return true
        }
    }

    // MARK: Export
    func copy() -> PlantCommunity {
        let new = PlantCommunity()
        new.remoteId = self.remoteId
        new.name = self.name
        new.aspect = self.aspect
        new.elevation = self.elevation
        new.notes = self.notes
        new.communityURL = self.communityURL
        new.purposeOfAction = self.purposeOfAction
        new.approvedByMinister = self.approvedByMinister
        new.shrubUse = self.shrubUse

        new.readinessDay = self.readinessDay
        new.readinessMonth = self.readinessMonth
        new.readinessNotes = self.readinessNotes

        for object in self.monitoringAreas {
            new.monitoringAreas.append(object.clone())
        }

        for object in self.pastureActions {
            new.pastureActions.append(object.copy())
        }

        for object in self.rangeReadiness {
            new.rangeReadiness.append(object.copy())
        }

        for object in self.stubbleHeight {
            new.stubbleHeight.append(object.copy())
        }

        new.shrubUse = self.shrubUse

        return new
    }

    func toDictionary() -> [String: Any] {
        var typeId = 0
        var elevationId = 0

        if let elevationObj = Reference.shared.getPlantCommunityElevation(named: elevation) {
            elevationId = elevationObj.id
        }

        if let type = Reference.shared.getPlantCommunitType(named: self.name) {
            typeId = type.id
        }

        var readyDay: Int = readinessDay
        var readyMonth: Int = readinessMonth

        if readyDay == -1 {
            readyDay = 0
        }
        if readyMonth == -1 {
            readyMonth = 0
        }

        var purpose = "none"

        if purposeOfAction.lowercased().contains("establish") {
            purpose = "establish"
        } else if purposeOfAction.lowercased().contains("maintain") {
            purpose = "maintain"
        }

        // TODO: Send Shrub use

        return [
            "name": name,
            "shrubUse": shrubUse,
            "communityTypeId": typeId,
            "elevationId": elevationId,
            "purposeOfAction": purpose,
            "aspect": aspect,
            "url": communityURL,
            "notes": notes,
            "rangeReadinessDay": readyDay,
            "rangeReadinessMonth": readyMonth,
            "rangeReadinessNote": readinessNotes,
            "approved": approvedByMinister
        ]
    }
}
