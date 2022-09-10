//
//  CategoryType.swift
//  zip_official
//
//  Created by user on 9/9/22.
//

import Foundation

public enum CategoryType: String {
    case HappyHour = "Happy Hour"
    case Trivia = "Trivia"
    case Deal = "Deal"
    case OpenMic = "Open Mic"
    case Music = "Music"
    
    public var imageName: String {
        switch self {
        case .HappyHour: return "happenings.happyhour"
        case .Trivia: return "happenings.trivia"
        case .Deal: return "happenings.deal"
        case .OpenMic: return "happenings.openMic"
        case .Music: return "happenings.music"
        }
    }
}
