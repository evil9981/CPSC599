//
//  IceTower.swift
//  GameApp
//
//  Created by Luke Toenjes on 2015-11-30.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit



class IceTower : Tower
{
    let tower_texture : SKTexture = SKTexture(imageNamed: "IceTower")
    
    static let towerCost : Int = 125
    static let towerDamage : Int = 15
    static let towerShootingSpeed : NSTimeInterval = 1.0
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, temp: Bool = false)
    {
        let gridSize = int2(2,2)
        let visSize = CGPointMake(2.5,2.5)
        let range = int2(3,3)
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, range: range, towerDamage: IceTower.towerDamage, towerShootingSpeed: IceTower.towerShootingSpeed, towerCost: IceTower.towerCost ,temp: temp)
    }
}
