//
//  DefenderPowerSource.swift
//  GameApp
//
//  Created by Luke Toenjes on 2015-11-29.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit


class DefenderPowerSource : PowerSource
{
    let tower_texture : SKTexture = SKTexture(imageNamed: "DefenderPowerSource")
    static let buildingCost = 50
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, temp: Bool = false)
    {
        let gridSize = int2(2,2)
        let visSize = CGPointMake(2.5,2.5)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, buildingCost: DefenderPowerSource.buildingCost, temp: temp)
    }
}
