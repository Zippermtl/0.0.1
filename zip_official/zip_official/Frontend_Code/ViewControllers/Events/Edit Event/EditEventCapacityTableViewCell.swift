//
//  EditEventCapacityTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/22.
//

import UIKit
extension EditEventProfileViewController {
    internal class EditEventCapacityTableViewCell: UITableViewCell, UITextFieldDelegate{
        static let identifier = "capacityCell"
        
        var event: Event!
        let capacitySlider: ResizeSlider
        private let capacityLabel: UILabel
        private let capacityNumField: UITextField
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.capacityNumField = UITextField()
            self.capacitySlider = ResizeSlider()
            self.capacityLabel = UILabel.zipTextFill()
        
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.backgroundColor = .zipGray
            
            capacityNumField.attributedPlaceholder = NSAttributedString(string: "Date",
                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
            capacityNumField.font = .zipBody
            capacityNumField.borderStyle = .roundedRect
            capacityNumField.tintColor = .white
            capacityNumField.returnKeyType = .continue
            capacityNumField.backgroundColor = .zipLightGray
            capacityNumField.textColor = .white
            capacityNumField.adjustsFontSizeToFitWidth = true
            capacityNumField.minimumFontSize = 10.0
            capacityNumField.textAlignment = .center
            capacityNumField.keyboardType = .numberPad
            
            capacitySlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
            capacitySlider.minimumValue = 1
            capacitySlider.maximumValue = 501
            
            capacitySlider.trackHeight = 2
            capacitySlider.minimumTrackTintColor = .zipVeryLightGray
            
            capacityLabel.text = "Capacity"
            
            addSubviews()
            configureSubviewLayout()
        }
        
        public func configure(event: Event) {
            self.event = event
            if event.maxGuests == -1 {
                capacitySlider.value = 501
                capacityNumField.text = "∞"
            } else {
                capacitySlider.value = Float(event.maxGuests)
                capacityNumField.text = event.maxGuests.description
            }
        }
        
        @objc func sliderChanged(_ sender: UISlider){
            if sender.value == 501 {
                capacityNumField.text = "∞"
                event.maxGuests = 0
            } else {
                capacityNumField.text = Int(sender.value).description
                event.maxGuests = Int(sender.value)
            }
            
        }
        
        private func addSubviews() {
            contentView.addSubview(capacityLabel)
            contentView.addSubview(capacityNumField)
            contentView.addSubview(capacitySlider)
        }
        
        private func configureSubviewLayout(){
            capacityLabel.translatesAutoresizingMaskIntoConstraints = false
            capacityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
            capacityLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
            
            capacityNumField.translatesAutoresizingMaskIntoConstraints = false
            capacityNumField.topAnchor.constraint(equalTo: capacityLabel.bottomAnchor,constant: 10).isActive = true
            capacityNumField.leftAnchor.constraint(equalTo: capacityLabel.leftAnchor).isActive = true
            capacityNumField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true

            
            capacitySlider.translatesAutoresizingMaskIntoConstraints = false
            capacitySlider.topAnchor.constraint(equalTo: capacityNumField.topAnchor).isActive = true
            capacitySlider.leftAnchor.constraint(equalTo: capacityNumField.rightAnchor, constant: 10).isActive = true
            capacitySlider.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            guard let numString = textField.text,
                  let num = Float(numString) else {
                return
            }
                
            capacitySlider.value = num
            sliderChanged(capacitySlider)
        }
        
        
    }
}

