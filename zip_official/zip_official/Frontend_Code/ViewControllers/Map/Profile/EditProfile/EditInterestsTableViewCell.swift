//
//  EditInterestsTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/6/22.
//

import UIKit

internal protocol DeleteInterestsProtocol: AnyObject {
    func deleteInterest(idx: Int)
    func openInterestSelect()
}

class EditInterestsTableViewCell: EditProfileTableViewCell { 
    weak var cellDelegate: GrowingCellProtocol?
    weak var presentInterestDelegate: PresentEditInterestsProtocol?
    weak var updateInterestsDelegate: UpdateInterestsProtocol?

    static let identifier = "interestTBviewCell"
    let collectionView: DynamicHeightCollectionView
    private var interests: [Interests]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = LeftOrientedFlowLayout()
        layout.minimumLineSpacing = 5
        
        self.collectionView = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        
        self.interests = []
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 128).isActive = true
        contentView.backgroundColor = .zipGray
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .zipGray
        
        collectionView.register(EditProfileInterestCell.self, forCellWithReuseIdentifier: EditProfileInterestCell.identifier)
        
        addSubviews()
        configureSubviewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(label: String, content: [Interests]) {
        super.configure(label: label)
        self.interests = content
        collectionView.reloadData()
        cellDelegate?.updateHeightOfRow(self, collectionView)
    }
    
    private func addSubviews(){
        rightView.addSubview(collectionView)
    }
    
    private func configureSubviewLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: rightView.topAnchor,constant: 5).isActive = true
        collectionView.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor,constant: -5).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cellDelegate?.updateHeightOfRow(self, collectionView)
    }
    
}

extension EditInterestsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("CELLS = \(interests.count + 1)")
        return interests.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditProfileInterestCell.identifier, for: indexPath) as! EditProfileInterestCell
        cell.delegate = self
        cell.tag = indexPath.row
        if indexPath.row == interests.count {
            cell.xButton.setImage(UIImage(systemName: "plus.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
            cell.configure(text: "Add More")
            cell.bg.backgroundColor = .zipBlue
        } else {
            cell.xButton.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray), for: .normal)
            cell.configure(text: interests[indexPath.row].description)
            cell.bg.backgroundColor = .zipLightGray
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == interests.count {
            openInterestSelect()
        }
    }
    
    
    private class EditProfileInterestCell: UICollectionViewCell {
        static let identifier = "interestCellInEdit"
        
        let bg: UIView
        let xButton: UIButton
        let interestLabel: UILabel
        weak var delegate: DeleteInterestsProtocol?
        
        @objc private func didTapX() {
            if interestLabel.text == "Add More" {
                delegate?.openInterestSelect()
            } else {
                delegate?.deleteInterest(idx: tag)
            }
        }
        
        override init(frame: CGRect) {
            bg = UIView()
            interestLabel = UILabel.zipTextFill()
            xButton = UIButton()
            
            super.init(frame: frame)
            bg.layer.masksToBounds = true
            bg.backgroundColor = .zipLightGray
            contentView.backgroundColor = .clear
            
            xButton.addTarget(self, action: #selector(didTapX), for: .touchUpInside)
            xButton.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray), for: .normal)
            
            interestLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            addSubviews()
            configureSubviewLayout()
        }
        
        required init?(coder: NSCoder) {
            bg = UIView()
            interestLabel = UILabel.zipTextFill()
            xButton = UIButton()
            
            super.init(coder: coder)
        }
        
        public func configure(text: String) {
            interestLabel.text = text
        }
        
        private func addSubviews() {
            contentView.addSubview(bg)
            bg.addSubview(xButton)
            bg.addSubview(interestLabel)
        }
        
        private func configureSubviewLayout(){
            bg.translatesAutoresizingMaskIntoConstraints = false
            bg.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            bg.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            bg.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            
            bg.layer.cornerRadius = 15
            
            interestLabel.translatesAutoresizingMaskIntoConstraints = false
            interestLabel.leftAnchor.constraint(equalTo: bg.leftAnchor,constant: 7).isActive = true
            interestLabel.topAnchor.constraint(equalTo: bg.topAnchor).isActive = true
            interestLabel.bottomAnchor.constraint(equalTo: bg.bottomAnchor).isActive = true

            xButton.translatesAutoresizingMaskIntoConstraints = false
            xButton.topAnchor.constraint(equalTo: bg.topAnchor).isActive = true
            xButton.bottomAnchor.constraint(equalTo: bg.bottomAnchor).isActive = true
            xButton.rightAnchor.constraint(equalTo: bg.rightAnchor, constant: -3).isActive = true
            xButton.widthAnchor.constraint(equalTo: xButton.heightAnchor).isActive = true
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    
}

extension EditInterestsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: UIFont.zipSubtitle]
        if indexPath.row == interests.count {
            return CGSize(width: "Add More".size(withAttributes: fontAttributes).width+30, height: 30)
        } else {
            return CGSize(width: interests[indexPath.row].description.size(withAttributes: fontAttributes).width+40,height: 30)
        }
        
        
    }
}


extension EditInterestsTableViewCell {
    class DynamicHeightCollectionView: UICollectionView {
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if bounds.size != intrinsicContentSize {
                self.invalidateIntrinsicContentSize()
            }
        }
        
        override var intrinsicContentSize: CGSize {
            return collectionViewLayout.collectionViewContentSize
        }
        
    }
    
}


extension EditInterestsTableViewCell: DeleteInterestsProtocol {
    func deleteInterest(idx: Int) {
        interests.remove(at: idx)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    func openInterestSelect() {
        presentInterestDelegate?.presentInterestSelect()
    }

}

extension EditInterestsTableViewCell: UpdateInterestsProtocol {
    func updateInterests(_ interests: [Interests]) {
        self.interests = interests
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        updateInterestsDelegate?.updateInterests(interests)
    }
    
    
}
