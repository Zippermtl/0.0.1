//
//  InterestSelectionViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/3/21.
//

import UIKit


protocol UpdateInterestsProtocol: AnyObject {
    func updateInterests(_ interests: [Interests])
}

class InterestSelectionViewController: UIViewController {
    var interests: [Interests] = []
    var delegate: UpdateInterestsProtocol?
    var collectionView: UICollectionView

    init(interests: [Interests]){
        self.interests = interests
        let layout = LeftOrientedFlowLayout()
        layout.minimumLineSpacing = 5
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.register(InterestsCollectionViewCell.self, forCellWithReuseIdentifier: InterestsCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .zipGray
        view.addSubview(collectionView)
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    @objc private func didTapDoneButton(){
        delegate?.updateInterests(interests)
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        navigationItem.title = "Edit Interests"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapDoneButton))
        
    }
}


//MARK: - CollectionView Delegate
extension InterestSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: UIFont.zipBody]
        return CGSize(width: Interests.allCases[indexPath.row].description.size(withAttributes: fontAttributes).width+20,
                      height: 40)
        
    }
}

//MARK: - CollectionView DataSource
extension InterestSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Interests.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestsCollectionViewCell.identifier, for: indexPath) as! InterestsCollectionViewCell
        let cellInterest = Interests.allCases[indexPath.row]
        cell.configure(interest: cellInterest)
        if interests.contains(cellInterest) {
            cell.isSelected = true
            cell.select()
        }
        cell.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InterestsCollectionViewCell
        let idx = interests.firstIndex(of: Interests.init(rawValue: cell.tag)!)
        if  idx != nil{
            interests.remove(at: idx!)
            collectionView.reloadData()
            cell.isSelected = !cell.isSelected
            cell.select()


        } else if interests.count < 5 {
            interests.append(Interests.init(rawValue: cell.tag) ?? .acting)
            collectionView.reloadData()
            cell.isSelected = !cell.isSelected
            cell.select()

        }
        interests.sort(by: {$0.rawValue < $1.rawValue})
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    
}


extension InterestSelectionViewController {
    private class InterestsCollectionViewCell: UICollectionViewCell {
        static let identifier = "interestsCell"

        
        var bg: UIView
        var interestLabel: UILabel
        override init(frame: CGRect) {
            bg = UIView()
            interestLabel = UILabel.zipSubtitle()
            
            super.init(frame: frame)
            bg.layer.masksToBounds = true
            bg.backgroundColor = .zipLightGray
            bg.layer.masksToBounds = true
            bg.layer.cornerRadius = 20
            contentView.backgroundColor = .clear
            
            interestLabel.textAlignment = .center
            
            addSubviews()
            configureSubviewLayout()
        }
        
        required init?(coder: NSCoder) {
            bg = UIView()
            interestLabel = UILabel.zipTextFill()
            
            super.init(coder: coder)
        }
        
        
        public func configure(interest: Interests){
            interestLabel.text = interest.description
            switch isSelected{
            case true: bg.backgroundColor = .zipBlue
            case false: bg.backgroundColor = .zipLightGray
            }
        }
        
        private func addSubviews(){
            contentView.addSubview(bg)
            bg.addSubview(interestLabel)

        }
        
        private func configureSubviewLayout(){
            bg.translatesAutoresizingMaskIntoConstraints = false
            bg.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            bg.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            bg.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            
            interestLabel.translatesAutoresizingMaskIntoConstraints = false
            interestLabel.rightAnchor.constraint(equalTo: bg.rightAnchor).isActive = true
            interestLabel.leftAnchor.constraint(equalTo: bg.leftAnchor).isActive = true
            interestLabel.centerYAnchor.constraint(equalTo: bg.centerYAnchor).isActive = true
        }
        
        public func select(){
            switch isSelected{
            case true: bg.backgroundColor = .zipBlue
            case false: bg.backgroundColor = .zipLightGray
            }
        }
        
        
    }
}

