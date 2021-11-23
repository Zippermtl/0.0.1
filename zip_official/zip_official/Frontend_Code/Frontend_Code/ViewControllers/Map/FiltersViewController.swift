//
//  FiltersViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/23/21.
//

import UIKit
import MARKRangeSlider

protocol FilterVCDelegate: AnyObject {
    func updateRings()
    func showFilterButton()
}

class FiltersViewController: UIViewController {
    weak var delegate: FilterVCDelegate?

    let outlineView = UIView()
    
    let titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(24)
        label.text = "FILTERS"
        return label
    }()
    
    let ageLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(18)
        label.text = "AGE"
        return label
    }()
    
    let genderLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(18)
        label.text = "SHOW ME:"
        return label
    }()
    
    let collegeLabel: UILabel = {
        var label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipTitle.withSize(18)
        label.text = "MY SCHOOL ONLY"
        return label
    }()
    
    let blueRingLabel: UILabel = {
        var label = UILabel()
        label.textColor = .zipBlue
        label.font = .zipTitle.withSize(18)
        label.text = "BLUE RING"
        return label
    }()
    
    let greenRingLabel: UILabel = {
        var label = UILabel()
        label.textColor = .zipGreen
        label.font = .zipTitle.withSize(18)
        label.text = "GREEN RING"
        return label
    }()
    
    let pinkRingLabel: UILabel = {
        var label = UILabel()
        label.textColor = .zipPink
        label.font = .zipTitle.withSize(18)
        label.text = "PINK RING"
        return label
    }()
    
    //MARK: Sliders
    let ageSlider = MARKRangeSlider()
    let blueSlider = UISlider()
    let greenSlider = UISlider()
    let pinkSlider = ResizeSlider()
    
    //MARK: Gender Buttons
    let menButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("MEN", for: .normal)
        btn.titleLabel?.font = .zipBody.withSize(16)
        btn.backgroundColor = .zipLightGray
        btn.addTarget(self, action: #selector(didTapMen), for: .touchUpInside)
        return btn
    }()
    
    let womenButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("WOMEN", for: .normal)
        btn.titleLabel?.font = .zipBody.withSize(16)
        btn.backgroundColor = .zipLightGray
        btn.addTarget(self, action: #selector(didTapWomen), for: .touchUpInside)

        return btn
    }()
    
    let everyoneButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("EVERYONE", for: .normal)
        btn.titleLabel?.font = .zipBody.withSize(16)
        btn.backgroundColor = .zipLightGray
        btn.addTarget(self, action: #selector(didTapEveryone), for: .touchUpInside)
        return btn
    }()
    
    let xButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "grayXButton")?.withTintColor(.zipVeryLightGray), for: .normal)
        btn.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return btn
    }()
    
    let doneButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Done", for: .normal)
        btn.setTitleColor(.zipBlue, for: .normal)
        btn.titleLabel?.font = .zipBody
        btn.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return btn
    }()
    
    let resetButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Reset", for: .normal)
        btn.setTitleColor(.zipBlue, for: .normal)
        btn.titleLabel?.font = .zipBody
        btn.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        return btn
    }()
    
    let collegeSwitch: UISwitch = {
        let flipSwitch = UISwitch()
        flipSwitch.isEnabled = false
        return flipSwitch
    }()
    
    let lockIcon: UIImageView = {
        let imgView = UIImageView()
        let config = UIImage.SymbolConfiguration(weight: .bold)
        imgView.image = UIImage(systemName: "lock", withConfiguration: config)
        imgView.tintColor = .zipVeryLightGray
        return imgView
    }()
    
    @objc private func didTapDoneButton() {
        let blueRingValue = Double(pinkSlider.value)/5
        if blueRingValue < 5 {
            AppDelegate.userDefaults.setValue(round(blueRingValue), forKey: "BlueRing")
        } else {
            AppDelegate.userDefaults.setValue(round(blueRingValue*0.2)/0.2, forKey: "BlueRing")
        }
        AppDelegate.userDefaults.setValue((round((Double(pinkSlider.value)/2)*0.2)/0.2), forKey: "GreenRing")
        AppDelegate.userDefaults.setValue((round((Double(pinkSlider.value))*0.2)/0.2), forKey: "PinkRing")
        
        AppDelegate.userDefaults.setValue(ageSlider.leftValue, forKey: "MinAgeFilter")
        AppDelegate.userDefaults.setValue(ageSlider.rightValue, forKey: "MaxAgeFilter")

        AppDelegate.userDefaults.setValue(genderFilter, forKey: "GenderFilter")


        delegate?.updateRings()
        delegate?.showFilterButton()

        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCloseButton() {
        delegate?.showFilterButton()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapResetButton() {
        pinkSlider.setValue(AppDelegate.userDefaults.float(forKey: "PinkRing"), animated: false)
        
        print("genderFilter = \(AppDelegate.userDefaults.integer(forKey: "GenderFilter"))")
        switch AppDelegate.userDefaults.integer(forKey: "GenderFilter") {
        case 0:
            menButton.backgroundColor = .zipVeryLightGray
            womenButton.backgroundColor = .zipLightGray
            everyoneButton.backgroundColor = .zipLightGray

        case 1:
            menButton.backgroundColor = .zipLightGray
            womenButton.backgroundColor = .zipVeryLightGray
            everyoneButton.backgroundColor = .zipLightGray
        default:
            menButton.backgroundColor = .zipLightGray
            womenButton.backgroundColor = .zipLightGray
            everyoneButton.backgroundColor = .zipVeryLightGray
            
        }
        
        genderFilter = AppDelegate.userDefaults.integer(forKey: "GenderFilter")
        
        ageSlider.setLeftValue(CGFloat(AppDelegate.userDefaults.float(forKey: "MinAgeFilter")),
                               rightValue: CGFloat(AppDelegate.userDefaults.float(forKey: "MaxAgeFilter")))
        
        ageLabel.text = "AGE: " + Int(ageSlider.leftValue).description + " to " + Int(ageSlider.rightValue).description
        
        sliderChanged(pinkSlider)
    }
    
    @objc func sliderChanged(_ sender: UISlider){
        let blueRingValue = Double(sender.value)/5/1000
        if blueRingValue < 5 {
            blueRingLabel.text = "BLUE RING: " + round(blueRingValue).description + " km"
        } else {
            blueRingLabel.text = "BLUE RING: " + (round(blueRingValue*0.2)/0.2).description + " km"
        }
        greenRingLabel.text = "GREEN RING: " + (round((Double(sender.value)/2/1000)*0.2)/0.2).description + " km"
        pinkRingLabel.text = "PINK RING: " + (round((Double(sender.value)/1000)*0.2)/0.2).description + " km"
    }
    
    @objc func ageSliderChanged(){
        ageLabel.text = "AGE: " + Int(ageSlider.leftValue).description + " to " + Int(ageSlider.rightValue).description
    }
    
    var genderFilter = 0
    
    @objc func didTapMen(){
        menButton.backgroundColor = .zipVeryLightGray
        womenButton.backgroundColor = .zipLightGray
        everyoneButton.backgroundColor = .zipLightGray
        genderFilter = 0
    }
    
    @objc func didTapWomen(){
        menButton.backgroundColor = .zipLightGray
        womenButton.backgroundColor = .zipVeryLightGray
        everyoneButton.backgroundColor = .zipLightGray
        genderFilter = 1

    }
    
    @objc func didTapEveryone(){
        menButton.backgroundColor = .zipLightGray
        womenButton.backgroundColor = .zipLightGray
        everyoneButton.backgroundColor = .zipVeryLightGray
        genderFilter = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        outlineView.backgroundColor = .zipGray
        configLabels()
        configureSliders()
        addSubviews()
        configureSubviewConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        outlineView.layer.cornerRadius = 15
        menButton.layer.cornerRadius = 10
        womenButton.layer.cornerRadius = 10
        everyoneButton.layer.cornerRadius = 10

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //no idea why this works here and not view did load
        pinkSlider.setValue(AppDelegate.userDefaults.float(forKey: "PinkRing"), animated: false)
        
        switch AppDelegate.userDefaults.integer(forKey: "GenderFilter") {
        case 0: menButton.backgroundColor = .zipVeryLightGray
        case 1: womenButton.backgroundColor = .zipVeryLightGray
        default: everyoneButton.backgroundColor = .zipVeryLightGray
        }
        
        ageSlider.setLeftValue(CGFloat(AppDelegate.userDefaults.float(forKey: "MinAgeFilter")),
                               rightValue: CGFloat(AppDelegate.userDefaults.float(forKey: "MaxAgeFilter")))

    }

    private func configLabels(){
        ageLabel.text = "AGE: " +
                        AppDelegate.userDefaults.integer(forKey: "MinAgeFilter").description +
                        " to " +
                        AppDelegate.userDefaults.integer(forKey: "MaxAgeFilter").description
        
        
        let blueRingValue = Double(AppDelegate.userDefaults.integer(forKey: "BlueRing"))/1000
        if blueRingValue < 5 {
            blueRingLabel.text = "BLUE RING: " + round(blueRingValue).description + " km"
        } else {
            blueRingLabel.text = "BLUE RING: " + (round(blueRingValue*0.2)/0.2).description + " km"
        }
        greenRingLabel.text = "GREEN RING: " + (round((Double(AppDelegate.userDefaults.integer(forKey: "GreenRing"))/1000)*0.2)/0.2).description + " km"
        pinkRingLabel.text = "PINK RING: " + (round((Double(AppDelegate.userDefaults.integer(forKey: "PinkRing"))/1000)*0.2)/0.2).description + " km"
    }
    
    
    private func configureSliders() {
//        blueSlider.minimumValue = 500
//        blueSlider.maximumValue = 4000
//        greenSlider.minimumValue = 4500
//        greenSlider.maximumValue = 8500
        
//        pinkSlider.setValue(Float(AppDelegate.userDefaults.integer(forKey: "PinkRing")), animated: false)
//        pinkSlider.value = Float(AppDelegate.userDefaults.integer(forKey: "PinkRing"))
        pinkSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        pinkSlider.minimumValue = 10000
        pinkSlider.maximumValue = 100000
        
        pinkSlider.trackHeight = 2
        
        pinkSlider.minimumTrackTintColor = .zipBlue
        
        
        ageSlider.setMinValue(17, maxValue: 60)
        ageSlider.minimumDistance = 5
        ageSlider.addTarget(self, action: #selector(ageSliderChanged), for: .valueChanged)
        ageSlider.rangeImage = ageSlider.rangeImage.withTintColor(.zipBlue)

        
//        ageSlider.backgroundColor = .red
//        let margin: CGFloat = 20
//        let width = view.bounds.width - 2 * margin
//        let height: CGFloat = 30
//
//        ageSlider.frame = CGRect(x: 0, y: 0,
//                                   width: width, height: height)
//        ageSlider.center = view.center
    }
    
    
    
    private func addSubviews(){
        view.addSubview(outlineView)
        outlineView.addSubview(titleLabel)
        outlineView.addSubview(ageLabel)
        outlineView.addSubview(genderLabel)
        outlineView.addSubview(blueRingLabel)
        outlineView.addSubview(greenRingLabel)
        outlineView.addSubview(pinkRingLabel)
        outlineView.addSubview(ageSlider)
        outlineView.addSubview(pinkSlider)
        outlineView.addSubview(xButton)
        outlineView.addSubview(doneButton)
        outlineView.addSubview(menButton)
        outlineView.addSubview(womenButton)
        outlineView.addSubview(collegeLabel)
        outlineView.addSubview(collegeSwitch)
        outlineView.addSubview(everyoneButton)
        outlineView.addSubview(resetButton)
        outlineView.addSubview(lockIcon)

    }
    
    private func configureSubviewConstraints(){
        outlineView.translatesAutoresizingMaskIntoConstraints = false
        outlineView.widthAnchor.constraint(equalToConstant: view.frame.width*0.75).isActive = true
        outlineView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        outlineView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        outlineView.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        outlineView.bottomAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 5).isActive = true
        
        xButton.translatesAutoresizingMaskIntoConstraints = false
        xButton.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        xButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        xButton.heightAnchor.constraint(equalToConstant: titleLabel.intrinsicContentSize.height).isActive = true
        xButton.widthAnchor.constraint(equalTo: xButton.heightAnchor).isActive = true
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true
        doneButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: titleLabel.intrinsicContentSize.height).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: outlineView.topAnchor,constant: 5).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: outlineView.centerXAnchor).isActive = true

        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        ageLabel.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        
        ageSlider.translatesAutoresizingMaskIntoConstraints = false
        ageSlider.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 5).isActive = true
        ageSlider.leftAnchor.constraint(equalTo: outlineView.leftAnchor,constant: 10).isActive = true
        ageSlider.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true
        ageSlider.heightAnchor.constraint(equalTo: pinkSlider.heightAnchor).isActive = true
        
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        genderLabel.centerYAnchor.constraint(equalTo: menButton.bottomAnchor, constant: 3).isActive = true
        genderLabel.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        genderLabel.widthAnchor.constraint(equalToConstant: genderLabel.intrinsicContentSize.width).isActive = true
        
        menButton.translatesAutoresizingMaskIntoConstraints = false
        menButton.topAnchor.constraint(equalTo: ageSlider.bottomAnchor, constant: 5).isActive = true
        menButton.heightAnchor.constraint(equalTo: genderLabel.heightAnchor).isActive = true
        menButton.leftAnchor.constraint(equalTo: genderLabel.rightAnchor, constant: 5).isActive = true
        menButton.widthAnchor.constraint(equalTo: womenButton.widthAnchor).isActive = true
        
        womenButton.translatesAutoresizingMaskIntoConstraints = false
        womenButton.centerYAnchor.constraint(equalTo: menButton.centerYAnchor).isActive = true
        womenButton.heightAnchor.constraint(equalTo: genderLabel.heightAnchor).isActive = true
        womenButton.leftAnchor.constraint(equalTo: menButton.rightAnchor, constant: 5).isActive = true
        womenButton.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -5).isActive = true

        everyoneButton.translatesAutoresizingMaskIntoConstraints = false
        everyoneButton.topAnchor.constraint(equalTo: menButton.bottomAnchor, constant: 6).isActive = true
        everyoneButton.heightAnchor.constraint(equalTo: genderLabel.heightAnchor).isActive = true
        everyoneButton.leftAnchor.constraint(equalTo: genderLabel.rightAnchor, constant: 5).isActive = true
        everyoneButton.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -5).isActive = true

        collegeLabel.translatesAutoresizingMaskIntoConstraints = false
        collegeLabel.centerYAnchor.constraint(equalTo: collegeSwitch.centerYAnchor).isActive = true
        collegeLabel.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true

        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        lockIcon.leftAnchor.constraint(equalTo: collegeLabel.rightAnchor, constant: 10).isActive = true
        lockIcon.centerYAnchor.constraint(equalTo: collegeLabel.centerYAnchor).isActive = true
        
        collegeSwitch.translatesAutoresizingMaskIntoConstraints = false
        collegeSwitch.topAnchor.constraint(equalTo: everyoneButton.bottomAnchor, constant: 5).isActive = true
        collegeSwitch.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true
        
        blueRingLabel.translatesAutoresizingMaskIntoConstraints = false
        blueRingLabel.topAnchor.constraint(equalTo: collegeLabel.bottomAnchor, constant: 5).isActive = true
        blueRingLabel.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true

