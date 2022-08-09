//
//  LoginViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/5/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import DropDown

protocol registrationCompleteProtocol{
    func startLocationTracking()
}

class LoginViewController: UIViewController {
    var countryDictionary  = ["AF":93,
                              "AL":355,
                              "DZ":213,
                              "AS":1,
                              "AD":376,
                              "AO":244,
                              "AI":1,
                              "AG":1,
                              "AR":54,
                              "AM":374,
                              "AW":297,
                              "AU":61,
                              "AT":43,
                              "AZ":994,
                              "BS":1,
                              "BH":973,
                              "BD":880,
                              "BB":1,
                              "BY":375,
                              "BE":32,
                              "BZ":501,
                              "BJ":229,
                              "BM":1,
                              "BT":975,
                              "BA":387,
                              "BW":267,
                              "BR":55,
                              "IO":246,
                              "BG":359,
                              "BF":226,
                              "BI":257,
                              "KH":855,
                              "CM":237,
                              "CA":1,
                              "CV":238,
                              "KY":345,
                              "CF":236,
                              "TD":235,
                              "CL":56,
                              "CN":86,
                              "CX":61,
                              "CO":57,
                              "KM":269,
                              "CG":242,
                              "CK":682,
                              "CR":506,
                              "HR":385,
                              "CU":53,
                              "CY":537,
                              "CZ":420,
                              "DK":45,
                              "DJ":253,
                              "DM":1,
                              "DO":1,
                              "EC":593,
                              "EG":20,
                              "SV":503,
                              "GQ":240,
                              "ER":291,
                              "EE":372,
                              "ET":251,
                              "FO":298,
                              "FJ":679,
                              "FI":358,
                              "FR":33,
                              "GF":594,
                              "PF":689,
                              "GA":241,
                              "GM":220,
                              "GE":995,
                              "DE":49,
                              "GH":233,
                              "GI":350,
                              "GR":30,
                              "GL":299,
                              "GD":1,
                              "GP":590,
                              "GU":1,
                              "GT":502,
                              "GN":224,
                              "GW":245,
                              "GY":595,
                              "HT":509,
                              "HN":504,
                              "HU":36,
                              "IS":354,
                              "IN":91,
                              "ID":62,
                              "IQ":964,
                              "IE":353,
                              "IL":972,
                              "IT":39,
                              "JM":1,
                              "JP":81,
                              "JO":962,
                              "KZ":77,
                              "KE":254,
                              "KI":686,
                              "KW":965,
                              "KG":996,
                              "LV":371,
                              "LB":961,
                              "LS":266,
                              "LR":231,
                              "LI":423,
                              "LT":370,
                              "LU":352,
                              "MG":261,
                              "MW":265,
                              "MY":60,
                              "MV":960,
                              "ML":223,
                              "MT":356,
                              "MH":692,
                              "MQ":596,
                              "MR":222,
                              "MU":230,
                              "YT":262,
                              "MX":52,
                              "MC":377,
                              "MN":976,
                              "ME":382,
                              "MS":1,
                              "MA":212,
                              "MM":95,
                              "NA":264,
                              "NR":674,
                              "NP":977,
                              "NL":31,
                              "AN":599,
                              "NC":687,
                              "NZ":64,
                              "NI":505,
                              "NE":227,
                              "NG":234,
                              "NU":683,
                              "NF":672,
                              "MP":1,
                              "NO":47,
                              "OM":968,
                              "PK":92,
                              "PW":680,
                              "PA":507,
                              "PG":675,
                              "PY":595,
                              "PE":51,
                              "PH":63,
                              "PL":48,
                              "PT":351,
                              "PR":1,
                              "QA":974,
                              "RO":40,
                              "RW":250,
                              "WS":685,
                              "SM":378,
                              "SA":966,
                              "SN":221,
                              "RS":381,
                              "SC":248,
                              "SL":232,
                              "SG":65,
                              "SK":421,
                              "SI":386,
                              "SB":677,
                              "ZA":27,
                              "GS":500,
                              "ES":34,
                              "LK":94,
                              "SD":249,
                              "SR":597,
                              "SZ":268,
                              "SE":46,
                              "CH":41,
                              "TJ":992,
                              "TH":66,
                              "TG":228,
                              "TK":690,
                              "TO":676,
                              "TT":1,
                              "TN":216,
                              "TR":90,
                              "TM":993,
                              "TC":1,
                              "TV":688,
                              "UG":256,
                              "UA":380,
                              "AE":971,
                              "GB":44,
                              "US":1,
                              "UY":598,
                              "UZ":998,
                              "VU":678,
                              "WF":681,
                              "YE":967,
                              "ZM":260,
                              "ZW":263,
                              "BO":591,
                              "BN":673,
                              "CC":61,
                              "CD":243,
                              "CI":225,
                              "FK":500,
                              "GG":44,
                              "VA":379,
                              "HK":852,
                              "IR":98,
                              "IM":44,
                              "JE":44,
                              "KP":850,
                              "KR":82,
                              "LA":856,
                              "LY":218,
                              "MO":853,
                              "MK":389,
                              "FM":691,
                              "MD":373,
                              "MZ":258,
                              "PS":970,
                              "PN":872,
                              "RE":262,
                              "RU":7,
                              "BL":590,
                              "SH":290,
                              "KN":1,
                              "LC":1,
                              "MF":590,
                              "PM":508,
                              "VC":1,
                              "ST":239,
                              "SO":252,
                              "SJ":47,
                              "SY":963,
                              "TW":886,
                              "TZ":255,
                              "TL":670,
                              "VE":58,
                              "VN":84,
                              "VG":284,
                              "VI":340]

