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
    var tower: Tower
    
    var units = [Unit]()
    var current_target : Unit!

    var range: int2
    var towerDamage: Int
    
    init(tower: Tower, range: int2, towerDamage: Int)
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
    var shoot_cooldown: NSTimeInterval = 0.0
    
    func update(delta: NSTimeInterval)
    {
        // Lower the cooldown
        shoot_cooldown -= delta
        
        // Actually shoot!
        if (shoot_cooldown <= 0 && current_target != nil)
        {
            Ammo.generate_ammo(tower, target: current_target)
            shoot_cooldown = tower.towerShootingSpeed
        }
        
        // Check if target needs to be canceled / switched
        check_target()
    }
    
    func check_target()
    {
        if (current_target != nil)
        {
            let target_pos = current_target.gridComp.current_pos
            let current_pos = self.tower.gridComp.current_pos
            
            let diff = abs(target_pos.x - current_pos.x)
            var horizontal_limit = true
            
            // Target is to the left of the tower
            if (diff <= 0)
            {
                // Target is to the left of the tower
                horizontal_limit = (diff > range.x + tower.gridComp.size.x + 1)
            }
            else
            {
                // Target is to the right of the tower
                horizontal_limit = (diff > range.x )
            }
            
            let vertical_limit = ( abs(target_pos.y - current_pos.y) >= range.y+tower.gridComp.size.y )

            
            let target_not_in_range = ( horizontal_limit || vertical_limit )
            let target_destroyed = (!self.tower.scene.children.contains(current_target.visualComp.node))
            
            if ( target_not_in_range || target_destroyed)
            {
                remove_current_target()
            }
        }
            
        if (current_target == nil && units.count != 0)
        {
            current_target = units[0]
        }
    }
    
    func remove_current_target()
    {
        units = units.filter { return $0.entity_id != current_target.entity_id } // Remove the current target
        current_target = nil // Remove it from the current target
    }
    
}