class CenterOrientedFlowLayout : UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var rows = [CollectionViewRow]()
        var currentRowY: CGFloat = -1
        
        for attribute in attributes {
            if currentRowY != attribute.frame.origin.y {
                currentRowY = attribute.frame.origin.y
                rows.append(CollectionViewRow(spacing: 10))
            }
            rows.last?.add(attribute: attribute)
        }
        rows.forEach { $0.centerLayout(collectionViewWidth: collectionView?.frame.width ?? 0) }
        return rows.flatMap { $0.attributes }
    }
    
    private class CollectionViewRow {
        var attributes = [UICollectionViewLayoutAttributes]()
        var spacing: CGFloat = 0

        init(spacing: CGFloat) {
            self.spacing = spacing
        }

        func add(attribute: UICollectionViewLayoutAttributes) {
            attributes.append(attribute)
        }
        
        var rowWidth: CGFloat {
            return attributes.reduce(0, { result, attribute -> CGFloat in
                return result + attribute.frame.width
            }) + CGFloat(attributes.count - 1) * spacing
        }
        
        func centerLayout(collectionViewWidth: CGFloat) {
            let padding = (collectionViewWidth - rowWidth) / 2
            var offset = padding
            for attribute in attributes {
                attribute.frame.origin.x = offset
                offset += attribute.frame.width + spacing
            }
        }
    }
}



class LeftOrientedFlowLayout : UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else {
                return
            }
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}


enum Interests: Int, CaseIterable, CustomStringConvertible, Codable {
    case acting
    case activism
    case art
    case astrology
    case athlete
    case blm
    case baking
    case basketball
    case bingeWatching
    case blogging
    case boardGames
    case brunch
    case cannabis
    case cars
    case catLover
    case chess
    case climateChange
    case climbing
    case coding
    case coffee
    case collecting
    case comedy
    case cooking
    case craftBeer
    case crossfit
    case cycling
    case diy
    case djing
    case dancing
    case dogLover
    case environmentalism
    case fashion
    case feminism
    case festivals
    case fishing
    case foodie
    case football
    case gardening
    case givingAdvice
    case golf
    case grabADrink
    case graphicDesign
    case greekLife
    case gymnastics
    case hiking
    case history
    case hockey
    case iceSkating
    case karaoke
    case lgbtq
    case lgbtqRights
    case language
    case learning
    case makeup
    case makingMusic
    case mathematics
    case mentalHealthAwareness
    case military
    case mixology
    case movies
    case museum
    case music
    case outdoors
    case partying
    case photography
    case picnicking
    case poetry
    case politics
    case puzzles
    case rapping
    case reading
    case roadTrips
    case running
    case science
    case shopping
    case singing
    case skiing
    case sleeping
    case snowboarding
    case soccer
    case spirituality
    case sports
    case surfing
    case swimming
    case tattoos
    case tea
    case thrifting
    case travel
    case trivia
    case vegan
    case vegetarian
    case videoGames
    case vlogging
    case volunteering
    case voterRights
    case walking
    case wine
    case workingOut
    case writing
    case yoga
    
