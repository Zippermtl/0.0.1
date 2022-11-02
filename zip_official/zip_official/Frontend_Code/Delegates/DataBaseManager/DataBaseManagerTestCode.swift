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
                events.append(Event(eventId: String(eventIdStart), title: "test", coordinates: CLLocation(latitude: 0, longitude: 0), hosts: [User(userId: "u6502222222")], bio: "test", address: "fuck my butt", locationName: "fuck my ass", maxGuests: 69, usersGoing: [], usersInterested: [], usersInvite: [User(userId: "u6501111111")], startTime: Date(), endTime: Date()))
            } else {
                events.append(Event(eventId: String(eventIdStart), title: "test", coordinates: CLLocation(latitude: 0, longitude: 0), hosts: [User(userId: "u6502222222")], bio: "test", address: "fuck my butt", locationName: "fuck my ass", maxGuests: 69, usersGoing: [], usersInterested: [], usersInvite: [], startTime: Date(), endTime: Date()))
            }
            eventIdStart += 1
            invite = false
            
        }
        for i in events {
            createEvent(event: i) { result in
                switch result {
                case .success(_):
                    print("succcccccccceeeeeeeedddd")
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    
    public func testthequery(){
        getAllPrivateEventsForMap(eventCompletion: { event in
            
        }, allCompletion: { result in
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
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as? [Double] ?? [36.144051,-86.800949]
        let userLoc = CLLocation(latitude: loc[0], longitude: loc[1])
        let baseEvent = Event(eventId: "sample",
                              title: "sample",
                              coordinates: userLoc,
                              hosts: [User(userId: "test", firstName: "Gabe", lastName: "Denton")],
                              bio: "fuck",
                              address: "shit",
                              locationName: "yianni's butthole",
                              maxGuests: 1,
                              usersGoing: [User(userId: "VirIsGay", firstName: "Vir", lastName: "ShitOnMyDick")],
                              usersInterested: [],
                              usersInvite: [User(userId: "VirIsGay", firstName: "Vir", lastName: "ShitOnMyDick")],
                              startTime: Date(),
                              endTime: Date(),
                              duration: TimeInterval(3))
        let a = UserEvent(event: baseEvent, type: .Open)
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
        loadEvent(event: Event(eventId: key)) { result in
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
        let image = UIImage(named: "defaultProfilePic")!
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as? [Double] ?? [36.144051,-86.800949]
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
                events.append(Event(eventId: String(eventIdStart), title: "test", coordinates: CLLocation(latitude: 0, longitude: 0), hosts: [User(userId: "u6502222222")], bio: "test", address: "fuck my butt", locationName: "fuck my ass", maxGuests: 69, usersGoing: [], usersInterested: [], usersInvite: [User(userId: "u6501111111")], startTime: Date(), endTime: Date()))
            } else {
                events.append(Event(eventId: String(eventIdStart), title: "test", coordinates: CLLocation(latitude: 0, longitude: 0), hosts: [User(userId: "u6502222222")], bio: "test", address: "fuck my butt", locationName: "fuck my ass", maxGuests: 69, usersGoing: [], usersInterested: [], usersInvite: [], startTime: Date(), endTime: Date()))
            }
            eventIdStart += 1
            invite = false
        }
        for i in events {
            temps.append(Event(eventId: i.eventId))
        }
        for event in temps {
            eventLoadTableView(event: event, completion: { result in
                switch result {
                case .success(let event):
                    print(event.eventId + " found")
                case.failure(let error):
                    print(error)
                }
            })
        }
        
    }
    
    public func testUserTableView(){
        var userIdStart = 00000001
        var users: [User] = []
        let image = UIImage(named: "defaultProfilePic")!
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as? [Double] ?? [36.144051,-86.800949]
        let userLoc = CLLocation(latitude: loc[0], longitude: loc[1])
        users.append(User(userId: "u2158018458"))
        users.append(User(userId: "u2508575270"))
        users.append(User(userId: "u6501111111"))
        users.append(User(userId: "u6502222222"))
        users.append(User(userId: "u9789070602"))

        for user in users {
            userLoadTableView(user: user, completion: {result in
                switch result {
                case .success(let user):
                    print(user.userId + " found")
                case.failure(let error):
                    print(error)
                }
            })
        }
        
        
    }
    
    public func getCSVData(path: String){
        
        do {
            var parsedCSV = [[String]]()
            let content = try String(contentsOfFile: path)
            var separatedEvents = content.components( separatedBy: "\n" )
            separatedEvents.remove(at: 0)
            for eventString in separatedEvents {
                let separated = eventString.split(separator: ",", omittingEmptySubsequences: false).map({ String($0) })
                var eventArray = [String]()
                var isCombining = false
                var combinedString = ""
                for str in separated {
                    
                    if str.starts(with: "\"") {
                        isCombining = true
                    }
                    
                    if str.count > 0 && str.suffix(1) == "\"" {
                        isCombining = false
                        combinedString += str.dropLast()
                        eventArray.append(combinedString)
                        combinedString = ""
                        continue
                    }
                    
                    if isCombining {
                        if combinedString == "" {
                            combinedString += str.dropFirst()
                        } else {
                            combinedString += ","
                            combinedString += str
                        }
                        
                    } else {
                        eventArray.append(String(str))
                    }
                    
                    
                }
                parsedCSV.append(eventArray)
            }
            createEventFromCsvData(data: parsedCSV, completion: { err in
                if let _ = err {
                    print("error in getCsvData")
                }
            })
        }
        catch {
            print("failure with csv Parsing")
            return
        }
        
    }
    
//    Title,ID,Venue,Address,Latitude,Longitude,Category,Bio,Date,Start Time,End Time,Phone Number,Website
    public func createEventFromCsvData(data: [[String]], completion: @escaping ((Error?) -> Void)) {
        var events : [RecurringEvent] = []
        for eventStrings in data {
            var tempData: [String] = []
            for str in eventStrings {
                tempData.append(str)
            }
            events.append(RecurringEvent(vals: tempData))

        }
            
        
        
        DatabaseManager.shared.createHappenings(events: events)
        
    }
    
//    class dataCodeSetting {
//        var title
//        var id
//        var Venue
//        var address
//        var latitude
//        var longitude
//        var category
//        var bio
//        var date
//        var startTime
//        var endTime
//        var phoneNumber
//        var website
//
//    }
 
    public func testEmail(){
        sendMail(type: .Harrassment, target: SearchObject(User(userId: "1")), descriptor: "took way too long")
    }
    
}
