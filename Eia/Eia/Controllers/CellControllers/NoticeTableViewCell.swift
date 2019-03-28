//
//  NoticeTableViewCell.swift
//  Eia
//
//  Created by Cleofas Pereira on 24/03/19.
//  Copyright © 2019 Cleofas Pereira. All rights reserved.
//

import UIKit
class NoticeTableViewCell: UITableViewCell {
    private let defaultIconImage = UIImage(named: "notification_selected_tab_icon")

    @IBOutlet weak var noticeIconImageView: UIImageView!
    @IBOutlet weak var noticeTitleLabel: UILabel!
    @IBOutlet weak var noticeContentLabel: UILabel!
    @IBOutlet weak var noticeDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    public func setup(withNotice notice: Notice) {
        noticeTitleLabel.text = notice.title
        noticeContentLabel.text = notice.notice_content
        noticeDateLabel.text = notice.date?.dateStringValue
        if let noticeType = NoticeType(rawValue: notice.notice_type ?? "") {
            if let iconImage = noticeType.icon {
                noticeIconImageView.image = iconImage
            } else {
                noticeIconImageView.image = defaultIconImage
            }
        } else {
            noticeIconImageView.image = defaultIconImage
        }
    }
}
