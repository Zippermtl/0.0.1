//
//  ZipFinderCollectionViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/17/21.
//

import Foundation
import UIKit
import MapKit
import MTSlideToOpen

class ZipFinderCollectionViewCell: UICollectionViewCell {

    
    static let identifier = "ZipFinderCollectionViewCell"
    
    // MARK: - Cell Data
    var delegate: ZFCardBackDelegate?
    // Color
    
    //User
    private var user = User()
    var userLoc = CLLocation()

    // MARK: - SubViews
    let cardFrontView = ZFCardFrontView()
    let cardBackView = ZFCardBackView()
    

    // MARK: - Subviews
    private var outlineView = UIView()
    private var cardView = UIView()
    
    
    public func configure(with user: User, loc: CLLocation) {
        self.user = user
        self.userLoc = loc
        configureBackground()
        configureCard()
        configureGestureRecognizer()
    }
    
    
    // MARK: - Configure
    
    //inits outline/card frame and color
    private func configureBackground() {
        contentView.backgroundColor = .clear
        outlineView.frame = CGRect(x: 10, y: 0, width: contentView.frame.size.width-20, height: contentView.frame.size.height)
        outlineView.layer.cornerRadius = 20
        contentView.addSubview(outlineView)
        outlineView.addSubview(cardView)
    
        cardView.frame = CGRect(x: 5, y: 5, width: outlineView.frame.size.width-10, height: outlineView.frame.size.height-10)
        cardView.layer.cornerRadius = 20
        cardView.layer.borderColor = UIColor.zipBlue.cgColor
        cardView.layer.borderWidth = 4
        cardView.backgroundColor = .zipGray
    }
    
    //inits front and back side of card
    private func configureCard(){
        cardFrontView.frame = cardView.frame
        cardFrontView.configure(user: user, cellColor: UIColor.zipBlue, loc: userLoc)
        cardView.addSubview(cardFrontView)
        
        cardFrontView.translatesAutoresizingMaskIntoConstraints = false
        cardFrontView.topAnchor.constraint(equalTo: cardView.topAnchor).isActive = true
        cardFrontView.leftAnchor.constraint(equalTo: cardView.leftAnchor).isActive = true
        cardFrontView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
        cardFrontView.rightAnchor.constraint(equalTo: cardView.rightAnchor).isActive = true
        
        cardBackView.frame = cardView.frame
        cardBackView.configure(user: user, cellColor: UIColor.zipBlue, loc: userLoc)
        cardView.addSubview(cardBackView)
        cardBackView.isHidden = true
        cardBackView.delegate = delegate
        cardFrontView.userLoc = userLoc
        
        cardBackView.translatesAutoresizingMaskIntoConstraints = false
        cardBackView.topAnchor.constraint(equalTo: cardView.topAnchor).isActive = true
        cardBackView.leftAnchor.constraint(equalTo: cardView.leftAnchor).isActive = true
        cardBackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
        cardBackView.rightAnchor.constraint(equalTo: cardView.rightAnchor).isActive = true
        

    }
    
    private func configureGestureRecognizer(){
        let tapFlip = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapFlip.numberOfTapsRequired = 1
        tapFlip.numberOfTouchesRequired = 1
        cardView.addGestureRecognizer(tapFlip)
    }
    
    override func prepareForReuse() {
        cardFrontView.isHidden = false
        cardFrontView.pictureCollectionView.reloadData()
        cardBackView.isHidden = true
    }

    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        flip()
    }
    
    func flip() {
        let flipSide: UIView.AnimationOptions = cardFrontView.isHidden ? .transitionFlipFromLeft : .transitionFlipFromRight
        UIView.transition(with: outlineView, duration: 0.5, options: flipSide, animations: { [weak self]  () -> Void in
            self?.cardFrontView.isHidden = !(self?.cardFrontView.isHidden ?? true)
            self?.cardBackView.isHidden = !(self?.cardBackView.isHidden ?? false)
        }, completion: nil)
    }
    
}








