//
//  Animation.swift
//  GameApp
//
//  Created by User on 2015-12-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class Animation: GameEntity
{
    var scene: GameScene
    var node: SKSpriteNode
    var sprite_player: SKAction
    init(scene: GameScene, textures: [SKTexture], speed: CGFloat, visSize: CGSize, worldPos: CGPoint)
    {
        self.scene = scene
        self.node = SKSpriteNode(texture: textures[0], size: visSize)
        self.node.position = worldPos
        self.node.zPosition = GameScene.ZPosition.Overlay.rawValue
        
        let fps = NSTimeInterval( speed / CGFloat(textures.count) )
        self.sprite_player = SKAction.animateWithTextures(textures, timePerFrame: fps )
        
        super.init()
        
        scene.addChild(node)
        
    }
    
    func run()
    {
        self.node.runAction(sprite_player, completion: { self.destroy() })
    }
    
    func destroy()
    {
        scene.removeChildrenInArray([node])
    }
}