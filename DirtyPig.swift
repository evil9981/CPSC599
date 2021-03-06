//
//  dirty_pig.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class DirtyPig: Pig
{
    static let leftTextures = [SKTexture(imageNamed: "dirty_pig_left_0"), SKTexture(imageNamed: "dirty_pig_left_1"), SKTexture(imageNamed: "dirty_pig_left_0"), SKTexture(imageNamed: "dirty_pig_left_2")]
    
    static let rightTextures = [SKTexture(imageNamed: "dirty_pig_right_0"), SKTexture(imageNamed: "dirty_pig_right_1"), SKTexture(imageNamed: "dirty_pig_right_0"), SKTexture(imageNamed: "dirty_pig_right_2")]
    
    static let upTextures = [SKTexture(imageNamed: "dirty_pig_up_0"), SKTexture(imageNamed: "dirty_pig_up_1"), SKTexture(imageNamed: "dirty_pig_up_0"), SKTexture(imageNamed: "dirty_pig_up_2")]
    
    static let downTextures = [SKTexture(imageNamed: "dirty_pig_down_0"), SKTexture(imageNamed: "dirty_pig_down_1"), SKTexture(imageNamed: "dirty_pig_down_0"), SKTexture(imageNamed: "dirty_pig_down_2")]
    
    static let dirtyDeath = [SKTexture(imageNamed: "dirty_pig_death_0"), SKTexture(imageNamed: "pig_death_1"), SKTexture(imageNamed: "pig_death_2")]
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, speed: NSTimeInterval)
    {
        let visSize = CGPointMake(1.2, 1.2)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position,
            leftTextures: DirtyPig.leftTextures, rightTextures: DirtyPig.rightTextures,
            upTextures: DirtyPig.upTextures, downTextures: DirtyPig.downTextures,
            speed: speed, visSize: visSize)

    }
}