//        blueSlider.translatesAutoresizingMaskIntoConstraints = false
//        blueSlider.topAnchor.constraint(equalTo: blueRingLabel.bottomAnchor).isActive = true
//        blueSlider.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
//        blueSlider.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true

        greenRingLabel.translatesAutoresizingMaskIntoConstraints = false
        greenRingLabel.topAnchor.constraint(equalTo: blueRingLabel.bottomAnchor).isActive = true
        greenRingLabel.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true

//        greenSlider.translatesAutoresizingMaskIntoConstraints = false
//        greenSlider.topAnchor.constraint(equalTo: greenRingLabel.bottomAnchor).isActive = true
//        greenSlider.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
//        greenSlider.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true
        
        pinkRingLabel.translatesAutoresizingMaskIntoConstraints = false
        pinkRingLabel.topAnchor.constraint(equalTo: greenRingLabel.bottomAnchor).isActive = true
        pinkRingLabel.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        
        pinkSlider.translatesAutoresizingMaskIntoConstraints = false
        pinkSlider.topAnchor.constraint(equalTo: pinkRingLabel.bottomAnchor).isActive = true
        pinkSlider.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        pinkSlider.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true
        
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.topAnchor.constraint(equalTo: pinkSlider.bottomAnchor).isActive = true
        resetButton.centerXAnchor.constraint(equalTo: outlineView.centerXAnchor).isActive = true


    }

    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


class ResizeSlider: UISlider {
  @IBInspectable var trackHeight: CGFloat = 2

  override func trackRect(forBounds bounds: CGRect) -> CGRect {
    return CGRect(origin: CGPoint(x: 0, y: bounds.midY), size: CGSize(width: bounds.width, height: trackHeight))
  }
}
