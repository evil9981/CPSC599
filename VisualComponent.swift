//
//  VisualComponent.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import GameplayKit
import SpriteKit

class VisualComponent: GKComponent
{
    var parent_entity: GameEntity
    var scene: GameScene
    var node: SKSpriteNode
    var size: CGPoint
    
    init(scene: GameScene, parent_entity: GameEntity, texture: SKTexture, world_position: CGPoint, size: CGPoint)
    {
        self.scene = scene
        self.parent_entity = parent_entity
        self.size = size
        
        self.node = SKSpriteNode(texture: texture)
        node.zPosition = GameScene.ZPosition.MazeUnit.rawValue + CGFloat(parent_entity.entity_id / 100000)
        node.size = CGSize(width: size.x*Tile.tileWidth, height: size.y*Tile.tileHeight)
        node.anchorPoint = CGPointMake(0.0 , 0.0)
        if (parent_entity is Building)
        {
            node.position = CGPointMake(world_position.x - (0.3 * Tile.tileWidth), world_position.y - (0.3 * Tile.tileHeight))
        }
        else
        {
            node.position = CGPointMake( world_position.x , world_position.y )
        }
        node.name = String(parent_entity.entity_id)
            
        scene.addChild(node)
    }
}
