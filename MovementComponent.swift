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
    var unit: Unit!
    
    public var moveLeft: SKAction!
    public var moveRight: SKAction!
    public var moveUp: SKAction!
    public var moveDown: SKAction!

    var current_movement: SKAction!
    var is_moving: Bool = false
    
    init(unit:Unit, leftTextures: [SKTexture] , rightTextures: [SKTexture], upTextures: [SKTexture] ,downTextures: [SKTexture], speed: NSTimeInterval)
    {
        super.init()
        
        self.unit = unit;
        self.updateActions(leftTextures, rightTextures: rightTextures, upTextures: upTextures, downTextures: downTextures, speed: speed)
        
        current_movement = moveRight
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
