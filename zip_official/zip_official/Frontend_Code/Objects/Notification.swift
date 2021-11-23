//
//  Notification.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/8/21.
//

import Foundation
import UIKit

enum NotificationType: Int, CaseIterable {
    case news
    case eventPublic
    case eventInvite
    case eventTimeChange
    case eventAddressChange
    case eventLimitedSpots
    case zipRequest
    case zipAccepted
}


struct ZipNotification {
    var fromId: Int? //figure this shit out later
    let type: NotificationType
    let image: UIImage
    let time: TimeInterval
    var hasRead: Bool = false
}
