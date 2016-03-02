//
//  FireTower.swift
//  GameApp
//
//  Created by Luke Toenjes on 2015-11-30.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit



class FireTower : Tower
{
    let tower_texture : SKTexture = SKTexture(imageNamed: "FireTower")
    
    static let towerCost : Int = 100
    static let towerDamage : Int = 30
    static let towerSpeed: NSTimeInterval = 1.0 // Once a second
    
    static let fireT_Building = [SKTexture(imageNamed: "FireT_In_Progress_01"), SKTexture(imageNamed: "FireT_In_Progress_02")]
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, temp: Bool = false)
    {
        let gridSize = int2(2,2)
        let visSize = CGPointMake(2.5,2.5)
        let range = int2(3,3)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, range: range, towerDamage: FireTower.towerDamage, towerShootingSpeed: FireTower.towerSpeed, towerCost: FireTower.towerCost, temp: temp)
    }
}
