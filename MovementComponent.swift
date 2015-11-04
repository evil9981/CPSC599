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
        switch(unit.movementComp.current_mov_option!)
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
        case .Treasure:
            debugPrint("REACHED THE TREASURE, OH NOES!")
            break
        case .None:
            break
        }
        
        if (!(unit.logicComp.current_tile is MazeTile))
        {
            unit.destroy()
        }
    }
    
    func handle_move_opt()
    {
        switch (unit.logicComp.current_tile.moveOpt)
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
        case .Treasure:
            debugPrint("REACHED THE TREASURE, OH NOES!")
            lifeCount = lifeCount - 1
            break
        case .None:
            break
        }
    }
    
    func move_left()
    {
        unit.logicComp.current_pos = int2(unit.logicComp.current_pos.x-1, unit.logicComp.current_pos.y)
        unit.logicComp.current_tile = Tile.getTile(unit.logicComp.tiles, pos: unit.logicComp.current_pos)
        
        handle_move_opt()
    }
    
    func move_right()
    {
        unit.logicComp.current_pos = int2(unit.logicComp.current_pos.x+1, unit.logicComp.current_pos.y)
        unit.logicComp.current_tile = Tile.getTile(unit.logicComp.tiles, pos: unit.logicComp.current_pos)
        
        handle_move_opt()
    }
    
    func move_up()
    {
        unit.logicComp.current_pos = int2(unit.logicComp.current_pos.x, unit.logicComp.current_pos.y+1)
        unit.logicComp.current_tile = Tile.getTile(unit.logicComp.tiles, pos: unit.logicComp.current_pos)
        
        handle_move_opt()
    }
    
    func move_down()
    {
        unit.logicComp.current_pos = int2(unit.logicComp.current_pos.x, unit.logicComp.current_pos.y-1)
        unit.logicComp.current_tile = Tile.getTile(unit.logicComp.tiles, pos: unit.logicComp.current_pos)
        
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
