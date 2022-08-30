//
//  EventDatePickerView.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/18/22.
//

import UIKit

class EventDatePickerView: UIView {
    var isSet: Bool {
        get {
            return (startDateField.text != "" &&
                   startTimeField.text != "" &&
                   endTimeField.text != "" &&
                   endDateField.text != "")
        }
    }
    
    var event: Event
    private let endDatePicker: UIDatePicker
    private let endTimePicker: UIDatePicker
    private let startDatePicker: UIDatePicker
    private let startTimePicker: UIDatePicker

    
    let startDateField: UITextField
    let startTimeField: UITextField
    let endDateField: UITextField
    let endTimeField: UITextField
    
    init(event: Event) {
        self.event = event
        self.startDateField = UITextField()
        self.startTimeField = UITextField()
        self.endDateField = UITextField()
        self.endTimeField = UITextField()
        
        self.startTimePicker = UIDatePicker()
        self.startDatePicker = UIDatePicker()
        self.endDatePicker = UIDatePicker()
        self.endTimePicker = UIDatePicker()
        
        super.init(frame: .zero)
        configurePickers()
        configureFields()
        addSubviews()
        configureSubviewLayout()
    }
    
    init() {
        self.event = Event()
        self.startDateField = UITextField()
        self.startTimeField = UITextField()
        self.endDateField = UITextField()
        self.endTimeField = UITextField()
        
        self.startTimePicker = UIDatePicker()
        self.startDatePicker = UIDatePicker()
        self.endDatePicker = UIDatePicker()
        self.endTimePicker = UIDatePicker()
        super.init(frame: .zero)
        configurePickers()
        configureFields()
        addSubviews()
        configureSubviewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setEvent(_ event: Event) {
        self.event = event
    }
    
    public func setInitialData() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        startDateField.text = formatter.string(from: event.startTime)
        endDateField.text = formatter.string(from: event.endTime)
        
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        startTimeField.text = formatter.string(from: event.startTime)
        endTimeField.text = formatter.string(from: event.endTime)
    }
    
    private func setMinMax() {
        endDatePicker.minimumDate = event.startTime
        endDatePicker.maximumDate = Date(timeInterval: TimeInterval(604800), since: event.startTime)
        
        let startEndDiff = Calendar.current.dateComponents([.day], from: event.startTime, to: event.endTime)
        if startEndDiff.day == 0 {
            endTimePicker.minimumDate = event.startTime
        } else {
            endTimePicker.minimumDate = .none
        }
        
        if Calendar.current.isDateInToday(event.startTime) {
            startTimePicker.minimumDate = Date()
        } else {
            startTimePicker.minimumDate = .none
        }

    }
    
    private func resetEndTime() {
        if event.startTime > event.endTime {
            endTimeField.text = ""
            endDateField.text = ""
        }
    }
    
    @objc func startDateChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        startDateField.text = formatter.string(from: sender.date)
        event.startTime = combineDateWithTime(date: sender.date, time: event.startTime) ?? event.startTime

