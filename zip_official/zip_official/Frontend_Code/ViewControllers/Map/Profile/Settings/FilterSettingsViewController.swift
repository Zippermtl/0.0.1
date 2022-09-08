//
//  FiltersViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/10/22.
//

import UIKit
import MARKRangeSlider

class FilterSettingsViewController: UIViewController {
    private let distanceView: cellView
    private let ageView: cellView
    private let genderView: cellView
    
    private let ageSlider : MARKRangeSlider
    private let ageLabel: UILabel
    private let distanceSlider: ResizeSlider
    private let distanceLabel: UILabel
    
    private let menButton: UIButton
    private let womenButton: UIButton
    private let everyoneButton: UIButton
    private let buttonHolder: UIStackView

    
    init() {
        distanceView = cellView(title: "Distance", subtitle: "Find users within")
        ageView = cellView(title: "Age", subtitle: "Show users between")
        genderView = cellView(title: "Gender", subtitle: "Show me")
        
        ageSlider = MARKRangeSlider()
        ageLabel = UILabel.zipSubtitle2()
        distanceSlider = ResizeSlider()
        distanceLabel = UILabel.zipSubtitle2()
        
        menButton = UIButton()
        womenButton = UIButton()
        everyoneButton = UIButton()
        
        buttonHolder = UIStackView()
        
        super.init(nibName: nil, bundle: nil)
        title = "ZipFinder Preferences"
        view.backgroundColor = .zipGray
        let minAge = CGFloat(AppDelegate.userDefaults.value(forKey: "MinAgeFilter") as? Int ?? 18)
        let maxAge = CGFloat(AppDelegate.userDefaults.value(forKey: "MaxAgeFilter") as? Int ?? 60)
        
        ageLabel.text = Int(minAge).description + "-" + Int(maxAge).description
        ageLabel.textAlignment = .center
        ageLabel.backgroundColor = .zipLightGray
        
        ageSlider.setLeftValue(minAge, rightValue: maxAge)
        ageSlider.minimumDistance = 5
        ageSlider.addTarget(self, action: #selector(ageSliderChanged), for: .valueChanged)
        ageSlider.rangeImage = ageSlider.rangeImage.withTintColor(.zipBlue)
        
        
        let maxRangeFilter = AppDelegate.userDefaults.value(forKey: "MaxRangeFilter") as? Int ?? 100

        distanceSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        distanceSlider.minimumValue = 4
        distanceSlider.maximumValue = 100
        distanceSlider.trackHeight = 2
        distanceSlider.minimumTrackTintColor = .zipBlue
        distanceSlider.setValue(Float(convertBack(inDistance: maxRangeFilter)), animated: false)
        
        var unit = "km"
        if NSLocale.current.regionCode == "US" {
            unit = "miles"
        }
        distanceLabel.text = maxRangeFilter.description + " " + unit
        distanceLabel.backgroundColor = .zipLightGray
        distanceLabel.textAlignment = .center
        
        menButton.setTitleColor(.white, for: .normal)
        menButton.setTitle("Men", for: .normal)
        menButton.titleLabel!.font = .zipSubtitle2
        menButton.layer.masksToBounds = true
        menButton.layer.cornerRadius = 8
        menButton.addTarget(self, action: #selector(didTapMen), for: .touchUpInside)
        
        womenButton.setTitleColor(.white, for: .normal)
        womenButton.setTitle("Women", for: .normal)
        womenButton.titleLabel!.font = .zipSubtitle2
        womenButton.layer.masksToBounds = true
        womenButton.layer.cornerRadius = 8
        womenButton.addTarget(self, action: #selector(didTapWomen), for: .touchUpInside)

        
        everyoneButton.setTitleColor(.white, for: .normal)
        everyoneButton.setTitle("Everyone", for: .normal)
        everyoneButton.titleLabel!.font = .zipSubtitle2
        everyoneButton.layer.masksToBounds = true
        everyoneButton.layer.cornerRadius = 8
        everyoneButton.addTarget(self, action: #selector(didTapEveryone), for: .touchUpInside)

        
        setGenderButtons()
        
        buttonHolder.axis = .horizontal
        buttonHolder.distribution = .equalSpacing
        buttonHolder.alignment = .center
        
        addSubviews()
        configureSubviewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapMen() {
        AppDelegate.userDefaults.set(0, forKey: "genderFilter")
        setGenderButtons()
    }
    
    @objc private func didTapWomen() {
        AppDelegate.userDefaults.set(1, forKey: "genderFilter")
        setGenderButtons()
    }
    
    @objc private func didTapEveryone() {
        AppDelegate.userDefaults.set(2, forKey: "genderFilter")
        setGenderButtons()
    }
    
    
    func convertDistance(inDistance: Int) -> Int {
        let d = Double(inDistance)
        return Int(0.007130 * d * d + 0.2870 * d)
    }
    
    func convertBack(inDistance: Int) -> Int {
        let d = Double(inDistance)
        return Int(round((-0.287 + sqrt(0.082368 + 0.02852 * d))/0.01426))
    }
    
    @objc func sliderChanged(_ sender: UISlider) {
        let convertedDistance = convertDistance(inDistance: Int(sender.value))
        var unit = "km"
        if NSLocale.current.regionCode == "US" {
            unit = "miles"
        }
        distanceLabel.text = convertedDistance.description + " " + unit
        AppDelegate.userDefaults.set(convertedDistance, forKey: "MaxRangeFilter")
    }
    
    @objc func ageSliderChanged(){
        AppDelegate.userDefaults.set(Int(ageSlider.leftValue), forKey: "MinAgeFilter")
        AppDelegate.userDefaults.set(Int(ageSlider.rightValue), forKey: "MaxAgeFilter")
        ageLabel.text = Int(ageSlider.leftValue).description + "-" + Int(ageSlider.rightValue).description
    }
    
    private func setGenderButtons(){
        let genderFilter = AppDelegate.userDefaults.value(forKey: "genderFilter") as? Int ?? 2
        if genderFilter == 0 {
            womenButton.backgroundColor = .zipLightGray
            everyoneButton.backgroundColor = .zipLightGray
            menButton.backgroundColor = .zipBlue
        } else if genderFilter == 1 {
            womenButton.backgroundColor = .zipBlue
            everyoneButton.backgroundColor = .zipLightGray
            menButton.backgroundColor = .zipLightGray
        } else {
            womenButton.backgroundColor = .zipLightGray
            everyoneButton.backgroundColor = .zipBlue
            menButton.backgroundColor = .zipLightGray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ageSlider.setMinValue(17, maxValue: 60)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        distanceLabel.layer.cornerRadius = distanceLabel.frame.height/2
        ageLabel.layer.cornerRadius = ageLabel.frame.height/2
    }
    
    private func addSubviews() {
       
        
        view.addSubview(distanceView)
        view.addSubview(distanceLabel)
        view.addSubview(distanceSlider)
        

        view.addSubview(ageView)
        view.addSubview(ageLabel)
        view.addSubview(ageSlider)

        view.addSubview(genderView)
        genderView.addSubview(buttonHolder)
        buttonHolder.addArrangedSubview(menButton)
        buttonHolder.addArrangedSubview(womenButton)
        buttonHolder.addArrangedSubview(everyoneButton)
    }
    
    
    
    private func configureSubviewLayout(){
        distanceView.translatesAutoresizingMaskIntoConstraints = false
        distanceView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        distanceView.bottomAnchor.constraint(equalTo: distanceSlider.bottomAnchor, constant: 10).isActive = true
        distanceView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        distanceView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.topAnchor.constraint(equalTo: distanceView.titleView.topAnchor).isActive = true
        distanceLabel.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -15).isActive = true
        distanceLabel.bottomAnchor.constraint(equalTo: distanceView.subtitleView.bottomAnchor).isActive = true
        
        if NSLocale.current.regionCode == "US" {
            distanceLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        } else {
            distanceLabel.widthAnchor.constraint(equalToConstant: 75).isActive = true

        }

        distanceLabel.layer.masksToBounds = true
       

        distanceSlider.translatesAutoresizingMaskIntoConstraints = false
        distanceSlider.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor,constant: 10).isActive = true
        distanceSlider.leftAnchor.constraint(equalTo: ageSlider.leftAnchor).isActive = true

//        distanceSlider.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 15).isActive = true
        distanceSlider.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -15).isActive = true
        
        ageView.translatesAutoresizingMaskIntoConstraints = false
        ageView.topAnchor.constraint(equalTo: distanceView.bottomAnchor).isActive = true
        ageView.bottomAnchor.constraint(equalTo: ageSlider.bottomAnchor,constant: 10).isActive = true
        ageView.rightAnchor.constraint(equalTo: distanceView.rightAnchor).isActive = true
        ageView.leftAnchor.constraint(equalTo: distanceView.leftAnchor).isActive = true
        
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.topAnchor.constraint(equalTo: ageView.titleView.topAnchor).isActive = true
        ageLabel.bottomAnchor.constraint(equalTo: ageView.subtitleView.bottomAnchor).isActive = true
        ageLabel.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -15).isActive = true
        ageLabel.widthAnchor.constraint(equalToConstant: 75).isActive = true

        ageLabel.layer.masksToBounds = true

        ageSlider.translatesAutoresizingMaskIntoConstraints = false
        ageSlider.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 10).isActive = true
        ageSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        ageSlider.leftAnchor.constraint(equalTo: ageView.subtitleView.leftAnchor).isActive = true

        genderView.translatesAutoresizingMaskIntoConstraints = false
        genderView.topAnchor.constraint(equalTo: ageView.bottomAnchor).isActive = true
        genderView.heightAnchor.constraint(equalTo: distanceView.heightAnchor).isActive = true
        genderView.rightAnchor.constraint(equalTo: distanceView.rightAnchor).isActive = true
        genderView.leftAnchor.constraint(equalTo: distanceView.leftAnchor).isActive = true

        buttonHolder.translatesAutoresizingMaskIntoConstraints = false
        buttonHolder.topAnchor.constraint(equalTo: genderView.subtitleView.bottomAnchor).isActive = true
        buttonHolder.bottomAnchor.constraint(equalTo: genderView.bottomAnchor).isActive = true
        buttonHolder.leftAnchor.constraint(equalTo: genderView.leftAnchor,constant: 25).isActive = true
        buttonHolder.rightAnchor.constraint(equalTo: genderView.rightAnchor,constant: -25).isActive = true
        
//        menButton.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        menButton.translatesAutoresizingMaskIntoConstraints = false
        menButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        menButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        womenButton.translatesAutoresizingMaskIntoConstraints = false
        womenButton.widthAnchor.constraint(equalTo: menButton.widthAnchor).isActive = true

        everyoneButton.translatesAutoresizingMaskIntoConstraints = false
        everyoneButton.widthAnchor.constraint(equalTo: menButton.widthAnchor).isActive = true
    }
    
    
    fileprivate class cellView: UIView{
        let titleView: UILabel
        let subtitleView: UILabel
        let sep: UIView
        init(title: String, subtitle: String){
            titleView = UILabel.zipSubtitle2()
            subtitleView = UILabel.zipTextNoti()
            sep = UIView()
            super.init(frame: .zero)
            titleView.text = title
            subtitleView.text = subtitle
            sep.backgroundColor = .zipSeparator
            
            addSubview(titleView)
            addSubview(subtitleView)
            addSubview(sep)

            
            titleView.translatesAutoresizingMaskIntoConstraints = false
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
            titleView.leftAnchor.constraint(equalTo: leftAnchor,constant: 15).isActive = true
            
            subtitleView.translatesAutoresizingMaskIntoConstraints = false
            subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor,constant: 5).isActive = true
            subtitleView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
            
            sep.translatesAutoresizingMaskIntoConstraints = false
            sep.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            sep.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            sep.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}
