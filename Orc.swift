//
//  Orc.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class Orc: Unit
{
    static let leftTextures = [SKTexture(imageNamed: "orc_left_0"), SKTexture(imageNamed: "orc_left_1"), SKTexture(imageNamed: "orc_left_0"), SKTexture(imageNamed: "orc_left_2")]
    
    static let rightTextures = [SKTexture(imageNamed: "orc_right_0"), SKTexture(imageNamed: "orc_right_1"), SKTexture(imageNamed: "orc_right_0"), SKTexture(imageNamed: "orc_right_2")]
    
    static let upTextures = [SKTexture(imageNamed: "orc_up_0"), SKTexture(imageNamed: "orc_up_1"), SKTexture(imageNamed: "orc_up_0"), SKTexture(imageNamed: "orc_up_2")]
    
    static let downTextures = [SKTexture(imageNamed: "orc_down_0"), SKTexture(imageNamed: "orc_down_1"), SKTexture(imageNamed: "orc_down_0"), SKTexture(imageNamed: "orc_down_2")]
    
    static let orcDeath = [SKTexture(imageNamed: "orc_death_0"), SKTexture(imageNamed: "orc_death_1"), SKTexture(imageNamed: "orc_death_2"), SKTexture(imageNamed: "orc_death_3")]
    
    static let cost = 20
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, speed: NSTimeInterval)
    {
        let gridSize = int2(1,1)
        let visSize = CGPointMake(1.2, 1.2)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position,
            leftTextures: Orc.leftTextures, rightTextures: Orc.rightTextures,
            upTextures: Orc.upTextures, downTextures: Orc.downTextures,
            speed: speed, gridSize: gridSize, visSize: visSize)
        
        self.hp = 50
    }
}
