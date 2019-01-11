//
//  Settings.swift
//  Myra
//
//  Created by Amir Shayegh on 2019-01-10.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class SettingsModel: Object {
    
    @objc dynamic var realmID: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "realmID"
    }
    
    @objc dynamic var autoSyncEndbaled: Bool = true
    @objc dynamic var cacheMapEndbaled: Bool = true
    
    func setAutoSync(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                autoSyncEndbaled = enabled
            }
        } catch _ {
            fatalError()
        }
    }
    
    func setCacheMap(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                cacheMapEndbaled = enabled
            }
        } catch _ {
            fatalError()
        }
    }
}


class SettingsManager {
    
    
    static let shared = SettingsManager()

    private init() {
        if getModel() == nil {
            let newModel = SettingsModel()
            RealmRequests.saveObject(object: newModel)
        }
    }
    
    func getModel()-> SettingsModel? {
        if let query = RealmRequests.getObject(SettingsModel.self), let model = query.last {
            // TODO: Delete print statement
            print("\(query.count) setting models exist.")
            return model
        } else {
            return nil
        }
    }
    
    // MARK: Sync
    func isAutoSyncEnabled()-> Bool {
        guard let model = getModel() else {return false}
        return model.autoSyncEndbaled
    }
    
    func setAutoSync(enabled: Bool) {
        guard let model = getModel() else {return}
        AutoSync.shared.endListener()
        model.setAutoSync(enabled: enabled)
        AutoSync.shared.beginListener()
    }
    
    // MARK: Map
    func clearMapData() {
        TileMaster.shared.deleteAllStoredTiles()
    }
    
    func getMapDataSize()-> String {
        return "\(TileMaster.shared.sizeOfStoredTiles())MB"
    }
    
    func isMapCacheEnabled()-> Bool {
        guard let model = getModel() else {return false}
        return model.cacheMapEndbaled
    }
    
    func setCacheMap(enabled: Bool) {
        guard let model = getModel() else {return}
        AutoSync.shared.endListener()
        model.setCacheMap(enabled: enabled)
        AutoSync.shared.beginListener()
    }
    
}
