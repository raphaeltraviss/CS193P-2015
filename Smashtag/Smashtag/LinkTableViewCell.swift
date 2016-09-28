//
//  LinkTableViewCell.swift
//  Smashtag
//
//  Created by Raphael on 3/23/16.
//  Copyright © 2016 Skyleaf Design. All rights reserved.
//

import UIKit

class LinkTableViewCell: UITableViewCell {
    var url: NSURL? {
        didSet {
            label.text = url?.absoluteString
        }
    }
    @IBOutlet weak var label: UILabel!
}
