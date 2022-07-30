//
//  DataBaseManagerTestCode.swift
//  zip_official
//
//  Created by user on 7/29/22.
//

import Foundation
import FirebaseDatabase
import MessageKit
import FirebaseAuth
import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension DatabaseManager {
    public func createSampleEventsMany(){
        var eventIdStart = 111
        var events: [Event] = []
        var invite = true
        for i in 0...50 {
            if((i % 2) == 0){
                invite = true
            }
            if(invite){
                events.append(Event(eventId: String(eventIdStart), title: "test", coordinates: CLLocation(latitude: 0, longitude: 0), hosts: [User(userId: "u6502222222")], description: "test", address: "fuck my butt", locationName: "fuck my ass", maxGuests: 69, usersGoing: [], usersInterested: [], usersInvite: [User(userId: "u6501111111")], startTime: Date(), endTime: Date()))
            } else {
                events.append(Event(eventId: String(eventIdStart), title: "test", coordinates: CLLocation(latitude: 0, longitude: 0), hosts: [User(userId: "u6502222222")], description: "test", address: "fuck my butt", locationName: "fuck my ass", maxGuests: 69, usersGoing: [], usersInterested: [], usersInvite: [], startTime: Date(), endTime: Date()))
            }
            eventIdStart += 1
            invite = false
            
        }
        for i in events {
            createEvent(event: i) { [weak self] fuck in
                guard let strongSelf = self else {
                    return
                }
                switch fuck{
                case .success(let f):
                    print("succcccccccceeeeeeeedddd")
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    
    public func testthequery(){
        getAllPrivateEventsForMap(completion: { [weak self] result in
            switch result {
            case .success(let events):
                print("sucess loading event: \(events)")

                for event in events {
                    print(event.eventId)
                }
                print("There are " + String(events.count) + " events you are invited too")
            case .failure(let error):
                print("Error loading events on map Error: \(error)")
            }
            print("done loading events")
        })
    }
    
    public func makeSampleEvent(){
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        let userLoc = CLLocation(latitude: loc[0], longitude: loc[1])
        let a = PublicEvent(eventId: "sample",
                            title: "sample",
                            coordinates: userLoc,
                            hosts: [User(userId: "test", firstName: "Gabe", lastName: "Denton")],
                            description: "fuck",
                            address: "shit",
                            locationName: "yianni's butthole",
                            maxGuests: 1,
                            usersGoing: [User(userId: "VirIsGay", firstName: "Vir", lastName: "ShitOnMyDick")],
                            usersInterested: [],
                            usersInvite: [User(userId: "VirIsGay", firstName: "Vir", lastName: "ShitOnMyDick")],
                            startTime: Date(),
                            endTime: Date(),
                            duration: TimeInterval(3))
        createEvent(event: a) { [weak self] fuck in
            guard let strongSelf = self else {
                return
            }
            switch fuck{
            case .success(let f):
                print("finished creating event sample")
                print("sample url: " + f)
                strongSelf.markGoing(event: a) { [weak self] failuresfuckingsuckass in
                    guard failuresfuckingsuckass == nil else {
                        print("return 1")
                        return
                    }
                    guard let strongSelf = self else {
                        print("return 2")
                        return
                    }
                    print("Yianni marked as going")
                    strongSelf.inviteUsers(event: a, users: [User(userId: "FUCK", firstName: "SHIT", lastName: "BITCH"), User(userId: "Cunt", firstName: "ASS", lastName: "HELL")]) { error in
                        guard error == nil else {
                            print("return 3")
                            return
                        }
                        print("finished inviting FUCK and CUNT")
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
        //        markInterested(event: a) { error in
        //            guard error != nil else {
        //                return
        //            }
        //        }
        
    }
    
    public func checkSampleEvent(){
        print("check Sample")
        let key = "sample"
        loadEvent(key: key) { result in
            switch result{
            case .success(let event):
                print("check sample event suc")
                event.out()
            case .failure(let error):
                print("check sample got fucked in the ass")
                print(error)
            }
        }
    }
    
    public func createSampleUsersMany(){
        var userIdStart = 00000001
        var users: [User] = []
        let image = UIImage(named: "gabe1")!
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        let userLoc = CLLocation(latitude: loc[0], longitude: loc[1])
        for i in 0...100 {
            users.append(User(userId: "u" + String(userIdStart), email: String(userIdStart) + "@gmail.com", username: "test", firstName: "butt", lastName: "hole " + String(i), birthday: Date(), location: userLoc, picNum: 1, pictures: [image], bio: "myass", school: "yianni", interests: [], previousEvents: [], goingEvents: []))
            userIdStart += 1
        }
        for i in users {
            createDatabaseUser(user: i, completion: { error in
                print("succccc")
            })
            }
    }

    public func testEventTableView(){
        var eventIdStart = 111
        var events: [Event] = []
        var temps: [Event] = []
        var finalize: [Event] = []
        var invite = true
        for i in 0...50 {
            if((i % 2) == 0){
                invite = true
            }
            if(invite){
                events.append(Event(eventId: String(eventIdStart), title: "test", coordinates: CLLocation(latitude: 0, longitude: 0), hosts: [User(userId: "u6502222222")], description: "test", address: "fuck my butt", locationName: "fuck my ass", maxGuests: 69, usersGoing: [], usersInterested: [], usersInvite: [User(userId: "u6501111111")], startTime: Date(), endTime: Date()))
            } else {
                events.append(Event(eventId: String(eventIdStart), title: "test", coordinates: CLLocation(latitude: 0, longitude: 0), hosts: [User(userId: "u6502222222")], description: "test", address: "fuck my butt", locationName: "fuck my ass", maxGuests: 69, usersGoing: [], usersInterested: [], usersInvite: [], startTime: Date(), endTime: Date()))
            }
            eventIdStart += 1
            invite = false
        }
        for i in events {
            temps.append(Event(eventId: i.eventId))
        }
        eventLoadTableView(events: temps, completion: { [weak self] result in
            switch result {
            case .success(let event):
                print(event.eventId + " found")
            case.failure(let error):
                print(error)
            }
        })
    }
    
    public func testUserTableView(){
        var userIdStart = 00000001
        var users: [User] = []
        let image = UIImage(named: "gabe1")!
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        let userLoc = CLLocation(latitude: loc[0], longitude: loc[1])
        users.append(User(userId: "u2158018458"))
        users.append(User(userId: "u2508575270"))
        users.append(User(userId: "u6501111111"))
        users.append(User(userId: "u6502222222"))
        users.append(User(userId: "u9789070602"))

        userLoadTableView(users: users, completion: { [weak self] result in
            switch result {
            case .success(let user):
                print(user.userId + " found")
            case.failure(let error):
                print(error)
            }
        })
    }
}
