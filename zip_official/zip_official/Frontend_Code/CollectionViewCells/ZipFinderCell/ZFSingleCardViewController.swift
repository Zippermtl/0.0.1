//
//  ZFSingleCardViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/12/22.
//

import UIKit
import CoreLocation

class ZFSingleCardViewController: UIViewController {
    private var user = User()

    private var cardFrontView: ZFCardFrontView?
    private var cardBackView: ZFCardBackView?
    private var cardView = UIView()
    
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.font = .zipTitle
        label.textColor = .white
        label.text = "PREVIEW"
        return label
    }()
    
    private let xButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        btn.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return btn
    }()
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    }
    
    
    public func configure(user: User) {
        self.user = user
        cardFrontView = ZFCardFrontView()
//        cardFrontView?.configure(user: user)

        cardBackView = ZFCardBackView()
        cardBackView?.configure(user: user)
        
        configureBackground()
        configureCard()
        configureCloseButton()
        configureGestureRecognizer()
    }
    
    private func configureBackground() {        
        let outlineSize: CGSize
        if AppDelegate.userDefaults.bool(forKey: "hasHomeButton"){
            outlineSize = CGSize(width: view.frame.size.width,
                              height: round(view.frame.size.height*0.9))
        } else {
            outlineSize = CGSize(width: view.frame.size.width,
                              height: round(view.frame.size.height*0.7))
        }
        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cardView.heightAnchor.constraint(equalToConstant: outlineSize.height).isActive = true
        cardView.widthAnchor.constraint(equalToConstant: outlineSize.width-25).isActive = true

        cardView.layer.cornerRadius = 20

    
        cardView.layer.cornerRadius = 20
        cardView.layer.borderColor = UIColor.zipBlue.cgColor
        cardView.layer.borderWidth = 4
        cardView.backgroundColor = .zipGray
        
    }
    
    //inits front and back side of card
    private func configureCard(){
        guard let cardFrontView = cardFrontView,
              let cardBackView = cardBackView
        else {
            return
        }
                
        cardFrontView.configure(user: user)
        cardView.addSubview(cardFrontView)
        
        cardFrontView.translatesAutoresizingMaskIntoConstraints = false
        cardFrontView.topAnchor.constraint(equalTo: cardView.topAnchor).isActive = true
        cardFrontView.leftAnchor.constraint(equalTo: cardView.leftAnchor).isActive = true
        cardFrontView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
        cardFrontView.rightAnchor.constraint(equalTo: cardView.rightAnchor).isActive = true
        
        cardBackView.configure(user: user)
        cardView.addSubview(cardBackView)
        cardBackView.isHidden = true
        
        cardBackView.translatesAutoresizingMaskIntoConstraints = false
        cardBackView.topAnchor.constraint(equalTo: cardView.topAnchor).isActive = true
        cardBackView.leftAnchor.constraint(equalTo: cardView.leftAnchor).isActive = true
        cardBackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
        cardBackView.rightAnchor.constraint(equalTo: cardView.rightAnchor).isActive = true
    }
    
    private func configureCloseButton(){
        view.addSubview(previewLabel)
        view.addSubview(xButton)

        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 5).isActive = true
        previewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        xButton.translatesAutoresizingMaskIntoConstraints = false
        xButton.centerYAnchor.constraint(equalTo: previewLabel.centerYAnchor).isActive = true
        xButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
    
    private func configureGestureRecognizer(){
        let tapFlip = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapFlip.numberOfTapsRequired = 1
        tapFlip.numberOfTouchesRequired = 1
        cardView.addGestureRecognizer(tapFlip)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        flip()
    }
    
    func flip() {
        guard let cardFrontView = cardFrontView
        else { return }
        
        let flipSide: UIView.AnimationOptions = cardFrontView.isHidden ? .transitionFlipFromLeft : .transitionFlipFromRight
        UIView.transition(with: cardView, duration: 0.5, options: flipSide, animations: { [weak self]  () -> Void in
            guard let cardFrontView = self?.cardFrontView,
                  let cardBackView = self?.cardBackView
            else { return }
            
            cardFrontView.isHidden = cardFrontView.isHidden
            cardBackView.isHidden = cardBackView.isHidden
        }, completion: nil)
    }

}
