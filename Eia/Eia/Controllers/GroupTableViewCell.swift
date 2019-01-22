//
//  GroupTableViewCell.swift
//  Eia
//
//  Created by Cleofas Pereira on 05/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupImageView.layer.cornerRadius = 6
        groupImageView.clipsToBounds = true
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    public func setup(with group: Group) {
        groupNameLabel.text = group.name
        groupDescriptionLabel.text = group.group_description
        if let photoStr = group.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            groupImageView.image = photoImage
        } else {
            // photo default...
        }
    }

}
