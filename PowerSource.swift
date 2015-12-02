//
//  Spawner.swift
//  GameApp
//
//  Created by Roger Sun on 2015-12-01.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class PowerSource: Building
{
    var mazeTiles : [Tile] = [Tile]()
    
    static var power_source_range = CGPointMake(9,9)
    
    override init(scene: GameScene, grid_position: int2, world_position: CGPoint, tower_texture: SKTexture, gridSize: int2, visSize: CGPoint, buildingCost: Int, temp: Bool = false)
    {
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, buildingCost: buildingCost, temp: temp)
        
    }
    
    static var tilesWithPowerSource : [Tile] = []
    static var shapes : [SKShapeNode] = [SKShapeNode]()
    
    static func visualizePowerSourceArea(scene : GameScene, show_shapes : Bool)
    {
        if (!show_shapes)
        {
            for shape in shapes
            {
                scene.removeChildrenInArray([shape])
            }
        }
        else
        {
            for tile in tilesWithPowerSource
            {
                let pos = tile.position
                let size = power_source_range.x * 2.0 + 2.0
                let shape = SKShapeNode(rectOfSize: CGSize(width: (size) * Tile.tileWidth , height: (size) * Tile.tileHeight ))
                
                shape.position = CGPointMake( ( CGFloat(pos.x) + 1 ) * Tile.tileWidth ,
                    CGFloat( (CGFloat(scene.map_height) ) - CGFloat(pos.y) ) * Tile.tileHeight )
                
                shape.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
                shape.strokeColor = UIColor.clearColor()
                shape.zPosition = GameScene.ZPosition.Tower.rawValue - 0.1
                scene.addChild(shape)
                
                shapes.append(shape)
            }
        }
    }
    
    override func update(delta: NSTimeInterval)
    {
        
    }
}
