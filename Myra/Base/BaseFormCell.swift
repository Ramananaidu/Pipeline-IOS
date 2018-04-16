//
//  BaseFormCell.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-03-01.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class BaseFormCell: UITableViewCell {

    // Mark: Constants

    // Mark: Variables
    var rup: RUP = RUP()
    var mode: FormMode = .Create

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(mode: FormMode, rup: RUP) {
        self.rup = rup
        self.mode = mode
    }

    func styleInput(input: UITextField) {
        input.layer.cornerRadius = 3
        input.layer.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1).cgColor
    }
}
