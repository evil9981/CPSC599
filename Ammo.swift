//
//  Ammo.swift
//  GameApp
//
//  Created by User on 2015-11-26.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class Ammo: GameEntity
{
    var scene: GameScene
    var damage: Int
    
    var visualComp: VisualComponent!

    enum ammoType
    {
        case CannonBall
        case FireBall
        case Lightning
    }
    
    init(texture: SKTexture, tower: Tower, target: Unit, world_position: CGPoint, size: CGPoint, damage: Int)
    {
        self.scene = tower.scene
        self.damage = damage
        
        super.init()
        
        // Set visual component and add it to the scene
        self.visualComp = VisualComponent(scene: scene, parent_entity: self, texture: texture, world_position: world_position, size: size)
        self.addComponent(visualComp)
    }
    
    static func generate_ammo(tower: Tower, target: Unit) -> Ammo
    {
        if (tower is FireTower)
        {
            return FireBall(tower: tower, target: target)
        }
        else if (tower is IceTower)
        {
            return IceBolt(tower: tower, target: target)
        }
        
        return CannonBall(tower: tower, target: target)
    }
}