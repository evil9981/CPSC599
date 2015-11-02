//
//  File.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Unit: GKEntity
{
    var movementComp: MovementComponent!
    var visualComp: VisualComponent!
    var logicComp: LogicComponent!
    
    var entity_id: Int = -1
    
    init(scene: GameScene, world_position: CGPoint, leftTextures: [SKTexture] , rightTextures: [SKTexture], upTextures: [SKTexture] ,downTextures: [SKTexture], speed: NSTimeInterval)
    {
        super.init()
        // Inc static entity id and set current
        entity_id = Unit.get_next_id()
        
        self.movementComp = MovementComponent(unit: self, leftTextures: leftTextures, rightTextures: rightTextures, upTextures: upTextures, downTextures: downTextures, speed: speed)
        self.addComponent(movementComp)
        
        // Set visual component and add it to the scene
        self.visualComp = VisualComponent(scene: scene, texture: leftTextures[0], world_position: world_position)
        self.addComponent(visualComp)
        
        // Add the logical component that moves creatures on the tiles set
        self.logicComp = LogicComponent()
        self.addComponent(logicComp)
    }
    
    func update()
    {
        if (!movementComp.is_moving)
        {
            visualComp.node!.runAction(movementComp.current_movement, completion: { self.movementComp.finishedMovement() })
            movementComp.is_moving = true
        }
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
    
    // MARK: Static methods and properties
    static var next_entity_id : Int = -1
    static func get_next_id() -> Int
    {
        Unit.next_entity_id++;
        return Unit.next_entity_id;
    }
}