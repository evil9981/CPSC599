//
//  RegularTower.swift
//  GameApp
//
//  Created by Luke Toenjes on 2015-11-30.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class RegularTower : Tower
{
    let tower_texture : SKTexture = SKTexture(imageNamed: "RegularTower")
    
    static let towerCost : Int = 75
    static let towerDamage : Int = 25
    static let towerSpeed: NSTimeInterval = 1.0 // Once a second
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, temp: Bool = false)
    {
        let gridSize = int2(2,2)
        let visSize = CGPointMake(2.5,2.5)
        let range = int2(3,3)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, range: range, towerDamage: RegularTower.towerDamage, towerShootingSpeed: RegularTower.towerSpeed, towerCost: RegularTower.towerCost, temp: temp)
    }
}
