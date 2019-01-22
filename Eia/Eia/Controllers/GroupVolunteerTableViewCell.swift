//
//  GroupVolunteerTableViewCell.swift
//  Eia
//
//  Created by Cleofas Pereira on 20/01/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit

class GroupVolunteerTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    public func setup(withVolunteer volunteer: Voluntary, group: Group?) {
        nameLabel.text = volunteer.name
        if let photoStr = volunteer.photo_str, let photoData = Data(base64Encoded: photoStr), let photoImage = UIImage(data: photoData) {
            photoImageView.image = photoImage
        } else {
            // photo default...
        }
    }

}
