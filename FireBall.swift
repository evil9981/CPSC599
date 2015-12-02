//
//  FireBall.swift
//  GameApp
//
//  Created by User on 2015-12-01.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit
import Darwin

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
        
        let size = CGPointMake(1, 1)
        let x_pos = tower.visualComp.node.position.x + (0.3 * tower.visualComp.node.frame.width )
        let y_pos = tower.visualComp.node.position.y + (0.75 * tower.visualComp.node.frame.height )
        
        let world_position = CGPointMake( x_pos , y_pos )

        super.init(texture: texture, tower: tower, target: target, world_position: world_position, size: size, damage: damage)
        
        let targetPos: CGPoint = get_position_to_shoot(target)
        
        // Rotate the fireball to face the target!
        let angle = atan2f(Float(targetPos.y - self.visualComp.node.position.y), Float(targetPos.x - self.visualComp.node.position.x))
        self.visualComp.node.runAction(SKAction.rotateByAngle(CGFloat(angle), duration: 0))
        self.visualComp.node.size = CGSize(width: 36*1.6,height: 20*1.6)
        
        // Place on a slightly different zPosition
        self.visualComp.node.zPosition = GameScene.ZPosition.Ammo.rawValue + CGFloat(self.entity_id / 1000)
        
        
        // Follow the target
        let followOrc = SKAction.moveTo(targetPos, duration: 0.25)
        self.visualComp.node.runAction(followOrc, completion:
            {
                self.tower.scene.removeChildrenInArray([self.visualComp.node])
                target.gotHit(self)
        })
    }
    
    func get_position_to_shoot(unit: Unit) -> CGPoint
    {
        let pos = unit.visualComp.node.position
        
        switch(unit.movementComp.current_mov_option!)
        {
        case .MoveLeft:
            return CGPointMake(pos.x + 0.7 * Tile.tileWidth, pos.y + 0.4 * Tile.tileHeight)
        case .MoveRight:
            return CGPointMake(pos.x + 1.0 * Tile.tileWidth, pos.y + 0.4 * Tile.tileHeight)
        case .MoveUp:
            return CGPointMake(pos.x + 0.2 * Tile.tileWidth, pos.y + 0.5 * Tile.tileHeight)
        case .MoveDown:
            return CGPointMake(pos.x + 0.1 * Tile.tileWidth, pos.y + 0.2 * Tile.tileHeight)
            
        default:
            return pos
        }
    }
}