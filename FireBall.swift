//
//  FireBall.swift
//  GameApp
//
//  Created by User on 2015-12-01.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class FireBall : Ammo
{
    var tower : Tower
    var target: Unit
    
    init(tower: Tower, target: Unit)
    {
        let texture = SKTexture(imageNamed: "FireBall")
        let damage = tower.towerDamage
        
        self.tower = tower
        self.target = target
        
        let size = CGPointMake(2, 2)
        let world_position = CGPointMake( tower.visualComp.node.position.x , tower.visualComp.node.position.y )

        super.init(texture: texture, tower: tower, target: target, world_position: world_position, size: size, damage: damage)
        
        self.visualComp.node.zPosition = GameScene.ZPosition.Ammo.rawValue + CGFloat(self.entity_id / 1000)
        
        let targetPos: CGPoint = Ammo.get_position_to_shoot(target)
        
        let followOrc = SKAction.moveTo(targetPos, duration: 0.25)
        
        self.visualComp.node.runAction(followOrc, completion:
            {
                self.tower.scene.removeChildrenInArray([self.visualComp.node])
                target.gotHit(self)
        })
    }
}