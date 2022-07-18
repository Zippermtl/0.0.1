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
        
        private let endDatePicker: UIDatePicker
        private let endTimePicker: UIDatePicker
        private let startDateField: UITextField
        private let startTimeField: UITextField
        private let endDateField: UITextField
        private let endTimeField: UITextField
        private var event: Event!
        
        
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.startDateField = UITextField()
            self.startTimeField = UITextField()
            self.endDateField = UITextField()
            self.endTimeField = UITextField()
    
            self.endDatePicker = UIDatePicker()
            self.endTimePicker = UIDatePicker()
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            configureTextFields()
            addSubviews()
            configureSubviewLayout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        public func configure(event: Event){
            self.event = event
            super.configure(label: "Date/Time")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            startDateField.text = formatter.string(from: event.startTime)
            endDateField.text = formatter.string(from: event.endTime)
            
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            startTimeField.text = formatter.string(from: event.startTime)
            endTimeField.text = formatter.string(from: event.endTime)
        }
        
        private func addSubviews(){
            rightView.addSubview(startTimeField)
            rightView.addSubview(startDateField)
            rightView.addSubview(endTimeField)
            rightView.addSubview(endDateField)
        }
        
        private func configureSubviewLayout(){
            startDateField.translatesAutoresizingMaskIntoConstraints = false
            startDateField.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
            startDateField.topAnchor.constraint(equalTo: rightView.topAnchor,constant: 5).isActive = true
            
            startTimeField.translatesAutoresizingMaskIntoConstraints = false
            startTimeField.leftAnchor.constraint(equalTo: startDateField.rightAnchor, constant: 10).isActive = true
            startTimeField.topAnchor.constraint(equalTo: startDateField.topAnchor).isActive = true
            
            endDateField.translatesAutoresizingMaskIntoConstraints = false
            endDateField.leftAnchor.constraint(equalTo: startDateField.leftAnchor).isActive = true
            endDateField.topAnchor.constraint(equalTo: startTimeField.bottomAnchor,constant: 10).isActive = true
            
            endTimeField.translatesAutoresizingMaskIntoConstraints = false
            endTimeField.topAnchor.constraint(equalTo: endDateField.topAnchor).isActive = true
            endTimeField.leftAnchor.constraint(equalTo: endDateField.rightAnchor, constant: 10).isActive = true
            endTimeField.bottomAnchor.constraint(equalTo: rightView.bottomAnchor,constant: -5).isActive = true

        }
      
        
        private func checkStartBeforeEnd() {
            if event.startTime > event.endTime {
                endTimeField.text = ""
                endDateField.text = ""
            }
            
            endTimePicker.minimumDate = Date(timeInterval: TimeInterval(3600), since: event.startTime)
            endDatePicker.minimumDate = event.startTime
        }
        
        @objc func startDateChanged(sender: UIDatePicker){
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            startDateField.text = formatter.string(from: sender.date)
            
            event.startTime = combineDateWithTime(date: sender.date, time: event.startTime) ?? event.startTime
            
            checkStartBeforeEnd()
        }

        @objc func startTimeChanged(sender: UIDatePicker){
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            startTimeField.text = formatter.string(from: sender.date)
            
            event.startTime = combineDateWithTime(date: event.startTime, time: sender.date)!
            
            checkStartBeforeEnd()
        }
        
        @objc func endDateChanged(sender: UIDatePicker){
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            endDateField.text = formatter.string(from: sender.date)
            
            event.endTime = combineDateWithTime(date: sender.date, time: event.endTime) ?? event.endTime
            
            let diff = Calendar.current.dateComponents([.day], from: event.startTime, to: event.endTime)
            if diff.day == 0 {
                endTimePicker.minimumDate = Date(timeInterval: TimeInterval(3600), since: event.startTime)
            } else {
                endTimePicker.minimumDate = .none
            }
        }
        
        @objc func endTimeChanged(sender: UIDatePicker){
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            endTimeField.text = formatter.string(from: sender.date)
            
            event.endTime = combineDateWithTime(date: event.startTime, time: sender.date)!
        }
        
        func combineDateWithTime(date: Date, time: Date) -> Date? {
            let calendar = Calendar.current
            
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
            
            let mergedComponments = NSDateComponents()
            mergedComponments.year = dateComponents.year ?? 2021
            mergedComponments.month = dateComponents.month ?? 1
            mergedComponments.day = dateComponents.day ?? 1
            mergedComponments.hour = timeComponents.hour ?? 12
            mergedComponments.minute = timeComponents.minute ?? 0
            mergedComponments.second = timeComponents.second ?? 0
            
            return calendar.date(from: mergedComponments as DateComponents)
        }
        
        
        private func configureTextFields() {
            endDatePicker.datePickerMode = .date
            endDatePicker.minuteInterval = 15
            endDatePicker.preferredDatePickerStyle = .inline
            endDatePicker.minimumDate = Date()
            endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)

            
            endDateField.inputView = endDatePicker
            
            
            endTimePicker.datePickerMode = .time
            endTimePicker.minuteInterval = 15
            endTimePicker.preferredDatePickerStyle = .wheels
            endTimePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)

            endTimeField.inputView = endTimePicker
            
            startDateField.attributedPlaceholder = NSAttributedString(string: "Date",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
            startDateField.font = .zipBody
            startDateField.borderStyle = .roundedRect
            startDateField.tintColor = .white
            startDateField.backgroundColor = .zipLightGray
            startDateField.textColor = .white
            startDateField.adjustsFontSizeToFitWidth = true
            startDateField.minimumFontSize = 10.0
            startDateField.textAlignment = .center

                
            let startDatePicker = UIDatePicker()
            startDatePicker.datePickerMode = .date
            startDatePicker.minuteInterval = 15
            startDatePicker.preferredDatePickerStyle = .inline
            
            startDatePicker.minimumDate = Date()
            startDateField.inputView = startDatePicker
                
            startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
            

            startTimeField.attributedPlaceholder = NSAttributedString(string: "Time",
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
            startTimeField.font = .zipBody
            startTimeField.borderStyle = .roundedRect
            startTimeField.tintColor = .white
            startTimeField.backgroundColor = .zipLightGray
            startTimeField.textColor = .white
            startTimeField.adjustsFontSizeToFitWidth = true
            startTimeField.minimumFontSize = 10.0
            startTimeField.textAlignment = .center
                
            let startTimePicker = UIDatePicker()
            startTimePicker.datePickerMode = .time
            startTimePicker.minuteInterval = 15
            startTimePicker.preferredDatePickerStyle = .wheels
            startTimeField.inputView = startTimePicker
                
            startTimePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
            
            
            endTimeField.attributedPlaceholder = NSAttributedString(string: "Time",
                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
            endTimeField.font = .zipBody
            endTimeField.borderStyle = .roundedRect
            endTimeField.tintColor = .white
            endTimeField.backgroundColor = .zipLightGray
            endTimeField.textColor = .white
            endTimeField.adjustsFontSizeToFitWidth = true
            endTimeField.minimumFontSize = 10.0
            endTimeField.textAlignment = .center
            
            
            endDateField.attributedPlaceholder = NSAttributedString(string: "Date",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
            endDateField.font = .zipBody
            endDateField.borderStyle = .roundedRect
            endDateField.tintColor = .white
            endDateField.backgroundColor = .zipLightGray
            endDateField.textColor = .white
            endDateField.adjustsFontSizeToFitWidth = true
            endDateField.minimumFontSize = 10.0
            endDateField.textAlignment = .center
        }
        
    }
}
