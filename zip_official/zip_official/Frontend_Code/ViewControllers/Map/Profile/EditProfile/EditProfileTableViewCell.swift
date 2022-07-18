//
//  EditProfileTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/6/22.
//

import UIKit

class EditProfileTableViewCell: UITableViewCell {

    let titleLabel: UILabel
    let rightView: UIView
    private let LABEL_WIDTH = 128

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.rightView = UIView()
        self.titleLabel = UILabel.zipTextFill()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .zipGray
        
        
        addSubviews()
        configureSubviewLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(label: String) {
        titleLabel.text = label
    }
    
    private func addSubviews(){
        contentView.addSubview(titleLabel)
        contentView.addSubview(rightView)
    }
    
    private func configureSubviewLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 128).isActive = true
        
        rightView.translatesAutoresizingMaskIntoConstraints = false
        rightView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        rightView.leftAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
        rightView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        rightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


