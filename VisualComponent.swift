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
    var scene: GameScene!
    var node: SKSpriteNode!
    var world_position: CGPoint!
    
    init(scene: GameScene, texture: SKTexture, world_position: CGPoint)
    {
        self.scene = scene
        
        self.node = SKSpriteNode(texture: texture)
        node.zPosition = 1
        node.size = CGSize(width: Tile.tileWidth-8, height: Tile.tileHeight - 8)
        node.anchorPoint = CGPointMake(0.05, 0.05)
        node.position = world_position
         
        scene.addChild(node)
    }
}
