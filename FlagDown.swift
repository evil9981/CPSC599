//
//  SpawnPoint.swift
//  GameApp
//
//  Created by User on 2015-12-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit


class FlagDown : Building
{
    let flag_down_texture : SKTexture = SKTexture(imageNamed: "flag_down")
    static let buildingCost = 0
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, temp: Bool = false)
    {
        let gridSize = int2(1,1)
        let visSize = CGPointMake(2,2)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: flag_down_texture, gridSize: gridSize, visSize: visSize, buildingCost: AttackerPowerSource.buildingCost, temp: temp)
    }
}
