//
//  Goblin.swift
//  GameApp
//
//  Created by Roger Sun on 2015-12-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class Goblin: Unit
{
    static let leftTextures = [SKTexture(imageNamed: "goblin_left_0"), SKTexture(imageNamed: "goblin_left_1"), SKTexture(imageNamed: "goblin_left_0"), SKTexture(imageNamed: "goblin_left_2")]
    
    static let rightTextures = [SKTexture(imageNamed: "goblin_right_0"), SKTexture(imageNamed: "goblin_right_1"), SKTexture(imageNamed: "goblin_right_0"), SKTexture(imageNamed: "goblin_right_2")]
    
    static let upTextures = [SKTexture(imageNamed: "goblin_up_0"), SKTexture(imageNamed: "goblin_up_1"), SKTexture(imageNamed: "goblin_up_0"), SKTexture(imageNamed: "goblin_up_2")]
    
    static let downTextures = [SKTexture(imageNamed: "goblin_down_0"), SKTexture(imageNamed: "goblin_down_1"), SKTexture(imageNamed: "goblin_down_0"), SKTexture(imageNamed: "goblin_down_2")]
    
    static let goblinDeath = [SKTexture(imageNamed: "goblin_death_0"), SKTexture(imageNamed: "goblin_death_1"), SKTexture(imageNamed: "goblin_death_2"), SKTexture(imageNamed: "goblin_death_3")]
    
    static let cost = 10
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, speed: NSTimeInterval)
    {
        let gridSize = int2(1,1)
        let visSize = CGPointMake(1.2, 1.2)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position,
            leftTextures: Goblin.leftTextures, rightTextures: Goblin.rightTextures,
            upTextures: Goblin.upTextures, downTextures: Goblin.downTextures,
            speed: speed, gridSize: gridSize, visSize: visSize)
        
        self.hp = 35
    }
}