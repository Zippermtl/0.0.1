//
//  EditPromoterViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/8/22.
//

import UIKit

class EditPromoterViewController: EditEventProfileViewController, UITextFieldDelegate {
    var price: Double?
    var link: URL?
    let priceField: UITextField
    let linkField: UITextField
    let sellTicketsSwitch: UISwitch
    var isOpen : Bool
    
    
    override init(event: Event) {
        sellTicketsSwitch = UISwitch()
        priceField = UITextField()
        linkField = UITextField()
        if let pEvent = event as? PromoterEvent,
           let price = pEvent.price {
            priceField.text = "$" + String(format: "%.2f", price)
            linkField.text = pEvent.buyTicketsLink?.absoluteString
            isOpen = true
        } else {
            isOpen = false
        }
        sellTicketsSwitch.isOn = isOpen

        super.init(event: event)
        priceField.delegate = self
        priceField.backgroundColor = .zipLightGray
        priceField.borderStyle = .roundedRect
        priceField.keyboardType = .decimalPad
        
        linkField.delegate = self
        linkField.backgroundColor = .zipLightGray
        linkField.borderStyle = .roundedRect

        sellTicketsSwitch.addTarget(self, action: #selector(didTapSwitch(sender:)), for: .valueChanged)
        setupKeyboardHiding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var originalY : CGFloat?
    @objc private func keyboardWillShow(sender: NSNotification) {
        originalY = view.frame.origin.y
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentFirst() as? UITextView else {
            return
        }
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        if textFieldBottomY > keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY / 2) * -1
            view.frame.origin.y = newFrameY
        }
    }
    
    @objc private func keyboardWillHide(notification : NSNotification) {
        if let originalY = originalY {
            view.frame.origin.y = originalY
        }
    }
    
    private func noPriceOrLinkAlert() {
        let alert = UIAlertController(title: "Error",
                                      message: "You must have both a link and a price",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
    }
    
    override func didTapSave() {
        view.endEditing(true)
        guard let event = event as? PromoterEvent else {
            fatalError("EDITING PROMOTER EVENT FOR NON PROMOTER EVENT")
        }
        if (price == nil && link != nil) || (price != nil && link == nil) {
            noPriceOrLinkAlert()
            return
        }
        
        
        if !isOpen {
            event.price = nil
            event.buyTicketsLink = nil
        } else {
            if verifyUrl(urlString: link?.absoluteString) {
                event.price = price
                event.buyTicketsLink = link
            } else {
                let alert = UIAlertController(title: "Error: URL Unavailable",
                                                    message: "Please Enter a Valid URL to continue",
                                                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok",
                                                    style: .cancel,
                                                    handler: nil))
                
                present(alert, animated: true)
                return
            }
            
        }

        super.didTapSave()
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    
    @objc private func didTapSwitch(sender: UISwitch) {
        isOpen = !isOpen
        let indexPaths : [IndexPath] = [IndexPath(row: 0, section: 1),IndexPath(row: 1, section: 1)]
        switch sender.isOn {
        case true:
            tableView.insertRows(at: indexPaths, with: .automatic)
        case false:
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "price")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "link")

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        else {
            let header = UIView()
            let sellTicketsLabel = UILabel.zipTextFill()
            sellTicketsLabel.text = "Sell Tickets:"
            
            header.addSubview(sellTicketsLabel)
            header.addSubview(sellTicketsSwitch)

            sellTicketsLabel.translatesAutoresizingMaskIntoConstraints = false
            sellTicketsLabel.centerYAnchor.constraint(equalTo: sellTicketsSwitch.centerYAnchor).isActive = true
            sellTicketsLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
            sellTicketsLabel.leftAnchor.constraint(equalTo: header.leftAnchor,constant: 10).isActive = true
            
            sellTicketsSwitch.translatesAutoresizingMaskIntoConstraints = false
            sellTicketsSwitch.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
            sellTicketsSwitch.bottomAnchor.constraint(equalTo: header.bottomAnchor,constant: -5).isActive = true
            sellTicketsSwitch.rightAnchor.constraint(equalTo: header.rightAnchor,constant: -20).isActive = true
            return header
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            if isOpen {
                return 2
            } else {
                return 0
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        else { return 30 }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: return getTitleCell(tableView: tableView, indexPath: indexPath)
            case 1: return getTimeCell(tableView: tableView, indexPath: indexPath)
            case 2: return getLocationCell(tableView: tableView, indexPath: indexPath)
            case 3: return getBioCell(tableView: tableView, indexPath: indexPath)
            default: return UITableViewCell()
            }
        } else {
            switch indexPath.row {
            case 0: return getPriceCell(tableView: tableView, indexPath: indexPath)
            case 1: return getLinkCell(tableView: tableView, indexPath: indexPath)
            default: return UITableViewCell()
            }
        }
    }
    
    private func getPriceCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "price", for: indexPath)
        let priceLabel = UILabel.zipTextFill()
        priceLabel.text = "Price"
        
        let view = cell.contentView
        view.backgroundColor = .zipGray
        view.addSubview(priceLabel)
        view.addSubview(priceField)
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 10).isActive = true
        priceLabel.centerYAnchor.constraint(equalTo: priceField.centerYAnchor).isActive = true
        priceLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

        
        priceField.translatesAutoresizingMaskIntoConstraints = false
        priceField.topAnchor.constraint(equalTo: view.topAnchor,constant: 5).isActive = true
        priceField.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -5).isActive = true
        priceField.leftAnchor.constraint(equalTo: priceLabel.rightAnchor, constant: 10).isActive = true
        priceField.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true

        return cell
    }
    
    private func getLinkCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "link", for: indexPath)
        let linkLabel = UILabel.zipTextFill()
        linkLabel.text = "Link"
        
        let view = cell.contentView
        view.backgroundColor = .zipGray
        view.addSubview(linkLabel)
        view.addSubview(linkField)
        
        linkLabel.translatesAutoresizingMaskIntoConstraints = false
        linkLabel.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 10).isActive = true
        linkLabel.centerYAnchor.constraint(equalTo: linkField.centerYAnchor).isActive = true
        linkLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        linkField.translatesAutoresizingMaskIntoConstraints = false
        linkField.topAnchor.constraint(equalTo: view.topAnchor,constant: 5).isActive = true
        linkField.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -5).isActive = true
        linkField.leftAnchor.constraint(equalTo: linkLabel.rightAnchor, constant: 10).isActive = true
        linkField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        return cell
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == priceField {
            if textField.text == "" || textField.text == nil {
                textField.text = "$"
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == priceField {
            guard let text = textField.text else {
                price = nil
                return
            }
            if text == "$" {
                textField.text = nil
            }
            let priceString = text.suffix(text.count-1)
            price = Double(priceString)
            
            guard let price = price else {
                textField.text = nil
                return
            }
            textField.text = "$" + String(format: "%.2f", price)

        } else {
            guard let text = textField.text else {
                link = nil
                return
            }
            
            link = URL(string: text)
        }
        
        func verifyUrl (urlString: String?) -> Bool {
            if let urlString = urlString {
                if let url = NSURL(string: urlString) {
                    return UIApplication.shared.canOpenURL(url as URL)
                }
            }
            return false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == priceField {
            let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        }
        
        return true
    }
    
}

   