    private let stepLabel: UILabel
    private let titleLabel: UILabel
    private let explanationLabel: UILabel
    private var countryCode = "+1"
    private let spinner = JGProgressHUD(style: .light)
    var locationDelegate: registrationCompleteProtocol?
    private let countryCodeLabel: UILabel
    private let countryCodeDD: DropDown
    private let phoneField: UITextField
    private let continueButton: UIButton
    
    private let pageStatus1: StatusCheckView = {
        let s = StatusCheckView()
        s.select()
        return s
    }()
    
    private let pageStatus2 = StatusCheckView()

    init(isLogin: Bool){
        stepLabel = UILabel.zipSubtitle()
        titleLabel = UILabel.zipHeader()
        explanationLabel = UILabel.zipTextDetail()

        continueButton = UIButton()
        phoneField = UITextField()
        countryCodeLabel = UILabel.zipSubtitle2()
        countryCodeDD = DropDown()
        
        super.init(nibName: nil, bundle: nil)
        navigationItem.backBarButtonItem =  BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        

        stepLabel.text = "Step 1"
        
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        if isLogin {
            titleLabel.text = "Enter Your Phone Number to Log In"
        } else {
            titleLabel.text = "Enter Your Phone Number to Register"
        }
        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor = .zipBlue
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 8
        continueButton.layer.masksToBounds = true
        continueButton.titleLabel?.font = UIFont.zipSubtitle2
     
        phoneField.font = .zipSubtitle2
        phoneField.keyboardType = .numberPad
        phoneField.textAlignment = .center
        phoneField.autocapitalizationType = .none
        phoneField.autocorrectionType = .no
        phoneField.returnKeyType = .continue
        phoneField.layer.cornerRadius = 12
        phoneField.layer.borderWidth = 1
        phoneField.layer.borderColor = UIColor.zipLightGray.cgColor
        phoneField.attributedPlaceholder = NSAttributedString(string: "Phone Number....",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        
        phoneField.backgroundColor = .zipLightGray
        phoneField.tintColor = .white
        phoneField.textColor = .white
        phoneField.delegate = self
        
        let string              = "We will send a text with a verification code. Message and data rates may apply. Learn what happens when your number changes."
        let range               = (string as NSString).range(of: "Learn what happens when your number changes.")
        let attributedString    = NSMutableAttributedString(string: string)

        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSNumber(value: 1), range: range)
        attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.white, range: range)

        explanationLabel.attributedText = attributedString
        
        explanationLabel.lineBreakMode = .byWordWrapping
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .center
        explanationLabel.isUserInteractionEnabled = true
        
