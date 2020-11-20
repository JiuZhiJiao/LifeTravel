//
//  NoteListTableViewCell.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit

class NoteListTableViewCell: UITableViewCell {

    @IBOutlet weak var noteDate: UILabel!
    @IBOutlet weak var noteLocation: UILabel!
    @IBOutlet weak var noteContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
