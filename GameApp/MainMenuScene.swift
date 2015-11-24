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
    var sandbox_button: SKSpriteNode!
    var multiplayer_button: SKSpriteNode!
    
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
        
        sandbox_button = SKSpriteNode(texture: SKTexture(imageNamed: "sandbox_button"))
        sandbox_button.xScale = 2
        sandbox_button.yScale = 2
        sandbox_button.name = "sandbox_button"
        sandbox_button.zPosition = 4

        var button_x = self.frame.width/2
        var button_y = self.frame.height/2
        sandbox_button.position = CGPointMake(button_x, button_y)
        
        scene!.addChild(sandbox_button)
        
        multiplayer_button = SKSpriteNode(texture: SKTexture(imageNamed: "multiplayer_button"))
        multiplayer_button.xScale = 2
        multiplayer_button.yScale = 2
        multiplayer_button.name = "multiplayer_button"
        multiplayer_button.zPosition = 4
        
        button_x = self.frame.width/2
        button_y = self.frame.height/2 - 20.0 - sandbox_button.frame.height
        multiplayer_button.position = CGPointMake(button_x, button_y)
        
        scene!.addChild(multiplayer_button)
    }
    
    enum PlayerSide
    {
        case ATTACKER
        case DEFENDER
    }
    enum GameMode
    {
        case MULTIPLAYER
        case SANDBOX
    }
    var this_game_mode: GameMode = .SANDBOX
    

    
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
                //askPlayerSide()
                //this_game_mode = GameMode.SANDBOX
                loadNextScene()
            }
            else if name == "multiplayer_button"
            {
                askPlayerSide()
                this_game_mode = GameMode.MULTIPLAYER
            }
            else if name == "attacker_button"
            {
                debugPrint("Player chose to be an attacker!")
            }
            else if name == "defender_button"
            {
                debugPrint("Player chose to be a defender!")
            }
            else if name == "back_button"
            {
                self.removeChildrenInArray([bg])
                self.addChild(sandbox_button)
                self.addChild(multiplayer_button)
            }

        }
    }
    
    var bg: SKShapeNode!
    func askPlayerSide()
    {
        scene!.removeChildrenInArray([sandbox_button, multiplayer_button])
        
        let bg_width = 400
        let bg_height = 150
        let bg_x = Int(self.frame.width/2) - bg_width/2
        let bg_y = Int(self.frame.height/2) - bg_height/2
        let bg_rect = CGRect(x: bg_x, y: bg_y , width: bg_width, height: bg_height)
        bg = SKShapeNode(rect: bg_rect)
        bg.fillColor = UIColor.grayColor().colorWithAlphaComponent(0.8)
        bg.strokeColor = UIColor.blackColor()
        bg.zPosition = 5
        
        let attacker_button = SKSpriteNode(texture: SKTexture(imageNamed: "attacker_button"))
        attacker_button.name = "attacker_button"
        
        let defender_button = SKSpriteNode(texture: SKTexture(imageNamed: "defender_button"))
        defender_button.name = "defender_button"
        
        let back_button = SKSpriteNode(texture: SKTexture(imageNamed: "back_button"))
        back_button.name = "back_button"
        
        attacker_button.position = CGPointMake( CGFloat(bg_x + bg_width/2) - attacker_button.frame.width, CGFloat(bg_y + bg_height) - attacker_button.frame.height - 6.0)
        defender_button.position = CGPointMake( CGFloat(bg_x + bg_width/2) + attacker_button.frame.width + 70.0 - defender_button.frame.width, CGFloat(bg_y + bg_height) - defender_button.frame.height - 6.0)

        back_button.position = CGPointMake( CGFloat(bg_x + bg_width/2) - back_button.frame.width  + 47.0, CGFloat(bg_y) + 15.0)
        
        bg.addChild(attacker_button)
        bg.addChild(defender_button)
        bg.addChild(back_button)
        
        self.addChild(bg)
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