        let explanationTap = UITapGestureRecognizer(target: self, action: #selector(didTapLearnMore))
        explanationLabel.addGestureRecognizer(explanationTap)
        
        countryCodeLabel.text = "CA +1"
        countryCodeLabel.backgroundColor = .zipLightGray
        countryCodeLabel.textAlignment = .center
        countryCodeLabel.isUserInteractionEnabled = true
        countryCodeLabel.layer.masksToBounds = true
        countryCodeLabel.layer.cornerRadius = 12
        
        let openDDtap = UITapGestureRecognizer(target: self, action: #selector(openDD))
        countryCodeLabel.addGestureRecognizer(openDDtap)
        
        countryCodeDD.anchorView = countryCodeLabel
        countryCodeDD.dismissMode = .onTap
        countryCodeDD.direction = .bottom
        var DDStrings = [String]()
        for (key,value) in countryDictionary {
            DDStrings.append("\(key) +\(value)")
        }
        countryCodeDD.dataSource = DDStrings.sorted(by: { $0 < $1  })
        countryCodeDD.selectionAction = { [unowned self] (index: Int, item: String) in
            let components = item.split(separator: " ")
            self.countryCode = String(components[1])
            self.countryCodeLabel.text = item
        }
        
        addSubviews()
        configureSubviewLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func openDD() {
        countryCodeDD.show()
    }
    
    @objc private func didTapLearnMore(){
        
    }

    
    @objc private func didTapLoginButton(){
        phoneField.resignFirstResponder()
        spinner.show(in: view)
        continueButton.isEnabled = false
        if let text = phoneField.text, !text.isEmpty {
            var number = text.replacingOccurrences(of: " ", with: "")
            number = number.replacingOccurrences(of: "-", with: "")
            number = number.replacingOccurrences(of: "(", with: "")
            number = number.replacingOccurrences(of: ")", with: "")

            DatabaseManager.shared.startAuth(phoneNumber: "\(countryCode)\(number)", completion: { [weak self] error in
                self?.spinner.dismiss(animated: true)
                guard error == nil else {
                    let error = error!
                    let alert = UIAlertController(title: "Error",
                                                  message: "\(error.localizedDescription)",
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok",
                                                  style: .cancel,
                                                  handler: { [weak self] _ in
                        self?.continueButton.isEnabled = true
                        
                        
                    }))
                    
                    self?.present(alert, animated: true)
                    return
                    
                }
                self?.continueButton.isEnabled = true
                DispatchQueue.main.async {
                    print("creating user with id \("u\(number)")")
                    let vc = SMSCodeViewController(user: User(userId: "u\(number)"), number: number)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Log In/Register"
        view.backgroundColor = .zipGray
        continueButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        
    }
    
    
    private func addSubviews(){
        view.addSubview(stepLabel)
        view.addSubview(titleLabel)
        view.addSubview(countryCodeLabel)
        view.addSubview(phoneField)
        view.addSubview(explanationLabel)
        view.addSubview(continueButton)
        view.addSubview(pageStatus1)
        view.addSubview(pageStatus2)

    }
    
    
    private func configureSubviewLayout() {
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stepLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -5).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 125).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor,multiplier: 0.5).isActive = true
        
        countryCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        countryCodeLabel.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 15).isActive = true
        countryCodeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        countryCodeLabel.heightAnchor.constraint(equalTo: phoneField.heightAnchor).isActive = true
        countryCodeLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 80).isActive = true
        
        phoneField.translatesAutoresizingMaskIntoConstraints = false
        phoneField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        phoneField.leftAnchor.constraint(equalTo: countryCodeLabel.rightAnchor,constant: 10).isActive = true
        phoneField.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -15).isActive = true
        phoneField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.topAnchor.constraint(equalTo: phoneField.bottomAnchor,constant: 20).isActive = true
        explanationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        explanationLabel.widthAnchor.constraint(equalTo: view.widthAnchor,multiplier: 0.7).isActive = true
        
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.bottomAnchor.constraint(equalTo: pageStatus1.topAnchor, constant: -10).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        pageStatus1.translatesAutoresizingMaskIntoConstraints = false
        pageStatus1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -5).isActive = true
        pageStatus1.heightAnchor.constraint(equalToConstant: 10).isActive = true
        pageStatus1.widthAnchor.constraint(equalTo: pageStatus1.heightAnchor).isActive = true
        pageStatus1.rightAnchor.constraint(equalTo: view.centerXAnchor,constant: -5).isActive = true
        
        pageStatus2.translatesAutoresizingMaskIntoConstraints = false
        pageStatus2.centerYAnchor.constraint(equalTo: pageStatus1.centerYAnchor).isActive = true
        pageStatus2.widthAnchor.constraint(equalTo: pageStatus1.widthAnchor).isActive = true
        pageStatus2.heightAnchor.constraint(equalTo: pageStatus1.heightAnchor).isActive = true
        pageStatus2.leftAnchor.constraint(equalTo: view.centerXAnchor,constant: 5).isActive = true
        
        pageStatus1.layer.cornerRadius = 5
        pageStatus2.layer.cornerRadius = 5
    }
    

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        didTapLoginButton()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let ACCEPTABLE_CHARACTERS = "0123456789-() "
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
    }
}


