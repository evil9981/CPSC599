//
//  Troll.swift
//  GameApp
//
//  Created by Roger Sun on 2015-12-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class Troll: Unit
{
    static let leftTextures = [SKTexture(imageNamed: "troll_left_0"), SKTexture(imageNamed: "troll_left_1"), SKTexture(imageNamed: "troll_left_0"), SKTexture(imageNamed: "troll_left_2")]
    
    static let rightTextures = [SKTexture(imageNamed: "troll_right_0"), SKTexture(imageNamed: "troll_right_1"), SKTexture(imageNamed: "troll_right_0"), SKTexture(imageNamed: "troll_right_2")]
    
    static let upTextures = [SKTexture(imageNamed: "troll_up_0"), SKTexture(imageNamed: "troll_up_1"), SKTexture(imageNamed: "troll_up_0"), SKTexture(imageNamed: "troll_up_2")]
    
    static let downTextures = [SKTexture(imageNamed: "troll_down_0"), SKTexture(imageNamed: "troll_down_1"), SKTexture(imageNamed: "troll_down_0"), SKTexture(imageNamed: "troll_down_2")]
    
    static let trollDeath = [SKTexture(imageNamed: "troll_death_0"), SKTexture(imageNamed: "troll_death_1"), SKTexture(imageNamed: "troll_death_2"), SKTexture(imageNamed: "troll_death_3")]
    
    static let cost = 40
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, speed: NSTimeInterval)
    {
        let gridSize = int2(1,1)
        let visSize = CGPointMake(1.2, 1.2)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position,
            leftTextures: Troll.leftTextures, rightTextures: Troll.rightTextures,
            upTextures: Troll.upTextures, downTextures: Troll.downTextures,
            speed: speed, gridSize: gridSize, visSize: visSize)
        
        self.hp = 110
    }
}

