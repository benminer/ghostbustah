//
//  Types.swift
//  GhostBustah
//
//  Created by Ben Miner on 10/26/17.
//  Copyright © 2017 Ben Miner. All rights reserved.
//

import Foundation
import SpriteKit

enum NodeType: String {
    case ghost = "ghost"
    case rareGhost = "rare-ghost"
    case bossGhost = "boss-ghost"
}


// TO BE FILLED
enum Sounds {
    // Temporary Fire Sound
   static let fire  = SKAction.playSoundFileNamed("hitBug", waitForCompletion: false)
}

