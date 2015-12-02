//
//  SpawnPoint.swift
//  GameApp
//
//  Created by User on 2015-12-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit


class FlagUp : Building
{
    let flag_up_texture : SKTexture = SKTexture(imageNamed: "flag_up")
    static let buildingCost = 0
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, temp: Bool = false)
    {
        let gridSize = int2(1,1)
        let visSize = CGPointMake(2,2)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: flag_up_texture, gridSize: gridSize, visSize: visSize, buildingCost: AttackerPowerSource.buildingCost, temp: temp)
    }
}
