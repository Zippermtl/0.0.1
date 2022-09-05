//
//  EditTextFieldTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/6/22.
//

import UIKit



protocol GrowingCellProtocol: AnyObject {
    func updateHeightOfRow(_ cell: UITableViewCell, _ view: UIView)
    func updateValue(value: String)
}


class EditTextFieldTableViewCell: EditProfileTableViewCell {
    static let identifier = "growingTextField"

    let textView: UITextView
    weak var cellDelegate: GrowingCellProtocol?
    
    var acceptableCharacters: String?
    var charLimit: Int?
    var placeHolder: String? { didSet {
        if textView.text == nil || textView.text == "" {
            textView.text = placeHolder
            textView.textColor = .zipVeryLightGray
        }
    }}
    
    var keyboardType : UIKeyboardType = .default {
        didSet {
            textView.keyboardType = keyboardType
        }
    }

    var saveFunc: ((String) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.textView = UITextView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .zipGray
        
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.bounces = false
        textView.layer.cornerRadius = 5
        
        textView.backgroundColor = .zipGray
        textView.font = .zipTextFill
        textView.textColor = .white
        textView.tintColor = .white
        
        addSubviews()
        configureSubviewLayout()
        addDoneButtonOnKeyboard()
    }
    
    func addDoneButtonOnKeyboard(){
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()
        
        textView.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        textView.resignFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(label: String, content: String, saveFunc: @escaping (String) -> Void) {
        textView.text = content
        self.saveFunc = saveFunc
        super.configure(label: label)
    }
    
    private func addSubviews(){
        rightView.addSubview(textView)
    }
    
    private func configureSubviewLayout() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
    }
    
    public func saveValue() {
        guard let saveFunc = saveFunc else {
            print("retunring")
            return
        }
        print("SAVING TEXT")
        saveFunc(textView.text)
    }
}


extension EditTextFieldTableViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty && placeHolder != nil{
            textView.text = placeHolder!
            textView.textColor = UIColor.lightGray
        }
        saveValue()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var cLimit = true
        var accepted = true
        if let limit = charLimit {
            let currentString = (textView.text ?? "") as NSString
            let str = currentString.replacingCharacters(in: range, with: text)
            cLimit = str.count <= limit
        }
        
        if let aChars = acceptableCharacters {
            let cs = NSCharacterSet(charactersIn: aChars).inverted
            let filtered = text.components(separatedBy: cs).joined(separator: "")
            accepted = !(text == filtered)
        }
        
        return cLimit && accepted
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor != .white {
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    
}