        resetEndTime()
        setMinMax()
    }

    @objc func startTimeChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        startTimeField.text = formatter.string(from: sender.date)
        
        event.startTime = combineDateWithTime(date: event.startTime, time: sender.date)!
        
        resetEndTime()
        setMinMax()
    }
    
    @objc func endDateChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        endDateField.text = formatter.string(from: sender.date)

        event.endTime = combineDateWithTime(date: sender.date, time: event.endTime) ?? event.endTime
        setMinMax()
    }
    
    @objc func endTimeChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        endTimeField.text = formatter.string(from: sender.date)
        
        event.endTime = combineDateWithTime(date: event.startTime, time: sender.date)!
        setMinMax()
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
    
    private func configurePickers(){
        endDatePicker.datePickerMode = .date
        endDatePicker.minuteInterval = 15
        endDatePicker.preferredDatePickerStyle = .inline
        endDatePicker.minimumDate = Date(timeInterval: TimeInterval(3600), since: Date())
        endDatePicker.maximumDate = Date(timeInterval: TimeInterval(604800), since: Date())
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        
        endTimePicker.datePickerMode = .time
        endTimePicker.minuteInterval = 15
        endTimePicker.preferredDatePickerStyle = .wheels
        endTimePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)
        
        startDatePicker.datePickerMode = .date
        startDatePicker.minuteInterval = 15
        startDatePicker.preferredDatePickerStyle = .inline
        startDatePicker.minimumDate = Date()
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)

        startTimePicker.datePickerMode = .time
        startTimePicker.minuteInterval = 15
        startTimePicker.preferredDatePickerStyle = .wheels
            
        startTimePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
    }
    
    private func configureFields(){
        startDateField.delegate = self
        startTimeField.delegate = self
        endDateField.delegate = self
        endTimeField.delegate = self
        
        endDateField.inputView = endDatePicker
        endTimeField.inputView = endTimePicker
        startDateField.inputView = startDatePicker
        startTimeField.inputView = startTimePicker
        
        startDateField.attributedPlaceholder = NSAttributedString(string: "Date",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        startDateField.font = .zipTextFill
        startDateField.borderStyle = .roundedRect
        startDateField.tintColor = .white
        startDateField.backgroundColor = .zipLightGray
        startDateField.textColor = .white
        startDateField.adjustsFontSizeToFitWidth = true
        startDateField.minimumFontSize = 10.0
        startDateField.textAlignment = .center
            

        startTimeField.attributedPlaceholder = NSAttributedString(string: "Time",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        startTimeField.font = .zipTextFill
        startTimeField.borderStyle = .roundedRect
        startTimeField.tintColor = .white
        startTimeField.backgroundColor = .zipLightGray
        startTimeField.textColor = .white
        startTimeField.adjustsFontSizeToFitWidth = true
        startTimeField.minimumFontSize = 10.0
        startTimeField.textAlignment = .center

        
        endTimeField.attributedPlaceholder = NSAttributedString(string: "Time",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        endTimeField.font = .zipTextFill
        endTimeField.borderStyle = .roundedRect
        endTimeField.tintColor = .white
        endTimeField.backgroundColor = .zipLightGray
        endTimeField.textColor = .white
        endTimeField.adjustsFontSizeToFitWidth = true
        endTimeField.minimumFontSize = 10.0
        endTimeField.textAlignment = .center
        
        
        endDateField.attributedPlaceholder = NSAttributedString(string: "Date",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        endDateField.font = .zipTextFill
        endDateField.borderStyle = .roundedRect
        endDateField.tintColor = .white
        endDateField.backgroundColor = .zipLightGray
        endDateField.textColor = .white
        endDateField.adjustsFontSizeToFitWidth = true
        endDateField.minimumFontSize = 10.0
        endDateField.textAlignment = .center
    }
    
    private func addSubviews(){
        addSubview(startDateField)
        addSubview(startTimeField)
        addSubview(endDateField)
        addSubview(endTimeField)
    }
    
    private func configureSubviewLayout() {
        startDateField.translatesAutoresizingMaskIntoConstraints = false
        startDateField.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        startDateField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        startTimeField.translatesAutoresizingMaskIntoConstraints = false
        startTimeField.leftAnchor.constraint(equalTo: startDateField.rightAnchor, constant: 10).isActive = true
        startTimeField.centerYAnchor.constraint(equalTo: startDateField.centerYAnchor).isActive = true
        
        endDateField.translatesAutoresizingMaskIntoConstraints = false
        endDateField.leftAnchor.constraint(equalTo: startDateField.leftAnchor).isActive = true
        endDateField.topAnchor.constraint(equalTo: startDateField.bottomAnchor, constant: 5).isActive = true
        endDateField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        endTimeField.translatesAutoresizingMaskIntoConstraints = false
        endTimeField.centerYAnchor.constraint(equalTo: endDateField.centerYAnchor).isActive = true
        endTimeField.leftAnchor.constraint(equalTo: startTimeField.leftAnchor).isActive = true
    }
    

}

extension EventDatePickerView: UITextFieldDelegate {
    private func roundUpToNearest15(date: Date) -> Date {
        let minuteGranuity = CGFloat(15)
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minute = CGFloat(calendar.component(.minute, from: date))
        
        // Round down to nearest date:
        let ceilingMinute = Int(ceil(minute / minuteGranuity) * minuteGranuity)%60
        if minute != 0 && ceilingMinute == 0 { hour += 1 } // round hour
        
        let ceilingDate = calendar.date(bySettingHour: hour,
                                        minute: ceilingMinute,
                                        second: 0,
                                        of: date)!
        return ceilingDate
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "" {
            if textField == startDateField {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                textField.text = formatter.string(from: Date())
                event.startTime = combineDateWithTime(date: Date(), time: event.startTime)!
                startDatePicker.date = event.startTime

            }
            
            else if textField == startTimeField {
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                
                let date = Date()
                let roundSeconds = ceil(date.timeIntervalSinceReferenceDate/900.0)*900.0
                let roundedDate = date.round(precision: roundSeconds)
                
                textField.text = formatter.string(from: roundedDate)
                event.startTime = combineDateWithTime(date: event.startTime, time: roundedDate)!
                startTimePicker.date = event.startTime
            }
            
            else if textField == endDateField {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                textField.text = formatter.string(from: Date(timeInterval: TimeInterval(3600), since: event.startTime))
                event.endTime = combineDateWithTime(date: Date(timeInterval: TimeInterval(3600), since: event.startTime), time: event.endTime)!
                endDatePicker.date = event.endTime
            }
            
            else if textField == endTimeField {
                let minEndTime = Date(timeInterval: 60*60, since: event.startTime)
                
                let roundSeconds = ceil(minEndTime.timeIntervalSinceReferenceDate/900.0)*900.0
                let roundedDate = minEndTime.round(precision: roundSeconds)
                
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                textField.text = formatter.string(from: roundedDate)
                event.endTime = combineDateWithTime(date: event.endTime, time: roundedDate)!
                endTimePicker.date = event.endTime
            }
        }
    }
}
