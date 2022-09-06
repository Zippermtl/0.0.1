//
//  FPCEventTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/1/22.
//

import UIKit
import DropDown

class FPCEventTableViewCell: AbstractEventTableViewCell, InvitedCell {    
    private let rsvpButton: UIButton
    var iPath: IndexPath
    private var goingDD: DropDown
    var delegate: InvitedTableViewDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        iPath = IndexPath(row: 0, section: 0)
        rsvpButton = UIButton()
        goingDD = DropDown()
       
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        goingDD.anchorView = rsvpButton
        goingDD.dismissMode = .onTap
        goingDD.direction = .bottom
        goingDD.textFont = .zipSubtitle2
        goingDD.dataSource = ["Going", "Not Going"]
        goingDD.selectionAction = { [unowned self] (index: Int, item: String) in
            if item == "Going" {
                self.markGoing()
            } else {
                self.markNotGoing()
            }
        }
        
        rsvpButton.addTarget(self, action: #selector(didTapGoingButton), for: .touchUpInside)
        rsvpButton.layer.cornerRadius = 5
        rsvpButton.layer.masksToBounds = true
        
        configureSubviewLayout()
    }
    
    private func markGoing(){
        let userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        if !event.usersGoing.contains(User(userId: userId)) {
            event.markGoing(completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                
                guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
                
                if let idx = strongSelf.event.usersNotGoing.firstIndex(of: User(userId: userId)) {
                    strongSelf.event.usersNotGoing.remove(at: idx)
                }
                strongSelf.event.usersGoing.append(User(userId: userId))
                
                DispatchQueue.main.async {
                    strongSelf.goingUI()
                    strongSelf.delegate?.removeCell(indexPath: strongSelf.iPath)
                }

            })
        }
        
    }
    
    private func markNotGoing() {
        let userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        if !event.usersNotGoing.contains(User(userId: userId)) {
            event.markNotGoing(completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                
                guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
                
                if let idx = strongSelf.event.usersGoing.firstIndex(of: User(userId: userId)) {
                    strongSelf.event.usersGoing.remove(at: idx)
                }
                strongSelf.event.usersNotGoing.append(User(userId: userId))
                
                DispatchQueue.main.async {
                    strongSelf.notGoingUI()
                    strongSelf.delegate?.removeCell(indexPath: strongSelf.iPath)
                }
            })
        }
    }
    
    private func goingUI(){
        rsvpButton.setTitle("Going", for: .normal)
        rsvpButton.backgroundColor = .zipGreen
    }
    
    private func notGoingUI() {
        rsvpButton.setTitle("Not Going", for: .normal)
        rsvpButton.backgroundColor = .zipRed
    }
    
    @objc func didTapGoingButton(){
        goingDD.show()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIndexPath(indexPath: IndexPath) {
        iPath = indexPath
    }
    
    override func configure(_ event: Event) {
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
        if event.usersGoing.contains(User(userId: userId)) {
            goingUI()
        } else if event.usersNotGoing.contains(User(userId: userId)) {
            notGoingUI()
        } else {
            rsvpButton.backgroundColor = .zipGray
            rsvpButton.setTitle("RSVP", for: .normal)
        }
        rsvpButton.titleLabel?.font = .zipSubtitle2
        
        super.configure(event)
    }
    
    private func configureSubviewLayout() {
        contentView.addSubview(rsvpButton)
        rsvpButton.translatesAutoresizingMaskIntoConstraints = false
        rsvpButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        rsvpButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        rsvpButton.rightAnchor.constraint(equalTo: participantsLabel.rightAnchor).isActive = true
        rsvpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -15).isActive = true
    }
    
    
    @objc private func didTapRejectButton(){
        delegate?.removeCell(indexPath: iPath)
    }
    
   
}
