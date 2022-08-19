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
        
        private let datePicker: EventDatePickerView
        private var event: Event!
        
        
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            datePicker = EventDatePickerView()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            addSubviews()
            configureSubviewLayout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        public func configure(event: Event){
            self.event = event
            datePicker.setEvent(event)
            super.configure(label: "Date/Time")
            datePicker.setInitialData()
        }
        
        private func addSubviews(){
            rightView.addSubview(datePicker)
        }
        
        private func configureSubviewLayout(){
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            datePicker.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
            datePicker.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
            datePicker.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
            datePicker.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
        }
    }
}
