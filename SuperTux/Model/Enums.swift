//
//  Enums.swift
//  SuperTux
//
//  Created by Thaís Fernandes on 02/09/21.
//

import Foundation

enum Directions: CaseIterable {
    case left
    case right
    
    var description: String {
        switch self {
            case .left: return "Left"
            case .right: return "Right"
        }
    }
}

enum TuxStates {
    case standing
    case walking
    case jumping
    
    var assetName: String {
        switch self {
            case .standing: return "TuxStanding"
            case .walking: return "TuxWalking"
            case .jumping: return "TuxJumping"
        }
    }
}
