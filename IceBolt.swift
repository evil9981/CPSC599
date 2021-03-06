//
//  LightningBolt.swift
//  GameApp
//
//  Created by User on 2015-12-01.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class IceBolt : Ammo
{
    var tower : Tower
    var target: Unit
    
    static let IceBoltTexture = [
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-0-1"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-0-2"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-0-3"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-0-4"),
        
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-1-0"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-1-1"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-1-2"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-1-3"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-1-4"),
        
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-2-0"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-2-1"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-2-2"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-2-3"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-2-4"),
        
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-3-0"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-3-1"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-3-2"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-3-3"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-3-4"),
        
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-4-0"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-4-1"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-4-2"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-4-3"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-4-4"),
        
        
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-5-0"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-5-1"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-5-2"),
        SKTexture(imageNamed: "IceBolt [www.imagesplitter.net]-5-3"),
    ]
    
    init(tower: Tower, target: Unit)
    {
        let texture = SKTexture(imageNamed: "IceBolt")
        let damage = tower.towerDamage
        
        self.tower = tower
        self.target = target
        let size = CGPointMake(1, 1)
        
        let x_pos = tower.visualComp.node.position.x + (0.3 * tower.visualComp.node.frame.width )
        let y_pos = tower.visualComp.node.position.y + (0.75 * tower.visualComp.node.frame.height )
        let world_position = CGPointMake( x_pos , y_pos )
        
        super.init(texture: texture, tower: tower, target: target, world_position: world_position, size: size, damage: damage)
        
        self.visualComp.node.zPosition = GameScene.ZPosition.Ammo.rawValue + CGFloat(self.entity_id / 1000)
        self.visualComp.node.size = CGSize(width: 56*1.6,height: 20*1.6)
        
        let targetPos: CGPoint = get_position_to_shoot(target)
        // Rotate the IceBolt to face the target!
        let angle = atan2f(Float(targetPos.y - self.visualComp.node.position.y), Float(targetPos.x - self.visualComp.node.position.x))
        self.visualComp.node.runAction(SKAction.rotateByAngle(CGFloat(angle), duration: 0))
        
        // Place on a slightly different zPosition
        self.visualComp.node.zPosition = GameScene.ZPosition.Ammo.rawValue + CGFloat(self.entity_id / 1000)
        
        // Follow target
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