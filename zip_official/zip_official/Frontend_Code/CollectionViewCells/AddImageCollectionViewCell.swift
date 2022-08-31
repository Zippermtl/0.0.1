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
    
    private var bgView: UIView
    @objc private func didTapAddButton() {
        delegate?.addImage()
    }
    
    var addButton: UIButton = {
        let btn = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let img = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.zipVeryLightGray)
        
        btn.setImage(img, for: .normal)
        btn.contentMode = .scaleAspectFit
        return btn
    }()
        
    override init(frame: CGRect) {
        bgView = UIView()
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)

        bgView.backgroundColor = .zipLightGray.withAlphaComponent(0.6)
        contentView.addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10).isActive = true
        bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bgView.rightAnchor.constraint(equalTo: contentView.rightAnchor,constant: -(10*7/10)).isActive = true
        bgView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        
        
        bgView.addSubview(addButton)
        
        
        addButton.layer.masksToBounds = true
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.centerXAnchor.constraint(equalTo: bgView.centerXAnchor).isActive = true
        addButton.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
