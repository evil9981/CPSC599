//
//  RegularTower.swift
//  GameApp
//
//  Created by Luke Toenjes on 2015-11-30.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

let regularTowerCost : Int = 75
let regularTowerDamage : Int = 25

class RegularTower : Tower
{
    let tower_texture : SKTexture = SKTexture(imageNamed: "RegularTower")
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint)
    {
        let gridSize = int2(2,2)
        let visSize = CGPointMake(3.5,3.5)
        let range = int2(3,3)
        let towerDamage = 25
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, range: range, towerDamage: towerDamage)
    }
}
