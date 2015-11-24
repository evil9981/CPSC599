//
//  GameScene.swift
//  GameApp
//
//  Created by User on 2015-10-21.
//  Copyright (c) 2015 Eric. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene
{
    override func didMoveToView(view: SKView)
    {
        let rgbValue = 0xADD8E6
        let r = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
        let g = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
        let b = CGFloat((rgbValue & 0xFF))/255.0
        self.backgroundColor = UIColor(red:r, green: g, blue: b, alpha: 1.0)
        
        for cloud_counter in 1 ... 50
        {
            if cloud_counter < 10
            {
                create_cloud( 0 )
            }
            else
            {
                create_cloud( 3 )
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let touch = touches.first!
        let touchPoint = touch.locationInView(self.view)
        let scenePoint = scene!.convertPointFromView(touchPoint)
        let touchedNode = self.nodeAtPoint(scenePoint)
        
        if let name = touchedNode.name
        {
            if name == "sandbox_button"
            {
                loadNextScene()
            }
            else if name == "multiplayer_button"
            {
                debugPrint("Multiplayer is not active yet!")
            }
        }
    }
    
    func loadNextScene()
    {
        if let scene = GameScene(fileNamed:"GameScene")
        {
            scene.scaleMode = scaleMode
            
            let reveal = SKTransition.fadeWithDuration(1)
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    func create_cloud(wait_time : NSTimeInterval)
    {
        let cloud = SKSpriteNode(texture: SKTexture(imageNamed: "cloud"))
        cloud.name = "cloud"
        
        let random_scale = CGFloat( arc4random_uniform( 2 ) ) + 2
        cloud.xScale = random_scale
        cloud.yScale = random_scale
        
        let random_height = CGFloat( arc4random_uniform( UInt32(self.frame.height - cloud.frame.height) )) + (cloud.frame.height )
        cloud.position = CGPointMake(self.frame.width + cloud.frame.width, self.frame.height - cloud.frame.height - random_height)
        
        let random_speed = NSTimeInterval(arc4random_uniform(5) + 2)
        let move_action = SKAction.moveByX(-(self.frame.width + 2*cloud.frame.width), y: 0, duration: random_speed)
        let wait = SKAction.waitForDuration(wait_time, withRange: wait_time + 1.0)
        
        let seq = SKAction.sequence([wait, move_action])
        cloud.runAction(seq, completion: {
                self.removeChildrenInArray([cloud])
                self.create_cloud(3)
            })
        
        self.addChild(cloud)
    }
}
