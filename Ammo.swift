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
    
    init(scene: GameScene, texture: SKTexture, speed: NSTimeInterval, world_position: CGPoint, size: CGPoint, damage: Int)
    {
        self.scene = scene
        self.damage = damage
        
        super.init()
        
        // Set visual component and add it to the scene
        self.visualComp = VisualComponent(scene: scene, parent_entity: self, texture: texture, world_position: world_position, size: size)
        self.addComponent(visualComp)
    }
}