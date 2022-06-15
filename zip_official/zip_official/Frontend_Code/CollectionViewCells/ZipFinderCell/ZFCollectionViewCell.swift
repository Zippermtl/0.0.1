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
    var idPath: Int = 0
    var delegate: ZFCardBackDelegate?
    // Color
    
    //User
    private var user: User?

    // MARK: - SubViews
    let cardFrontView: ZFCardFrontView
    let cardBackView: ZFCardBackView
    
    // MARK: - Subviews
    private var cardView = UIView()
    
    
    
    override init(frame: CGRect) {
        cardFrontView = ZFCardFrontView()
        cardBackView = ZFCardBackView()
        super.init(frame: frame)

        configureBackground()
        configureCard()
        configureGestureRecognizer()
    }
    

    
    required init?(coder: NSCoder) {
        cardFrontView = ZFCardFrontView()
        cardBackView = ZFCardBackView()
        
        super.init(coder: coder)

        configureBackground()
        configureCard()
        configureGestureRecognizer()
    }
    
    public func configure(user: User, loc: CLLocation, idPath: Int) {
        cardFrontView.configure(user: user)
        cardBackView.configure(user: user)
    }
    
    
    // MARK: - Configure
    
    //inits outline/card frame and color
    private func configureBackground() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        cardView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        cardView.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
        cardView.widthAnchor.constraint(equalToConstant: contentView.frame.width-25).isActive = true

        cardView.layer.cornerRadius = 30
        cardView.layer.borderColor = UIColor.white.cgColor //UIColor.zipBlue.cgColor
        cardView.layer.borderWidth = 2
        cardView.backgroundColor = .zipGray
    }
    
    //inits front and back side of card
    private func configureCard(){
        cardView.addSubview(cardFrontView)
        
        cardFrontView.frame = cardView.frame

        cardFrontView.translatesAutoresizingMaskIntoConstraints = false
        cardFrontView.topAnchor.constraint(equalTo: cardView.topAnchor).isActive = true
        cardFrontView.leftAnchor.constraint(equalTo: cardView.leftAnchor).isActive = true
        cardFrontView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
        cardFrontView.rightAnchor.constraint(equalTo: cardView.rightAnchor).isActive = true
        
        
        cardView.addSubview(cardBackView)
        cardBackView.frame = cardView.frame
//        cardBackView.addSubviews()
//        cardBackView.configureSubviewLayout()
        
        cardBackView.isHidden = true
        cardBackView.delegate = delegate
        
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
        UIView.transition(with: cardView, duration: 0.5, options: flipSide, animations: { [weak self]  () -> Void in
            self?.cardFrontView.isHidden = !(self?.cardFrontView.isHidden ?? true)
            self?.cardBackView.isHidden = !(self?.cardBackView.isHidden ?? false)
        }, completion: nil)
    }
    
}








