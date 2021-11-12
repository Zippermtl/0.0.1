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

    private let checkMark = UIImageView(image: UIImage(named: "accept"))
    private let xMark = UIImageView(image: UIImage(named: "redX"))
    
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
        backgroundColor = .zipVeryLightGray
        addSubview(checkMark)
        addSubview(xMark)
        
        xMark.translatesAutoresizingMaskIntoConstraints = false
        xMark.topAnchor.constraint(equalTo: topAnchor).isActive = true
        xMark.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        xMark.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        xMark.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        checkMark.translatesAutoresizingMaskIntoConstraints = false
        checkMark.topAnchor.constraint(equalTo: topAnchor).isActive = true
        checkMark.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        checkMark.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        checkMark.leftAnchor.constraint(equalTo: leftAnchor).isActive = true

        checkMark.isHidden = true
        xMark.isHidden = true
    }
    
    public func clear(){
        backgroundColor = .zipVeryLightGray
        checkMark.isHidden = true
        xMark.isHidden = true
        status = .neutral
    }
    
    public func accept(){
        backgroundColor = .clear
        checkMark.isHidden = false
        xMark.isHidden = true
        status = .accept
    }
    
    public func reject(){
        backgroundColor = .clear
        checkMark.isHidden = true
        xMark.isHidden = false
        status = .reject
    }
    
    public func select(){
        backgroundColor = .zipBlue
        checkMark.isHidden = true
        xMark.isHidden = true
        status = .selected
    }
    

}
