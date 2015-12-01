//
//  File.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class Unit: GameEntity
{
    var scene: GameScene
    
    var movementComp: MovementComponent!
    var visualComp: VisualComponent!
    var gridComp: GridComponent!
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, leftTextures: [SKTexture] , rightTextures: [SKTexture], upTextures: [SKTexture] ,downTextures: [SKTexture], speed: NSTimeInterval, gridSize: int2, visSize: CGPoint)
    {
        self.scene = scene
        
        super.init()
        
        // Add the logical component that moves creatures on the tiles set
        self.gridComp = GridComponent(tiles: scene.tiles, unit: self, pos: grid_position, size: gridSize)
        self.addComponent(gridComp)
        
        // Add the movement component
        self.movementComp = MovementComponent(unit: self, leftTextures: leftTextures, rightTextures: rightTextures, upTextures: upTextures, downTextures: downTextures, speed: speed)
        self.addComponent(movementComp)
        
        // Set visual component and add it to the scene
        self.visualComp = VisualComponent(scene: scene, parent_entity: self, texture: leftTextures[0], world_position: world_position, size: visSize)
        self.addComponent(visualComp)
        
        self.movementComp.handle_move_opt()
    }
    
    func update(delta: NSTimeInterval)
    {
        if (!movementComp.is_moving)
        {
            visualComp.node.runAction(movementComp.current_movement, completion: { self.movementComp.finishedMovement() })
            
            movementComp.update()
            
            movementComp.is_moving = true
        }
    }
    
    func gotHit(ammo: Ammo)
    {
        debugPrint("Unit hit for \(ammo.damage)")
    }
    
    func moveLeft()
    {
        movementComp.current_movement = movementComp.moveLeft
    }
    func moveRight()
        
    {movementComp.current_movement = movementComp.moveRight
    }
    func moveUp()
    {
        movementComp.current_movement = movementComp.moveUp
    }
    func moveDown()
    {
        movementComp.current_movement = movementComp.moveDown
    }
    
    func destroy()
    {
        scene.removeChildrenInArray([self.visualComp.node])
        scene.all_units.removeValueForKey(self.entity_id)
    }
}