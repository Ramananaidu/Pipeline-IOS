//
//  Options.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-09-06.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

class Options {
    static let shared = Options()
    private init() {}

    func getMinistersIssueTypesOptions() -> [SelectionPopUpObject] {
        var options: [SelectionPopUpObject] = [SelectionPopUpObject]()
        let query = Reference.shared.getIssueType()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }

    func getMinistersIssueActionsOptions() -> [SelectionPopUpObject] {
        var options: [SelectionPopUpObject] = [SelectionPopUpObject]()
        let query = Reference.shared.getIssueActionType()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }

    func getPlanCommunityTypeOptions() -> [SelectionPopUpObject] {
        var options: [SelectionPopUpObject] = [SelectionPopUpObject]()
        let query = Reference.shared.getPlantCommunityType()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }

    func getPlantCommunityElevationLookup() -> [SelectionPopUpObject] {
        var options = [SelectionPopUpObject]()
        let query = Reference.shared.getPlantCommunityElevation()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }

    func getPlantCommunityPurposeOfActionsLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        returnArray.append(SelectionPopUpObject(display: "Establish Plant Community"))
        returnArray.append(SelectionPopUpObject(display: "Maintain Plant Community"))
        returnArray.append(SelectionPopUpObject(display: "Clear"))
        return returnArray
    }

    func getRangeLandHealthLookup() -> [SelectionPopUpObject] {
        var options = [SelectionPopUpObject]()
        let query = Reference.shared.getMonitoringAreaHealth()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }

    func getMonitoringAreaPurposeLookup() -> [SelectionPopUpObject] {
        var options = [SelectionPopUpObject]()
        let query = Reference.shared.getMonitoringAreaPurposeType()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }

    func getPastureActionLookup() -> [SelectionPopUpObject] {
        var options = [SelectionPopUpObject]()
        let query = Reference.shared.getPlantCommunityActionType()
        for item in query {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }

    func getIndicatorPlantLookup(forShrubUse: Bool? = false) -> [SelectionPopUpObject] {
        var shrubUse = false
        if let su = forShrubUse, su {
            shrubUse = su
        }
        var options = [SelectionPopUpObject]()
        let query = Reference.shared.getPlantSpecies()
        for item in query where item.isShrubUse == shrubUse {
            options.append(SelectionPopUpObject(display: item.name))
        }
        return options
    }

    func getPasturesLookup(rup: Plan) -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let names = getPastureNames(rup: rup)
        for name in names {
            returnArray.append(SelectionPopUpObject(display: name, value: name))
        }
        return returnArray
    }

    func getPastureNames(rup: Plan) -> [String] {
        var names = [String]()
        for pasture in rup.pastures {
            names.append(pasture.name)
        }
        return names
    }

    func getPastureNamed(name: String, rup: Plan) -> Pasture? {
        for pasture in rup.pastures {
            if pasture.name == name {
                return pasture
            }
        }
        return nil
    }

    func getRANLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let agreements = RUPManager.shared.getAgreements()
        for agreement in agreements {
            returnArray.append(SelectionPopUpObject(display: agreement.agreementId))
        }
        return returnArray
    }

    func getManagementConsiderationLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let objects = Reference.shared.getManagegementConsiderationType()
        for object in objects {
             returnArray.append(SelectionPopUpObject(display: object.name))
        }
        return returnArray
    }

    func getAdditionalRequirementLookup() -> [SelectionPopUpObject] {
        var returnArray = [SelectionPopUpObject]()
        let objects = Reference.shared.getAdditionalRequirementCategory()
        for object in objects {
            returnArray.append(SelectionPopUpObject(display: object.name))
        }
        return returnArray
    }
}
