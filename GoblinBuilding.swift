//
//  GoblinBuilding.swift
//  GameApp
//
//  Created by Roger Sun on 2015-12-01.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class GoblinBuilding: Spawner
{
    let tower_texture : SKTexture = SKTexture(imageNamed: "Goblin_Building")
    
    static let towerCost : Int = 100
    static let unitCooldown : Float = 1.5 // second
    
    static let goblinB_Building = [SKTexture(imageNamed: "GoblinB_In_Progress_01"), SKTexture(imageNamed: "GoblinB_In_Progress_02")]
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, temp: Bool = false)
    {
        let gridSize = int2(2,2)
        let visSize = CGPointMake(2.5,2.5)
        
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, towerCost: GoblinBuilding.towerCost, unitCooldown: GoblinBuilding.unitCooldown, temp: temp)
    }
    
    
}
