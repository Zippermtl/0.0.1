//
//  NotificationsSettingsCellTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//

import UIKit

class SettingsCellTableViewCell: UITableViewCell {
    static let identifier = "settingsCell"
    
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
            if textLabel!.text == "Delete Account" {
                textLabel!.textColor = .red
            }
            textLabel?.font = .zipBody
            switchControl.isHidden = !sectionType.containsSwitch
            disclosureIndicator.isHidden = !sectionType.containsDisclosureIndiciated

        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.onTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)

        switchControl.translatesAutoresizingMaskIntoConstraints = false
        accessoryView = switchControl
        return switchControl
    }()
    
    lazy var disclosureIndicator: UIView = {
        let view = UIView()
        let img = UIImageView(image: UIImage(systemName: "chevron.forward")?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        view.addSubview(img)
        img.translatesAutoresizingMaskIntoConstraints = false
        img.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        img.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        accessoryView = view
        return view
    }()
    

    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        backgroundColor = .clear
        selectionStyle = .none

        addSubview(disclosureIndicator)
        disclosureIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        disclosureIndicator.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
                
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
