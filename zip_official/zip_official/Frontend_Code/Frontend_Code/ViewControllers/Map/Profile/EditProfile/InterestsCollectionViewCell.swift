//
//  InterestsCollectionViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/3/21.
//

import UIKit

class InterestsCollectionViewCell: UICollectionViewCell {
    static let identifier = "interestsCell"
    
    
    var label: UILabel = {
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .white
        return label
    }()
    
    public func configure(){
        contentView.backgroundColor = .zipGray
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    

    
}
