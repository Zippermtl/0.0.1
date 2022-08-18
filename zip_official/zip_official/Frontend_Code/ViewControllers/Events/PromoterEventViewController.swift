//
//  PromoterEventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/17/22.
//

import UIKit

class PromoterEventViewController: EventViewController {
    var priceCell: UITableViewCell?
    var linkCell: UITableViewCell?

    init(event: PromoterEvent) {
        super.init(event: event)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func configureCells() {
        super.configureCells()
        guard let pEvent = event as? PromoterEvent,
              let price = pEvent.price,
              let link = pEvent.buyTicketsLink else {
            return
        }
        
        priceCell = UITableViewCell()
        priceCell?.backgroundColor = .zipGray
        priceCell?.selectionStyle = .none
        var priceContent = locationCell!.defaultContentConfiguration()
        priceContent.textProperties.color = .white
        priceContent.textProperties.font = .zipTextFill
        priceContent.image = UIImage(systemName: "dollarsign.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        priceContent.text = "\(price)"
        priceCell?.contentConfiguration = priceContent
        tableCells.append(locationCell!)
        
        linkCell = UITableViewCell()
        linkCell?.backgroundColor = .zipGray
        linkCell?.selectionStyle = .none
        var linkContent = locationCell!.defaultContentConfiguration()
        linkContent.textProperties.color = .white
        linkContent.textProperties.font = .zipTextFill
        linkContent.image = UIImage(systemName: "dollarsign.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        linkContent.text = link
        linkCell?.contentConfiguration = priceContent
        tableCells.append(locationCell!)        
    }

}
