//
//  PostTimelineCell.swift
//  gezond
//
//  Created by Lise-Lotte Geutjes on 18-12-17.
//  Copyright © 2017 Drama Media. All rights reserved.
//

import UIKit

class PostTimelineCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var heartsView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
