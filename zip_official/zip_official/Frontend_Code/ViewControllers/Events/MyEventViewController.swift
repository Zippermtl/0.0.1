//
//  EventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/9/21.
//

import UIKit
import MapKit
import CoreLocation
import JGProgressHUD


class MyEventViewController: EventViewController {
    
    override init(event: Event) {
        super.init(event: event)
        
        goingButton.backgroundColor = .zipGray
//        goingButton.layer.borderWidth = 1
        goingButton.layer.borderColor = UIColor.zipBlue.cgColor
           
        goingButton.setTitle("Edit", for: .normal)
        goingButton.titleLabel?.textColor = .white
        goingButton.titleLabel?.font = .zipSubtitle2
        goingButton.titleLabel?.textAlignment = .center
        goingButton.contentVerticalAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func configureLabels(){
        super.configureLabels()
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        hostLabel.attributedText = NSAttributedString(string: "Hosted by You", attributes: attributes)
    }
    
    override func didTapGoingButton() {
        let vc = EditEventProfileViewController(event: event)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didTapSaveButton() {
        
    }
    
    
    
}
