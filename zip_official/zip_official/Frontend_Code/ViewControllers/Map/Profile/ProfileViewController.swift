//
//  SecondViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/2/21.
//


import UIKit
import MapKit
import CoreLocation
import SDWebImage
import JGProgressHUD

/*
 
 let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
 let img = UIImage(systemName: "calendar", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
 
 let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
 let img = UIImage(systemName: "person.3.fill", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
 
 
 let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
 let img = UIImage(systemName: "calendar", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
 let icon = UIImageView(image: img)
 
 
 
 
 
 
 */


class ProfileViewController: AbstractProfileViewController {
    
    init(id: String) {
        let actionButtonInfo = ("Edit", UIColor.zipLightGray)
        let settingsIcon = UIImage(systemName: "gearshape")!.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        super.init(id: id,
                   B1: IconButton.eventsIcon(),
                   B2: IconButton.zipsIcon(),
                   B3: IconButton.myCardIcon(),
                   rightBarButtonIcon: settingsIcon,
                   centerActionInfo: actionButtonInfo
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didTapRightBarButton() {
        let settingsView = SettingsPageViewController()
        settingsView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(settingsView, animated: true)
    }
    
    override func didTapCenterActionButton() {
        let editView = EditProfileViewController(user: user)
        editView.delegate = self
        editView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(editView, animated: true)
    }
    
    override func didTapB1Button() {
        let hostingEvents = Event.getTodayUpcomingPrevious(events: User.getUDEvents(toKey: .hostedEvents))
        let goingEvents = Event.getTodayUpcomingPrevious(events: User.getUDEvents(toKey: .goingEvents))
        let savedEvents = Event.getTodayUpcomingPrevious(events: User.getUDEvents(toKey: .savedEvents))
        
        let goingData = [
            CellSectionData(title: "Today", items: goingEvents.0, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Upcoming", items: goingEvents.1, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Previous", items: goingEvents.2, cellType: CellType(eventType: .save))
        ]

        let savedData = [
            CellSectionData(title: "Today", items: savedEvents.0, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Upcoming", items: savedEvents.1, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Previous", items: savedEvents.2, cellType: CellType(eventType: .save))
        ]
        
        let hostingData = [
            CellSectionData(title: "Today", items: hostingEvents.0, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Upcoming", items: hostingEvents.1, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Previous", items: hostingEvents.2, cellType: CellType(eventType: .save))
        ]
        
        let tableData : [MultiSectionData] = [
            MultiSectionData(title: "Going", sections: goingData),
            MultiSectionData(title: "Saved", sections: savedData),
            MultiSectionData(title: "Hosting", sections: hostingData)
        ]

        let vc = MasterTableViewController(multiSectionData: tableData)
        vc.title = "My Events"
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didTapB2Button() {
        let section = MasterTableViewController.cellControllers(with: User.getMyZips(), title: nil, cellType: .zipList)
        let multisection = MultiSectionData(title: nil, sections: [section])
        let myZips = MasterTableViewController(multiSectionData: [multisection])
        myZips.title = "My Zips"
        navigationController?.pushViewController(myZips, animated: true)
        
    }
    
    override func didTapB3Button() {
        let cardPreview = ZFSingleCardViewController()
        cardPreview.configure(user: user)
        cardPreview.modalPresentationStyle = .overCurrentContext
        present(cardPreview, animated: true)
    }
    
    override func didTapPhotos() {
        let vc = UserPhotosViewController()
        vc.delegate = self
        vc.configure(user: user)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    override func configurePhotoCountText() {
        super.configurePhotoCountText()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .small)
        let img = UIImage(systemName: "plus", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        photoCountButton.setImage(img, for: .selected)

        
        if user.pictureURLs.count == 0 {
            photoCountButton.isHidden = false
            photoCountButton.isSelected = true
        } else {
            photoCountButton.isSelected = false
        }
    }


}

extension ProfileViewController: UpdateFromEditProtocol {
    func update() {
        configurePhotoCountText()
        profilePictureView.sd_setImage(with: user.profilePicUrl)
        configureCells()
        tableView.reloadData()
    }
}
