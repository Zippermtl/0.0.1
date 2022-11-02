//
//  LocalEventCoder.swift
//  zip_official
//
//  Created by user on 10/28/22.
//

import Foundation

//MARK: Local Event Coder
public class LocalEventCoder : EventCoder {
    var id: String?
    var imageUrl : String?
    var loadStatus: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case imageUrl = "imageUrl"
        case loadStatus = "loadStatus"
    }
    
    override init(event: Event) {
        self.id = event.eventId
        self.imageUrl = event.imageUrl?.absoluteString
        self.loadStatus = event.loadStatus.rawValue
        
        super.init(event: event)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.imageUrl = try? container.decode(String.self, forKey: .imageUrl)
        self.loadStatus = try? container.decode(Int.self, forKey: .loadStatus)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(imageUrl, forKey: .imageUrl)
        try? container.encode(loadStatus, forKey: .loadStatus)
        try super.encode(to: encoder)
    }
    
    override public func createEvent() -> Event {
        let event = super.createEvent()
        if let id = id {
            event.eventId = id
        }
        if let imageUrl = imageUrl {
            event.imageUrl = URL(string: imageUrl)
        }
        if let loadStatus = loadStatus {
            event.loadStatus = User.UserLoadType(rawValue: loadStatus)!
        }
        return event
    }

}
