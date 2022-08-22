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

    var cornerRadius = CGFloat(5)
    
    let xButton: UIButton = {
        let btn = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .medium)
        let img = UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
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
        picture.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        picture.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        picture.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        picture.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        
        
        contentView.addSubview(xButton)
        xButton.translatesAutoresizingMaskIntoConstraints = false
        xButton.centerYAnchor.constraint(equalTo: picture.topAnchor).isActive = true
        xButton.centerXAnchor.constraint(equalTo: picture.rightAnchor).isActive = true
        xButton.heightAnchor.constraint(equalTo: xButton.widthAnchor).isActive = true
//        xButton.backgroundColor = .zipBlue
        
        guard let bg =  xButton.imageView else {
            return
        }
        bg.backgroundColor = .zipBlue
        bg.layer.masksToBounds = true
        
        
        xButton.layer.masksToBounds = true
        
        xButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let bg =  xButton.imageView else {
            return
        }
        
        bg.layer.cornerRadius = bg.frame.height/2
//        xButton.layer.cornerRadius = xButton.frame.height/2
//        print("width = \(xButton.frame.width) height = \(xButton.frame.height)")

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
