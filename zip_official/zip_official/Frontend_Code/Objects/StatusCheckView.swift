//
//  statusCheckView.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/27/21.
//

import UIKit



class StatusCheckView: UIView {
    enum StatusCheck: Int {
        case neutral
        case accept
        case reject
        case selected
    }

    
    private let checkMark = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue)
    private let xMark = UIImage(systemName:  "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.red)
    private let clearMark = UIImage(systemName:  "circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray)
    private let imageView = UIImageView()
    
    public var status = StatusCheck(rawValue: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure(){
        backgroundColor = .clear
        addSubview(imageView)
        imageView.image = clearMark
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true

    }
    
    public func clear(){
        backgroundColor = .zipVeryLightGray
        imageView.image = clearMark
        status = .neutral
    }
    
    public func accept(){
        backgroundColor = .clear
        imageView.image = checkMark
        status = .accept
    }
    
    public func reject(){
        backgroundColor = .clear
        imageView.image = xMark
        status = .reject
    }
    
    public func select(){
        backgroundColor = .zipBlue
        imageView.image = clearMark
//        checkMark.isHidden = true
//        xMark.isHidden = true
        status = .selected
    }
    

}
