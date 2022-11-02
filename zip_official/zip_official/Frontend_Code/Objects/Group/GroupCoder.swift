//
//  GroupCoder.swift
//  zip_official
//
//  Created by user on 10/28/22.
//

import Foundation
import MapKit
import FirebaseFirestore

public class GroupCoder: Codable {
    var users: [String]
    var id: String
    var adm: String
    var coverIndex: [Int]
    var pictures: [Int]
    var title: String
    var picNum : Int
    init(group: Group){
        self.users = group.users.map({$0.userId})
        self.id = group.id
        self.adm = group.adm
        self.coverIndex = group.coverIndex
        self.pictures = group.pictures
        self.title = group.title
        self.picNum = group.picNum
    }
    
    enum CodingKeys: String, CodingKey {
        case users = "users"
        case id = "id"
        case adm = "adm"
        case coverIndex = "coverIndex"
        case pictures = "pictures"
        case title = "title"
        case picNum = "picNum"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.users = try container.decode([String].self, forKey: .users)
        self.id = try container.decode(String.self, forKey: .id)
        self.adm = try container.decode(String.self, forKey: .adm)
        self.coverIndex = try container.decode([Int].self, forKey: .coverIndex)
        self.pictures = try container.decode([Int].self, forKey: .pictures)
        self.title = try container.decode(String.self, forKey: .title)
        self.picNum = try container.decode(Int.self, forKey: .picNum)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(users, forKey: .users)
        try container.encode(id, forKey: .id)
        try container.encode(adm, forKey: .adm)
        try container.encode(coverIndex, forKey: .coverIndex)
        try container.encode(pictures, forKey: .pictures)
        try container.encode(title, forKey: .title)
        try container.encode(picNum, forKey: .picNum)
    }
    
    public func createGroup() -> Group {
        return Group(userList: users.map( { User(userId: $0 )} ), groupId: id, admin: adm, coverPicIndex: coverIndex, pictureIndices: pictures, groupTitle: title)
    }
    
    public func updateGroup(group: Group) {
        group.users = users.map( { User(userId: $0 )} )
        group.id = id
        group.adm = adm
        group.coverIndex = coverIndex
        group.pictures = pictures
        group.title = title
//        group.picNum = picNum
    }
    
    public func validate(id: String) -> Bool {
        return users.contains(id)
    }
}
