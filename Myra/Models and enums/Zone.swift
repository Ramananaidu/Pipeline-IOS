//
//  Zone.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-12.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Zone: Object {
    @objc dynamic var realmID: String = {
         return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "realmID"
    }

    var districts = List<District>()
    @objc dynamic var id: Int = -1
    @objc dynamic var code: String = ""
    @objc dynamic var districtId: Int = -1
    @objc dynamic var desc: String = ""
    @objc dynamic var contactName: String = ""
    @objc dynamic var contactPhoneNumber: String = ""
    @objc dynamic var contactEmail: String = ""

    func set(district: District, id: Int, code: String, districtId: Int, desc: String, contactName: String, contactPhoneNumber: String, contactEmail: String) {
        self.districts.append(district)
        self.id = id
        self.code = code
        self.districtId = districtId
        self.desc = desc
        self.contactName = contactName
        self.contactEmail = contactEmail
        self.contactPhoneNumber = contactPhoneNumber
    }
}
