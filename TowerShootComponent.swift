//
//  TowerShootComponent.swift
//  GameApp
//
//  Created by User on 2015-11-03.
//  Copyright © 2015 Eric. All rights reserved.
//

import GameplayKit
import SpriteKit

class TowerShootComponent: GKComponent
{
    var tower: Building
    
    var units = [Unit]()
    var current_target : Unit!

    var range: int2
    var towerDamage: Int
    
    init(tower: Building, range: int2, towerDamage: Int)
    {
        self.tower = tower
        self.range = range
        self.towerDamage = towerDamage
        
        super.init()
        
        tower.gridComp.updateTilesWithTower(range)
    }
    
    func add_unit_to_range(unit: Unit)
    {
        if !units.contains(unit)
        {
            units.append(unit)
        }
        
        if (current_target == nil)
        {
            current_target = unit
            debugPrint("New target aquired! Entity_id for target: \(unit.entity_id)")
        }
    }
    
    var should_shoot = true
    func update()
    {
        if (should_shoot && current_target != nil)
        {
            should_shoot = false
            
            let cannonball = SKSpriteNode(imageNamed: "CannonBall")
            cannonball.position = CGPointMake(tower.visualComp.node.position.x + Tile.tileWidth * 0.5, tower.visualComp.node.position.y + Tile.tileHeight * 1.8)
            //cannonball.anchorPoint = CGPointMake(5, 0.2)
            cannonball.zPosition = 4
            cannonball.size = CGSize(width: 32,height: 32)
            tower.scene.addChild(cannonball)
            
            let targetPos: CGPoint = get_position_to_shoot(current_target)
            
            let followOrc = SKAction.moveTo(targetPos, duration: 0.5)
            let cooldown = SKAction.waitForDuration(0.5)
            cannonball.runAction(followOrc, completion:
            {
                self.tower.scene.removeChildrenInArray([cannonball])
                self.tower.visualComp.node.runAction(cooldown, completion: { self.should_shoot = true;  } )
            })
            
            check_target()
        }
    }
    
    func check_target()
    {
        let target_pos = current_target.gridComp.current_pos
        let current_pos = self.tower.gridComp.current_pos
        
        if ( abs(target_pos.x - current_pos.x) >= (range.x+tower.gridComp.size.x) || abs(target_pos.y - current_pos.y) >= range.y+tower.gridComp.size.y )
        {
            units = units.filter { return $0.entity_id != current_target.entity_id } // Remove the current target
            current_target = nil // Remove it from the current target
        }
       
        if (current_target != nil)
        {
            if (!self.tower.scene.children.contains(current_target.visualComp.node))
            {
                units = units.filter { return $0.entity_id != current_target.entity_id } // Remove the current target
                current_target = nil // Remove it from the current target
            }
        }
        
        if (units.count != 0)
        {
            current_target = units[0]
        }
    }
    
    func get_position_to_shoot(unit: Unit) -> CGPoint
    {
        let pos = unit.visualComp.node.position
        
        switch(unit.movementComp.current_mov_option!)
        {
        case .MoveLeft:
            return CGPointMake(pos.x - 1 * Tile.tileWidth, pos.y)
        case .MoveRight:
            return CGPointMake(pos.x + 1 * Tile.tileWidth, pos.y)
        case .MoveUp:
            return CGPointMake(pos.x, pos.y + 1 * Tile.tileHeight)
        case .MoveDown:
            return CGPointMake(pos.x, pos.y - 1 * Tile.tileHeight)
            
        default:
            return pos
        }
    }
}
