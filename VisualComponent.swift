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
        node.zPosition = GameScene.ZPosition.MazeUnit.rawValue
        node.size = CGSize(width: size.x*Tile.tileWidth, height: size.y*Tile.tileHeight)
        node.anchorPoint = CGPointMake(0.00, 0.00)
        node.position = world_position
        node.name = String(parent_entity.entity_id)
            
        scene.addChild(node)
    }
}
