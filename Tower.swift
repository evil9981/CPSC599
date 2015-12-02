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
    
    static var show_shapes : Bool = false
    static var mazeTiles : [Tile] = [Tile]()
    static var shapes : [SKShapeNode] = [SKShapeNode]()
    
    static func visualizeMazeTiles(scene: GameScene)
    {
        Tower.show_shapes = !Tower.show_shapes
        if (!Tower.show_shapes)
        {
            for shape in shapes
            {
                scene.removeChildrenInArray([shape])
            }
        }
        else
        {
            for tile in mazeTiles
            {
                let pos = tile.position
                let shape = SKShapeNode(rectOfSize: CGSize(width: (8.0) * Tile.tileWidth , height: (8.0) * Tile.tileHeight ))
                
                shape.position = CGPointMake( ( CGFloat(pos.x) + 1 ) * Tile.tileWidth ,
                    CGFloat( (CGFloat(scene.map_height) ) - CGFloat(pos.y) ) * Tile.tileHeight )
                
                shape.fillColor = UIColor.redColor().colorWithAlphaComponent(0.15)
                shape.strokeColor = UIColor.clearColor()
                shape.zPosition = GameScene.ZPosition.Tower.rawValue - 0.1
                scene.addChild(shape)
                
                shapes.append(shape)
            }
        }
    }
    
    override func update(delta: NSTimeInterval)
    {
        towerComp.update(delta)
    }
}
