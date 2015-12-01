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

public class PigMoveComponent: GKComponent
{
    var unit: Pig
    
    public var moveLeft: SKAction!
    public var moveRight: SKAction!
    public var moveUp: SKAction!
    public var moveDown: SKAction!

    var current_movement: SKAction!
    var current_mov_option: TileOpts!
    var is_moving: Bool = false
    
    init(unit:Pig, leftTextures: [SKTexture] , rightTextures: [SKTexture], upTextures: [SKTexture] ,downTextures: [SKTexture], speed: NSTimeInterval)
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
    }

    func get_random_move()
    {
        var position = unit.gridComp.current_pos
        
        var tile = Tile.getTile(unit.gridComp.tiles, pos: unit.gridComp.current_pos)
        var attempt = 0
        
        while ( attempt == 0 || !(tile is GoalTile) )
        {
            let num = arc4random_uniform( 4 )
            switch (num)
            {
            case 0:
                position = int2(position.x + 1, position.y )
                
                current_movement = self.moveRight
                current_mov_option = TileOpts.MoveRight
            case 1:
                position = int2(position.x - 1, position.y )
                
                current_movement = self.moveLeft
                current_mov_option = TileOpts.MoveLeft
            case 2:
                position = int2(position.x , position.y + 1)
                
                current_movement = self.moveUp
                current_mov_option = TileOpts.MoveUp
            case 3:
                position = int2(position.x , position.y - 1)
                
                current_movement = self.moveDown
                current_mov_option = TileOpts.MoveDown
                
            default:
                break
            }
            
            tile = Tile.getTile(unit.gridComp.tiles, pos: position)
            position = unit.gridComp.current_pos
            attempt++
        }
        
    }
    
    func handle_move_opt()
    {
        get_random_move()
        
        if (!(unit.gridComp.current_tile is GoalTile))
        {
            unit.destroy()
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
        
        unit.update()
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
