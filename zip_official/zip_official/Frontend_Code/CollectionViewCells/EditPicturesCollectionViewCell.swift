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
    static let identifier = "pictureCell"
    weak var delegate: EditPicturesCollectionViewCellDelegate?
    var picture = UIImageView()

    var cornerRadius = CGFloat(5)
    
    let xButton: UIButton = {
        let btn = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold, scale: .small)
        let img = UIImage(systemName: "xmark", withConfiguration: largeConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue)
        btn.setImage(img, for: .normal)
        
        btn.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        btn.contentMode = .scaleAspectFit
        btn.imageView?.contentMode = .scaleAspectFit
        btn.isHidden = true
        return btn
    }()
    
    @objc private func didTapDeleteButton() {
        delegate?.deleteCell(xButton)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        
        contentView.addSubview(picture)
        picture.layer.masksToBounds = true
        picture.layer.cornerRadius = cornerRadius

        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10).isActive = true
        picture.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        picture.rightAnchor.constraint(equalTo: contentView.rightAnchor,constant: -(10*7/10)).isActive = true
        picture.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        
        
        contentView.addSubview(xButton)
        xButton.translatesAutoresizingMaskIntoConstraints = false
        xButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        xButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        xButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        xButton.heightAnchor.constraint(equalTo: xButton.widthAnchor).isActive = true
        
    
       
        
        xButton.backgroundColor = .white
        xButton.layer.masksToBounds = true
        xButton.layer.cornerRadius = 10
        xButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(pictureHolder: PictureHolder) {
        
        if pictureHolder.isUrl() {
            picture.sd_setImage(with: pictureHolder.url, completed: nil)
        } else {
            picture.image = pictureHolder.image
        }
    }
}
