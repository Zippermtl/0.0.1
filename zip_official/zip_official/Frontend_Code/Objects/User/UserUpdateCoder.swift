//
//  UserUpdateCoder.swift
//  zip_official
//
//  Created by user on 10/28/22.
//

import Foundation
import MapKit
import FirebaseFirestore

class UserUpdateCoder: Codable {
    var bio: String
    var interests: [Interests]
    var school: String?
    var gender: String
    
    init(user: User) {
        self.bio = user.bio
        self.interests = user.interests
        self.school = user.school
        self.gender = user.gender
    }
    
    enum CodingKeys: String, CodingKey {
        case school = "school"
        case interests = "interests"
        case gender = "gender"
        case bio = "bio"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.interests = try container.decode([Interests].self, forKey: .interests)
        self.school = try? container.decode(String.self, forKey: .school)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bio, forKey: .bio)
        try container.encode(gender, forKey: .gender)
        try? container.encode(school, forKey: .school)
        try container.encode(interests, forKey: .interests)
    }
    
    
    public func createUser() -> User{
        return User(
            gender: gender,
            bio: bio,
            school: school,
            interests: interests
        )
    }
    
    public func updateUser(_ user: User) {
        user.bio = bio
        user.school = school
        user.interests = interests
        user.gender = gender
    }
}
