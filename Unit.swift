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
    var hp : Int = 0
    
    var movementComp: MovementComponent!
    var visualComp: VisualComponent!
    var gridComp: GridComponent!
    
    static let MAX_GOLD = 500
    var unit_worth = 50
    
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
        self.hp -= ammo.damage
        
        if (ammo is FireBall)
        {
            let size = CGSize(width: 2.0 * Tile.tileWidth ,height: 2.0 * Tile.tileHeight)
            let animation = Animation(scene: scene, textures: FireBall.FireBallTexture, speed: 0.5, visSize: size , worldPos: ammo.visualComp.node.position)
            animation.run()
        }
        
        if (ammo is IceBolt)
        {
            let size = CGSize(width: 2.3 * Tile.tileWidth ,height: 2.3 * Tile.tileHeight)
            let animation = Animation(scene: scene, textures: IceBolt.IceBoltTexture, speed: 0.5, visSize: size , worldPos: ammo.visualComp.node.position)
            animation.run()
        }
        
        if (self.hp <= 0)
        {
            if (self is Orc)
            {
                let size = CGSize(width: Tile.tileWidth,height: Tile.tileHeight)
                let animation = Animation(scene: scene, textures: Orc.orcDeath, speed: 0.8, visSize: size , worldPos: ammo.visualComp.node.position, death_anim: true)
                animation.run()
            }
            
            else if (self is Troll)
            {
                let size = CGSize(width: 1.6 * Tile.tileWidth, height: 1.6 * Tile.tileHeight)
                let animation = Animation(scene: scene, textures: Troll.trollDeath, speed: 0.8, visSize: size , worldPos: ammo.visualComp.node.position, death_anim: true)
                animation.run()
            }
            
            else if (self is Goblin)
            {
                let size = CGSize(width: 1.2 * Tile.tileWidth,height: 1.2 * Tile.tileHeight)
                let animation = Animation(scene: scene, textures: Goblin.goblinDeath, speed: 0.8, visSize: size , worldPos: ammo.visualComp.node.position, death_anim: true)
                animation.run()
            }
            
            // Kill unit!
            attackerGoldCount += self.unit_worth
            defenderGoldCount += Unit.MAX_GOLD - self.unit_worth
            self.destroy()
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
    
    func destroy()
    {
        scene.removeChildrenInArray([self.visualComp.node])
        scene.all_units.removeValueForKey(self.entity_id)
        self.visualComp.node.removeAllActions()
    }
}