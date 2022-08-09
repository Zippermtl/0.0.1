//
//  GenderSelectViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/9/22.
//

import UIKit

protocol GenderCellDelegate: AnyObject {
    func selectGender(s: String)
    
}

class GenderSelectViewController: UIViewController {
    
    var gender = ""
    
    let maleCell: GenderCell
    let femaleCell: GenderCell
    let otherCell: GenderCell
    let preferNotToSayCell: GenderCell

    init() {
        maleCell = GenderCell(text: "Male")
        femaleCell = GenderCell(text: "Female")
        otherCell = GenderCell(text: "Other")
        preferNotToSayCell = GenderCell(text: "Prefer Not to Say")
        super.init(nibName: nil, bundle: nil)
        title = "Select Your Gender"
        
        view.addSubview(maleCell)
        view.addSubview(femaleCell)
        view.addSubview(otherCell)
        view.addSubview(preferNotToSayCell)
        
        maleCell.translatesAutoresizingMaskIntoConstraints = false
        maleCell.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        maleCell.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        maleCell.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
        femaleCell.translatesAutoresizingMaskIntoConstraints = false
        femaleCell.topAnchor.constraint(equalTo: maleCell.topAnchor, constant: 10).isActive = true
        femaleCell.leftAnchor.constraint(equalTo: maleCell.leftAnchor).isActive = true
        femaleCell.rightAnchor.constraint(equalTo: maleCell.rightAnchor).isActive = true
        
        otherCell.translatesAutoresizingMaskIntoConstraints = false
        otherCell.topAnchor.constraint(equalTo: femaleCell.topAnchor, constant: 10).isActive = true
        otherCell.leftAnchor.constraint(equalTo: femaleCell.leftAnchor).isActive = true
        otherCell.rightAnchor.constraint(equalTo: femaleCell.rightAnchor).isActive = true
        
        preferNotToSayCell.translatesAutoresizingMaskIntoConstraints = false
        preferNotToSayCell.topAnchor.constraint(equalTo: otherCell.topAnchor, constant: 10).isActive = true
        preferNotToSayCell.leftAnchor.constraint(equalTo: otherCell.leftAnchor).isActive = true
        preferNotToSayCell.rightAnchor.constraint(equalTo: otherCell.rightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


}

extension GenderSelectViewController: GenderCellDelegate {
    func selectGender(s: String) {
        gender = s
    }
}

extension GenderSelectViewController {
    
    internal class GenderCell: UIView {
        weak var delegate: GenderCellDelegate?
        
        let typeLabel: UILabel
        let selectionButton: UIButton
        
        init(text: String) {
            typeLabel = UILabel.zipTextFill()
            selectionButton = UIButton()
            super.init(frame: .zero)
            backgroundColor = .zipVeryLightGray
            layer.masksToBounds = true
            layer.cornerRadius = 15
            heightAnchor.constraint(equalToConstant: 40).isActive = true

            
            typeLabel.text = text
            
            selectionButton.setImage(UIImage(systemName: "circle")?.withRenderingMode(.alwaysOriginal).withTintColor(.white ), for: .normal)
            selectionButton.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue), for: .normal)
            
            addSubview(typeLabel)
            addSubview(selectionButton)
            
            typeLabel.translatesAutoresizingMaskIntoConstraints = false
            typeLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            typeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
            
            selectionButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            selectionButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        }
        
        @objc private func didTapSwitch() {
            selectionButton.isSelected = !selectionButton.isSelected
            delegate?.selectGender(s: typeLabel.text!)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
