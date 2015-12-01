//
//  Tower.swift
//  GameApp
//
//  Created by User on 2015-11-03.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class Tower: Building
{
    var towerComp: TowerShootComponent!
    var mazeTiles : [Tile] = [Tile]()
    
    var towerDamage: Int
    var towerShootingSpeed: NSTimeInterval
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, tower_texture: SKTexture, gridSize: int2, visSize: CGPoint, range: int2, towerDamage: Int, towerShootingSpeed: NSTimeInterval, towerCost: Int, temp: Bool = false)
    {
        self.towerDamage = towerDamage
        self.towerShootingSpeed = towerShootingSpeed
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, buildingCost: towerCost, temp: temp)
        
        if (!temp)
        {
            self.towerComp = TowerShootComponent(tower: self, range: range, towerDamage: towerDamage)
            self.addComponent(towerComp)
        }
    }
    
    var shapes : [SKShapeNode] = [SKShapeNode]()
    var shapes_shown : Bool = false
    
    func visualizeMazeTiles()
    {
        // First time we're visualizing a tower's attack tiles
        if (shapes.count == 0)
        {
            for tile in mazeTiles
            {
                let pos = tile.position
                
                let shape = SKShapeNode(rectOfSize: CGSize(width: Tile.tileWidth , height: Tile.tileHeight ))
                
                shape.position = CGPointMake( ( CGFloat(pos.x) ) * Tile.tileWidth ,
                    CGFloat( (CGFloat(scene.map_height) ) - CGFloat(pos.y) ) * Tile.tileHeight )
                
                shape.fillColor = UIColor.redColor().colorWithAlphaComponent(0.2)
                shape.strokeColor = UIColor.clearColor()
                shape.zPosition = GameScene.ZPosition.Tower.rawValue - 0.1
                self.scene.addChild(shape)
                
                shapes_shown = true
                shapes.append(shape)
            }
        }
        // Every next time we toggle
        else
        {
            if (shapes_shown)
            {
                for shape in shapes
                {
                    self.scene.removeChildrenInArray([shape])
                }
                shapes_shown = false
            }
            else
            {
                for shape in shapes
                {
                    self.scene.addChild(shape)
                }
                shapes_shown = true
            }
        }
    }
    
    override func update(delta: NSTimeInterval)
    {
        towerComp.update(delta)
    }
}
