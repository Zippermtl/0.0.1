//
//  EventInviteTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/28/21.
//

import UIKit

class InviteTableViewCell: UITableViewCell {
    static let identifier = "eventInviteCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with user: User){
        
    }

}
