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

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.textView = UITextView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .zipGray
        
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.bounces = false
        textView.layer.cornerRadius = 5
        
        textView.backgroundColor = .zipGray
        textView.font = .zipTextFill
        textView.textColor = .white
        textView.tintColor = .white
        
        addSubviews()
        configureSubviewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(label: String, content: String) {
        textView.text = content
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
}


extension EditTextFieldTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        cellDelegate?.updateHeightOfRow(self, textView)
        cellDelegate?.updateValue(value: textView.text ?? "")
    }
    
}
