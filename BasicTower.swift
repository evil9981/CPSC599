//
//  BasicTower.swift
//  GameApp
//
//  Created by User on 2015-11-03.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

let basicTowerCost : Int = 100

class BasicTower : Tower
{
    let tower_texture : SKTexture = SKTexture(imageNamed: "BasicTower")
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint)
    {
        let gridSize = int2(2,2)
        let visSize = CGPointMake(2,2)
        let range = int2(3,3)
        let towerDamage = 30
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, range: range, towerDamage: towerDamage)
    }
}
