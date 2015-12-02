//
//  AttackerPowerSource.swift
//  GameApp
//
//  Created by Roger Sun on 2015-12-01.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit


class AttackerPowerSource : Building
{
    let tower_texture : SKTexture = SKTexture(imageNamed: "AttackerPowerSource")
    static let buildingCost = 50
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, temp: Bool = false)
    {
        let gridSize = int2(2,2)
        let visSize = CGPointMake(2,2)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, buildingCost: AttackerPowerSource.buildingCost, temp: temp)
    }
}
