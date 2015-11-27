//
//  fancy_pig.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class FancyPig: Pig
{
    static let leftTextures = [SKTexture(imageNamed: "fancy_pig_left_0"), SKTexture(imageNamed: "fancy_pig_left_1"), SKTexture(imageNamed: "fancy_pig_left_0"), SKTexture(imageNamed: "fancy_pig_left_2")]
    
    static let rightTextures = [SKTexture(imageNamed: "fancy_pig_right_0"), SKTexture(imageNamed: "fancy_pig_right_1"), SKTexture(imageNamed: "fancy_pig_right_0"), SKTexture(imageNamed: "fancy_pig_right_2")]
    
    static let upTextures = [SKTexture(imageNamed: "fancy_pig_up_0"), SKTexture(imageNamed: "fancy_pig_up_1"), SKTexture(imageNamed: "fancy_pig_up_0"), SKTexture(imageNamed: "fancy_pig_up_2")]
    
    static let downTextures = [SKTexture(imageNamed: "fancy_pig_down_0"), SKTexture(imageNamed: "fancy_pig_down_1"), SKTexture(imageNamed: "fancy_pig_down_0"), SKTexture(imageNamed: "fancy_pig_down_2")]
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, speed: NSTimeInterval)
    {
        let visSize = CGPointMake(1.2, 1.2)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position,
            leftTextures: FancyPig.leftTextures, rightTextures: FancyPig.rightTextures,
            upTextures: FancyPig.upTextures, downTextures: FancyPig.downTextures,
            speed: speed, visSize: visSize)

        visualComp.node.zPosition = 3
    }
}