    var description: String {
        switch self {
        case .acting: return "Acting"
        case .activism: return "Activism"
        case .art: return "Art"
        case .astrology: return "Astrology"
        case .athlete: return "Athlete"
        case .blm: return "BLM"
        case .baking: return "Baking"
        case .basketball: return "Basketball"
        case .bingeWatching: return "Binge-watching"
        case .blogging: return "Blogging"
        case .boardGames: return "Board Games"
        case .brunch: return "Brunch"
        case .cannabis: return "Cannabis"
        case .cars: return "Cars"
        case .catLover: return "Cat Lover"
        case .chess: return "Chess"
        case .climateChange: return "Climate Change"
        case .climbing: return "Climbing"
        case .coding: return "Coding"
        case .coffee: return "Coffee"
        case .collecting: return "Collecting"
        case .comedy: return "Comedy"
        case .cooking: return "Cooking"
        case .craftBeer: return "Craft Beer"
        case .crossfit: return "Crossfit"
        case .cycling: return "Cycling"
        case .diy: return "DIY"
        case .djing: return "DJing"
        case .dancing: return "Dancing"
        case .dogLover: return "Dog Lover"
        case .environmentalism: return "Environmentalism"
        case .fashion: return "Fashion"
        case .feminism: return "Feminism"
        case .festivals: return "Festivals"
        case .fishing: return "Fishing"
        case .foodie: return "Foodie"
        case .football: return "Football"
        case .gardening: return "Gardening"
        case .givingAdvice: return "Giving Advice"
        case .golf: return "Golf"
        case .grabADrink: return "Grab A Drink"
        case .graphicDesign: return "Graphic Design"
        case .greekLife: return "Greek Life"
        case .gymnastics: return "Gymnastics"
        case .hiking: return "Hiking"
        case .history: return "History"
        case .hockey: return "Hockey"
        case .iceSkating: return "Ice Skating"
        case .karaoke: return "Karaoke"
        case .lgbtq: return "LGBTQ+"
        case .lgbtqRights: return "LGBTQ+ Rights"
        case .language: return "Language"
        case .learning: return "Learning"
        case .makeup: return "Makeup"
        case .makingMusic: return "Making Music"
        case .mathematics: return "Mathematics"
        case .mentalHealthAwareness: return "Mental Health Awareness"
        case .military: return "Military"
        case .mixology: return "Mixology"
        case .movies: return "Movies"
        case .museum: return "Museum"
        case .music: return "Music"
        case .outdoors: return "Outdoors"
        case .partying: return "Partying"
        case .photography: return "Photography"
        case .picnicking: return "Picnicking"
        case .poetry: return "Poetry"
        case .politics: return "Politics"
        case .puzzles: return "Puzzles"
        case .rapping: return "Rapping"
        case .reading: return "Reading"
        case .roadTrips: return "Road Trips"
        case .running: return "Running"
        case .science: return "Science"
        case .shopping: return "Shopping"
        case .singing: return "Singing"
        case .skiing: return "Skiing"
        case .sleeping: return "Sleeping"
        case .snowboarding: return "Snowboarding"
        case .soccer: return "Soccer"
        case .spirituality: return "Spirituality"
        case .sports: return "Sports"
        case .surfing: return "Surfing"
        case .swimming: return "Swimming"
        case .tattoos: return "Tattoos"
        case .tea: return "Tea"
        case .thrifting: return "Thrifting"
        case .travel: return "Travel"
        case .trivia: return "Trivia"
        case .vegan: return "Vegan"
        case .vegetarian: return "Vegetarian"
        case .videoGames: return "Video Games"
        case .vlogging: return "Vlogging"
        case .volunteering: return "Volunteering"
        case .voterRights: return "Voter Rights"
        case .walking: return "Walking"
        case .wine: return "Wine"
        case .workingOut: return "Working Out"
        case .writing: return "Writing"
        case .yoga: return "Yoga"
        }
    }
    
    enum CodingKeys: CodingKey {
        case acting
        case activism
        case art
        case astrology
        case athlete
        case blm
        case baking
        case basketball
        case bingeWatching
        case blogging
        case boardGames
        case brunch
        case cannabis
        case cars
        case catLover
        case chess
        case climateChange
        case climbing
        case coding
        case coffee
        case collecting
        case comedy
        case cooking
        case craftBeer
        case crossfit
        case cycling
        case diy
        case djing
        case dancing
        case dogLover
        case environmentalism
        case fashion
        case feminism
        case festivals
        case fishing
        case foodie
        case football
        case gardening
        case givingAdvice
        case golf
        case grabADrink
        case graphicDesign
        case greekLife
        case gymnastics
        case hiking
        case history
        case hockey
        case iceSkating
        case karaoke
        case lgbtq
        case lgbtqRights
        case language
        case learning
        case makeup
        case makingMusic
        case mathematics
        case mentalHealthAwareness
        case military
        case mixology
        case movies
        case museum
        case music
        case outdoors
        case partying
        case photography
        case picnicking
        case poetry
        case politics
        case puzzles
        case rapping
        case reading
        case roadTrips
        case running
        case science
        case shopping
        case singing
        case skiing
        case sleeping
        case snowboarding
        case soccer
        case spirituality
        case sports
        case surfing
        case swimming
        case tattoos
        case tea
        case thrifting
        case travel
        case trivia
        case vegan
        case vegetarian
        case videoGames
        case vlogging
        case volunteering
        case voterRights
        case walking
        case wine
        case workingOut
        case writing
        case yoga
    }
}
