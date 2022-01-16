//
//  AddImageCollectionViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/13/22.
//

import UIKit

protocol AddImageCollectionViewCellDelegate: AnyObject {
    func addImage()
}

class AddImageCollectionViewCell: UICollectionViewCell {
    static let identifier = "PictureCollectionViewCell"
    weak var delegate: AddImageCollectionViewCellDelegate?
    
    @objc private func didTapAddButton() {
        delegate?.addImage()
    }
    
    private var addButton: UIButton = {
        let btn = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let img = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.zipVeryLightGray)
        
        btn.setImage(img, for: .normal)
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        return btn
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        
        contentView.addSubview(addButton)
        addButton.layer.masksToBounds = true

        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        addButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        addButton.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    

}
