//
//  SongCell.swift
//  IsItYacht
//
//  Created by Evan Cole on 9/16/18.
//  Copyright © 2018 Evan Cole. All rights reserved.
//

import UIKit

// class for cells containing song information in the History and Search tabs
class SongCell: UITableViewCell {
    @IBOutlet weak var coverArt: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var YoNLabel: UILabel!
}
