//
//  MyEventsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/22/21.
//

import UIKit
import MapKit
import CoreLocation


class MyEventsViewController: MasterTableViewController {
    init() {
        let hostingEvents = Event.getTodayUpcomingPrevious(events: User.getUDEvents(toKey: .hostedEvents))
        let goingEvents = Event.getTodayUpcomingPrevious(events: User.getUDEvents(toKey: .goingEvents))
        let savedEvents = Event.getTodayUpcomingPrevious(events: User.getUDEvents(toKey: .savedEvents))
        
        print("MY PAST EVENTS = ")
        print(User.getUDEvents(toKey: .pastHostEvents))
        
        let goingData = [
            CellSectionData(title: "Today", items: goingEvents.0, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Upcoming", items: goingEvents.1, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Previous", items: User.getUDEvents(toKey: .pastGoingEvents), cellType: CellType(eventType: .save))
        ]

        let savedData = [
            CellSectionData(title: "Today", items: savedEvents.0, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Upcoming", items: savedEvents.1, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Previous", items: savedEvents.2, cellType: CellType(eventType: .save))
        ]
        
        let hostingData = [
            CellSectionData(title: "Today", items: hostingEvents.0, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Upcoming", items: hostingEvents.1, cellType: CellType(eventType: .save)),
            CellSectionData(title: "Previous", items: User.getUDEvents(toKey: .pastHostEvents), cellType: CellType(eventType: .save))
        ]
        
        let tableData : [MultiSectionData] = [
            MultiSectionData(title: "Going", sections: goingData),
            MultiSectionData(title: "Saved", sections: savedData),
            MultiSectionData(title: "Hosting", sections: hostingData)
        ]

        super.init(multiSectionData: tableData)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = super.tableView(tableView, cellForRowAt: indexPath) as? EventFinderTableViewCell {
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let goingEvents = multiSectionData[0].sections[0].items.map({ $0.getItem() as! Event})
                        + multiSectionData[0].sections[1].items.map({ $0.getItem() as! Event})
        let pastGoingEvents = multiSectionData[0].sections[2].items.map({ $0.getItem() as! Event})
        
        let savedEvents = multiSectionData[0].sections[0].items.map({ $0.getItem() as! Event})
                        + multiSectionData[1].sections[1].items.map({ $0.getItem() as! Event})
                        + multiSectionData[2].sections[2].items.map({ $0.getItem() as! Event})
        
        let hostEvents = multiSectionData[2].sections[0].items.map({ $0.getItem() as! Event})
                       + multiSectionData[2].sections[1].items.map({ $0.getItem() as! Event})
        
        let pastHostEvents = multiSectionData[2].sections[2].items.map({ $0.getItem() as! Event})
        
        User.setUDEvents(events: goingEvents, toKey: .goingEvents)
        User.setUDEvents(events: pastGoingEvents, toKey: .pastGoingEvents)
        User.setUDEvents(events: hostEvents, toKey: .hostedEvents)
        User.setUDEvents(events: pastHostEvents, toKey: .pastHostEvents)
        User.setUDEvents(events: savedEvents, toKey: .savedEvents)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MyEventsViewController : SaveEventCellProtocol {
    func saveEvent(event: Event) {
        let filtered = Event.getTodayUpcomingPrevious(events: [event])
        let controller = EventCellController(item: event, cellType: CellType(eventType: .save))
        if !filtered.0.isEmpty {
            self.multiSectionData[1].sections[0].items.append(controller)
        } else if !filtered.1.isEmpty {
            self.multiSectionData[1].sections[1].items.append(controller)
        } else {
            self.multiSectionData[1].sections[2].items.append(controller)
        }
    }
    
    func unsaveEvent(event: Event) {
        let filtered = Event.getTodayUpcomingPrevious(events: [event])
        if !filtered.0.isEmpty {
            if let idx = multiSectionData[1].sections[0].items.firstIndex(where: { $0.getItem() as! Event == event }) {
                multiSectionData[1].sections[0].items.remove(at: idx)
            }
        } else if !filtered.1.isEmpty {
            if let idx = multiSectionData[1].sections[1].items.firstIndex(where: { $0.getItem() as! Event == event }) {
                multiSectionData[1].sections[1].items.remove(at: idx)
            }
        } else {
            if let idx = multiSectionData[1].sections[2].items.firstIndex(where: { $0.getItem() as! Event == event }) {
                multiSectionData[1].sections[2].items.remove(at: idx)
            }
        }
    }
}
