//
//  Movement.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

public class MovementComponent: GKComponent
{
    var unit: Unit
    
    public var moveLeft: SKAction!
    public var moveRight: SKAction!
    public var moveUp: SKAction!
    public var moveDown: SKAction!

    var current_movement: SKAction!
    var current_mov_option: TileOpts!
    var is_moving: Bool = false
    
    init(unit:Unit, leftTextures: [SKTexture] , rightTextures: [SKTexture], upTextures: [SKTexture] ,downTextures: [SKTexture], speed: NSTimeInterval)
    {
        self.unit = unit
        
        super.init()
        
        self.updateActions(leftTextures, rightTextures: rightTextures, upTextures: upTextures, downTextures: downTextures, speed: speed)
        
        current_movement = moveRight
        current_mov_option = TileOpts.MoveRight
    }
    
    func update()
    {
        switch(self.current_mov_option!)
        {
        case .MoveLeft:
            move_left()
            break
        case .MoveRight:
            move_right()
            break
        case .MoveUp:
            move_up()
            break
        case .MoveDown:
            move_down()
            break
            
        default:
            debugPrint("[MovementCompoenent] This shouldn't ever happen")
            break
        }
        
        if (!(unit.gridComp.current_tile is MazeTile))
        {
            unit.destroy()
        }
    }
    
    func teleport_to_tile()
    {
        let tile = self.unit.gridComp.current_tile
        let target_tile = tile.teleportDestination!
        
        let target_pos = target_tile.position
        
        let newScenePos = self.unit.scene.pointForCoordinate(target_pos)
        
        // Update grid comp
        unit.gridComp.move_unit_to_tile(target_tile.position)
        
        // Update visual comp
        unit.visualComp.node.position = CGPointMake(newScenePos.x + 0.7 * Tile.tileWidth, newScenePos.y + 0.2 * Tile.tileHeight)
        
        handle_move_opt()
    }
    
    func handle_move_opt()
    {
        switch (unit.gridComp.current_tile.moveOpt)
        {
        case .MoveLeft:
            current_movement = self.moveLeft
            current_mov_option = TileOpts.MoveLeft
            break
        case .MoveRight:
            current_movement = self.moveRight
            current_mov_option = TileOpts.MoveRight
            break
        case .MoveUp:
            current_movement = self.moveUp
            current_mov_option = TileOpts.MoveUp
            break
        case .MoveDown:
            current_movement = self.moveDown
            current_mov_option = TileOpts.MoveDown
            break
        case .Goal:
            unit.scene.take_one_life()
            break
        case .Teleport:
            teleport_to_tile()
        default:
            break
        }
    }
    
    func move_left()
    {
        let new_pos = int2(unit.gridComp.current_pos.x-1, unit.gridComp.current_pos.y)
        unit.gridComp.move_unit_to_tile(new_pos)
        
        handle_move_opt()
    }
    
    func move_right()
    {
        let new_pos = int2(unit.gridComp.current_pos.x+1, unit.gridComp.current_pos.y)
        unit.gridComp.move_unit_to_tile(new_pos)
        
        handle_move_opt()
    }
    
    func move_up()
    {
        let new_pos = int2(unit.gridComp.current_pos.x, unit.gridComp.current_pos.y+1)
        unit.gridComp.move_unit_to_tile(new_pos)
        
        handle_move_opt()
    }
    
    func move_down()
    {
        let new_pos = int2(unit.gridComp.current_pos.x, unit.gridComp.current_pos.y-1)
        unit.gridComp.move_unit_to_tile(new_pos)
        
        handle_move_opt()
    }
    
    func finishedMovement()
    {
        is_moving = false
    }
    
    func updateActions(leftTextures: [SKTexture] , rightTextures: [SKTexture], upTextures: [SKTexture] ,downTextures: [SKTexture], speed: NSTimeInterval)
    {
        self.moveLeft = moveLeftAction(speed, textures: leftTextures)
        self.moveRight = moveRightAction(speed, textures: rightTextures)
        self.moveUp = moveUpAction(speed, textures: upTextures)
        self.moveDown = moveDownAction(speed, textures: downTextures)
    }
    
    func moveLeftAction(speed: NSTimeInterval, textures: [SKTexture]) -> SKAction
    {
        let moveAction = SKAction.moveByX(-Tile.tileWidth, y: 0, duration: speed)
        let timePerFrame = speed / NSTimeInterval(textures.count)
        let spritePlay = SKAction.animateWithTextures(textures, timePerFrame: timePerFrame)
        
        return SKAction.group([moveAction, spritePlay])
    }
    
    func moveRightAction(speed: NSTimeInterval, textures: [SKTexture]) -> SKAction
    {
        let moveAction = SKAction.moveByX(Tile.tileWidth, y: 0, duration: speed)
        let timePerFrame = speed / NSTimeInterval(textures.count)
        let spritePlay = SKAction.animateWithTextures(textures, timePerFrame: timePerFrame)
        
        return SKAction.group([moveAction, spritePlay])
    }
    
    func moveUpAction(speed: NSTimeInterval, textures: [SKTexture]) -> SKAction
    {
        let moveAction = SKAction.moveByX(0, y: Tile.tileHeight, duration: speed)
        let timePerFrame = speed / NSTimeInterval(textures.count)
        let spritePlay = SKAction.animateWithTextures(textures, timePerFrame: timePerFrame)
        
        return SKAction.group([moveAction, spritePlay])
    }
    
    func moveDownAction(speed: NSTimeInterval, textures: [SKTexture]) -> SKAction
    {
        let moveAction = SKAction.moveByX(0, y: -Tile.tileHeight, duration: speed)
        let timePerFrame = speed / NSTimeInterval(textures.count)
        let spritePlay = SKAction.animateWithTextures(textures, timePerFrame: timePerFrame)
        
        return SKAction.group([moveAction, spritePlay])
    }
}
