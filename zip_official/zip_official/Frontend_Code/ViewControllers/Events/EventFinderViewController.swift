//
//  EventsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/21.
//



//https://stackoverflow.com/questions/35662840/how-to-add-circular-mask-on-camera-in-swift

//https://stackoverflow.com/questions/31283523/display-uisearchcontrollers-searchbar-programmatically

import UIKit
import MapKit
import CoreLocation

class EventFinderViewController: MasterTableViewController {
    var PromoterMultiSection : MultiSectionData
    var OpenMultiSection : MultiSectionData
    var ClosedMultiSection : MultiSectionData
    
    var PTSection : CellSectionData
    var PUSection : CellSectionData
    var OTSection : CellSectionData
    var OUSection : CellSectionData
    var CTSection : CellSectionData
    var CUSection : CellSectionData
    
    var addedEvents : [String : Bool] = [:]
    
    init() {
        PTSection = CellSectionData(title: "Today", items: [], cellType: .rsvp)
        PUSection = CellSectionData(title: "Upcoming", items: [], cellType: .rsvp)
        
        OTSection = CellSectionData(title: "Today", items: [], cellType: .rsvp)
        OUSection = CellSectionData(title: "Upcoming", items: [], cellType: .rsvp)
        
        CTSection = CellSectionData(title: "Today", items: [], cellType: .rsvp)
        CUSection = CellSectionData(title: "Upcoming", items: [], cellType: .rsvp)
        
        PromoterMultiSection = MultiSectionData(title: "Promoter", sections: [PTSection,PUSection])
        OpenMultiSection = MultiSectionData(title: "Open", sections: [OTSection,OUSection])
        ClosedMultiSection = MultiSectionData(title: "Closed", sections: [CTSection,CUSection])

        super.init(multiSectionData: [PromoterMultiSection, OpenMultiSection, ClosedMultiSection])
        title = "Find Events"
        findAllEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func findAllEvents() {
        DatabaseManager.shared.getAllPrivateEventsForMap(eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            strongSelf.addEvent(event: event)
            print("FIRING SINGLE PRIVATE")

        }, allCompletion: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
            print("FIRING ALL PRIVATE")
        })
        
        DatabaseManager.shared.getAllPublic(eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            strongSelf.addEvent(event: event)
        }, allCompletion: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
            
        })
        
        DatabaseManager.shared.getAllPromoter(eventCompletion: { [weak self] event in
            guard let strongSelf = self else { return }
            strongSelf.addEvent(event: event)
        }, allCompletion: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()

        })
    }
    
    private func addEvent(event: Event) {
        if addedEvents[event.eventId] == nil {
            addedEvents[event.eventId] = true
            switch event.getType() {
            case .Open :
                if Calendar.current.isDateInToday(event.startTime) {
                    OTSection.items.append(EventCellController(item: event, cellType: CellType(eventType: .rsvp)))
                } else {
                    OUSection.items.append(EventCellController(item: event, cellType: CellType(eventType: .rsvp)))
                }
            case .Closed :
                if Calendar.current.isDateInToday(event.startTime) {
                    CTSection.items.append(EventCellController(item: event, cellType: CellType(eventType: .rsvp)))
                } else {
                    CUSection.items.append(EventCellController(item: event, cellType: CellType(eventType: .rsvp)))
                }
            
            case .Promoter :
                if Calendar.current.isDateInToday(event.startTime) {
                    PTSection.items.append(EventCellController(item: event, cellType: CellType(eventType: .rsvp)))
                } else {
                    PUSection.items.append(EventCellController(item: event, cellType: CellType(eventType: .rsvp)))
                }
            default: break
            }
            
            
        }
    }
    
}


class BackBarButtonItem: UIBarButtonItem {
  @available(iOS 14.0, *)
  override var menu: UIMenu? {
    set {
      /* Don't set the menu here */
      /* super.menu = menu */
    }
    get {
      return super.menu
    }
  }
}
