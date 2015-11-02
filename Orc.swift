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
    static let leftTextures = [SKTexture(imageNamed: "left_0"), SKTexture(imageNamed: "left_1"), SKTexture(imageNamed: "left_0"), SKTexture(imageNamed: "left_2")]
    
    static let rightTextures = [SKTexture(imageNamed: "right_0"), SKTexture(imageNamed: "right_1"), SKTexture(imageNamed: "right_0"), SKTexture(imageNamed: "right_2")]
    
    static let upTextures = [SKTexture(imageNamed: "up_0"), SKTexture(imageNamed: "up_1"), SKTexture(imageNamed: "up_0"), SKTexture(imageNamed: "up_2")]
    
    static let downTextures = [SKTexture(imageNamed: "down_0"), SKTexture(imageNamed: "down_1"), SKTexture(imageNamed: "down_0"), SKTexture(imageNamed: "down_2")]
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, speed: NSTimeInterval)
    {
        super.init(scene: scene, grid_position: grid_position, world_position: world_position,
            leftTextures: Orc.leftTextures, rightTextures: Orc.rightTextures,
            upTextures: Orc.upTextures, downTextures: Orc.downTextures,
            speed: speed)
    }
}
