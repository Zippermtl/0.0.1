//
//  GrowingCellTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/2/21.
//

import UIKit



class GrowingCellTableViewCell: UITableViewCell {
    static let identifier = "GrowingIdentifier"
    
    weak var cellDelegate: GrowingCellProtocol?
    
    var textView: UITextView = {
        let textView = UITextView()
        
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.bounces = false
        textView.layer.cornerRadius = 5
        
        textView.backgroundColor = .zipGray
        textView.font = .zipBody
        textView.textColor = .white
        textView.tintColor = .white
        
        return textView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(with user: User){
        textView.text = user.bio
        if user.bio == "" {
            textView.text = "Hello, I'm " + user.firstName + " " + user.lastName + " and I'm new to Zipper"
        }
        
        textView.delegate = self
        
        
        contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        textView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        textView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }

}


extension GrowingCellTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let delegate = cellDelegate {
            delegate.updateHeightOfRow(self, textView)
            
            guard let text = textView.text else {
                return
            }
            delegate.updateValue(value: text)
        }
    }
}
