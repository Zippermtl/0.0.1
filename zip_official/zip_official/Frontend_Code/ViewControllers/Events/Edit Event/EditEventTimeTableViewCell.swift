//
//  EditEventTimeTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/22.
//

import UIKit
extension EditEventProfileViewController {
    internal class EditEventTimeTableViewCell: EditProfileTableViewCell {
        static let identifier = "startendtimecell"
        
        private var datePicker: EventDatePickerView!
        private var event: Event!
        
        
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func configure(event: Event){
            self.event = event
            datePicker = EventDatePickerView(event: event)
            datePicker.setInitialData()

            super.configure(label: "Date/Time")
            addSubviews()
            configureSubviewLayout()
        }
        
        private func addSubviews(){
            rightView.addSubview(datePicker)
        }
        
        private func configureSubviewLayout(){
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            datePicker.topAnchor.constraint(equalTo: rightView.topAnchor,constant: 5).isActive = true
            datePicker.bottomAnchor.constraint(equalTo: rightView.bottomAnchor,constant: -5).isActive = true
            datePicker.rightAnchor.constraint(equalTo: rightView.rightAnchor,constant: -5).isActive = true
            datePicker.widthAnchor.constraint(greaterThanOrEqualTo: rightView.widthAnchor).isActive = true
        }
    }
}
