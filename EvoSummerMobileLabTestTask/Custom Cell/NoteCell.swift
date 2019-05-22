//
//  NoteCell.swift
//  EvoSummerMobileLabTestTask
//
//  Created by Denis Semerych on 5/16/19.
//  Copyright © 2019 Denis Semerych. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var noteText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
