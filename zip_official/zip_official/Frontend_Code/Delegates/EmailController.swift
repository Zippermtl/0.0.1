//
//  EmailController.swift
//  zip_official
//
//  Created by user on 9/8/22.
//

import Foundation
//import GoogleAPIClient
//import <MailCore/MailCore.h>

//class EmailController {
    
public enum EmailControllerType: String {
    case Harrassment = "Harrassment"
    case Spam  = "Spam"
    case FakeEvent = "Fake Event/Spam"
    case InappropriatePic = "Inappropriate Photo"
    case InappropriateBio = "Inappropriate Bio"
    case Danger = "Someone is in Danger"
    //MARK: Yianni add more here
}
    
//    let service = GTLServiceGmail()
//    static let shared = EmailController()
//    private let reciever = "contact.zipmtl@gmail.com"
//    private let sender = "zipper.alerts@gmail.com"
//    private let pass = "ZPmtl2.3-17"
//
//    init(){
//
//    }
    
func sendMail(type: EmailControllerType, target: SearchObject, descriptor: String){
    var smtpSession = MCOSMTPSession()
    smtpSession.hostname = "smtp.gmail.com"
    smtpSession.username = "zipper.alerts@gmail.com"
    smtpSession.password = "ZPmtl2.3-17"
    smtpSession.port = 465
    smtpSession.authType = MCOAuthType.saslPlain
    smtpSession.connectionType = MCOConnectionType.TLS
    smtpSession.connectionLogger = {(connectionID, type, data) in
//            if data != nil {
        if let d = data {
            if let string = NSString(data: d, encoding: String.Encoding.utf8.rawValue){
                NSLog("Connectionlogger: \(string)")
            }
        }
    }

    var builder = MCOMessageBuilder()
    builder.header.to = [MCOAddress(displayName: "Contact Zipper", mailbox: "itsrool@gmail.com")]
    builder.header.from = MCOAddress(displayName: "Zipper Alerts", mailbox: "matt@gmail.com")
    builder.header.subject = "Alert: " + type.rawValue
    builder.htmlBody = createBodyFunc(type: type, target: target, desc: descriptor)

    let rfc822Data = builder.data()
    if let sendOperation = smtpSession.sendOperation(with: rfc822Data) {
        sendOperation.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(error)")
            } else {
                NSLog("Successfully sent email!")
            }
        }
    }
    
}

func createBodyFunc(type: EmailControllerType, target: SearchObject, desc: String) -> String {
    let id = AppDelegate.userDefaults.value(forKey: "userId") as! String
    let targetId = target.getId()
    var targetType: String
    let intro = "User: " + id + " has alerted "
    let mid = " for "
    
    if target.isUser() {
        targetType = "User: "
    } else if target.isEvent() {
        targetType = "Event: "
    } else {
        targetType = "Failed to extract type: "
    }
    //MARK: Gabe - comments this out cause idk what you're tryna do here
//    switch type{
//    case .Harrassment:
        return intro + targetType + targetId + mid + type.rawValue + " due to detection in: \n" + "Desc: " + desc
//    }
}
    
//    func sendEmail() {
//
//        guard let query = GTLQueryGmail.queryForUsersMessagesSend(with: nil) else {
//            return
//        }
//
//        let gtlMessage = GTLGmailMessage()
//        gtlMessage.raw = self.generateRawString()
//
//        query.message = gtlMessage
//
//        self.service.executeQuery(query, completionHandler: { (ticket, response, error) -> Void in
//            print("ticket \(String(describing: ticket))")
//            print("response \(String(describing: response))")
//            print("error \(String(describing: error))")
//        })
//    }
//
//    func generateRawString() -> String {
//
//        let dateFormatter:DateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
//        let todayString:String = dateFormatter.string(from: NSDate() as Date)
//
//        let rawMessage = "" +
//            "Date: \(todayString)\r\n" +
//            "From: " + sender + "\r\n" +
//            "To: username <mail>\r\n" +
//            "Subject: Test send email\r\n\r\n" +
//            "Test body"
//
//        print("message \(rawMessage)")
//
//        return GTLEncodeWebSafeBase64(rawMessage.data(using: String.Encoding.utf8))
//    }
    
//}
