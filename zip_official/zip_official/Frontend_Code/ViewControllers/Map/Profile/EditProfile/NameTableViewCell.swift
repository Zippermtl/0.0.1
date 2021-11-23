//
//  NameTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/2/21.
//

import UIKit

class NameTableViewCell: UITableViewCell {
    static let identifier = "nameIdentifier"
    private var textField = UITextField()
    
    private var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.sizeToFit()
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func configure(with user: User, idx: Int){
//        let name = user.name.components(separatedBy: " ")

        if idx == 0 {
//            textField.text = name[0]
            textField.text = user.firstName
            label.text = "First Name: "
        } else {
//            textField.text = name[1]
            textField.text = user.lastName
            label.text = "Last Name: "
        }
        textField.autocorrectionType = .no
        textField.font = .zipBody
        textField.tintColor = .white
        textField.textColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 10))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 5

        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(textField)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftAnchor.constraint(equalTo: label.rightAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        textField.widthAnchor.constraint(equalToConstant: contentView.frame.width - label.intrinsicContentSize.width - 20).isActive = true
        textField.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true



    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
