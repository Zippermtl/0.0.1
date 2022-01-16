//
//  EditPicturesCollectionViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/13/22.
//

import UIKit

protocol EditPicturesCollectionViewCellDelegate: AnyObject {
    func deleteCell(_ sender: UIButton)
}

class EditPicturesCollectionViewCell: UICollectionViewCell {
    weak var delegate: EditPicturesCollectionViewCellDelegate?
    var picture = UIImageView()

    var cornerRadius = CGFloat(0)
    
    let xButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark.square.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray), for: .normal)
        btn.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    @objc private func didTapDeleteButton() {
        delegate?.deleteCell(xButton)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(pictureHolder: PictureHolder) {
        xButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        
        if pictureHolder.isUrl() {
            picture.sd_setImage(with: pictureHolder.url, completed: nil)
        } else {
            picture.image = pictureHolder.image
        }
        
        contentView.addSubview(picture)
        picture.layer.masksToBounds = true
        picture.layer.cornerRadius = cornerRadius

        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        picture.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        picture.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        picture.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        
        contentView.addSubview(xButton)
        xButton.translatesAutoresizingMaskIntoConstraints = false
        xButton.topAnchor.constraint(equalTo: picture.topAnchor).isActive = true
        xButton.rightAnchor.constraint(equalTo: picture.rightAnchor).isActive = true

    }
}
