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
    
    init(scene: GameScene, textures: [SKTexture], speed: NSTimeInterval, visSize: CGSize, worldPos: CGPoint)
    {
        self.scene = scene
        self.node = SKSpriteNode(texture: textures[0], size: visSize)
        
        super.init()
        
        scene.addChild(node)
        let spritePlay = SKAction.animateWithTextures(textures, timePerFrame: speed)
        
        self.node.runAction(spritePlay, completion: { self.destroy() })
    }
    
    func destroy()
    {
        scene.removeChildrenInArray([node])
    }
}