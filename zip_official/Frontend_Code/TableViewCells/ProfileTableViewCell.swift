//
//  ProfileTableViewCellTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/29/21.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    //MARK: - Subviews
    var imgView = UIImageView()

    private var cellLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with text: String, image: UIImage = UIImage()){
        cellLabel.text = text
        imgView = UIImageView(image: image)
        
        contentView.addSubview(imgView)
        contentView.addSubview(cellLabel)
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.widthAnchor.constraint(equalToConstant: cellLabel.intrinsicContentSize.height*1.75).isActive = true
        imgView.heightAnchor.constraint(equalTo: imgView.widthAnchor, multiplier: 1).isActive = true
        imgView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 7).isActive = true
        imgView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        cellLabel.leftAnchor.constraint(equalTo: imgView.rightAnchor, constant: 5).isActive = true
        cellLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        cellLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cellLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    var topInset: CGFloat = 0
    var leftInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    var rightInset: CGFloat = 0

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        self.layoutMargins = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }
}
