//
//  GameScene.swift
//  GameApp
//
//  Created by User on 2015-10-21.
//  Copyright (c) 2015 Eric. All rights reserved.
//

import SpriteKit
import SwiftyJSON
import GameKit
import UIKit

class MainMenuScene: SKScene, NetworkableScene
{
    var multiplayer_button: SKSpriteNode!
    
    var all_pigs : Dictionary<Int, SKSpriteNode> = Dictionary<Int, SKSpriteNode>()
    
    enum ZPositions : CGFloat
    {
        case Cloud = 0
        case Pig = 1
        case Button = 2
        case Overlay = 3
        case OverlayButton = 4
    }
    
    var network_inst: NetworkSingleton!
    override func didMoveToView(view: SKView)
    {
        // Don't auto lock screen on time out - this'll disconnect user!
        UIApplication.sharedApplication().idleTimerDisabled = true
        
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
        
        network_inst = NetworkSingleton.getInst(self)
        getPlayerInfo()
        
        add_title()
        init_game_buttons()
        Tile.init_tile_sets()
    }
    
    func add_title()
    {
        let title_node = SKSpriteNode(texture: SKTexture(imageNamed: "TransperentTitle"))
        title_node.xScale = 2
        title_node.yScale = 2
        title_node.name = "title_node"
        title_node.zPosition = ZPositions.Button.rawValue
        
        let title_x = self.frame.width/2
        let title_y = self.frame.height/2 + 140
        title_node.position = CGPointMake(title_x, title_y)
        
        scene!.addChild(title_node)
    }
    
    func init_game_buttons()
    {
        let button_x = self.frame.width/2
        let button_y = self.frame.height/2
        
        multiplayer_button = SKSpriteNode(texture: SKTexture(imageNamed: "multiplayer_button"))
        multiplayer_button.xScale = 2
        multiplayer_button.yScale = 2
        multiplayer_button.name = "multiplayer_button"
        multiplayer_button.zPosition = ZPositions.Button.rawValue
        
        //button_x = self.frame.width/2
        //button_y = self.frame.height/2 - 20.0 - sandbox_button.frame.height
        multiplayer_button.position = CGPointMake(button_x, button_y)
        
        scene!.addChild(multiplayer_button)

    }
    

    
    let MAX_PIGS = 10
    let MAX_TIMER : UInt32 = 5
    
    var timer : NSTimeInterval = 0.0
    var prev_time : NSTimeInterval = 0.0
    override func update(currentTime: NSTimeInterval)
    {
        // Get the delta time
        var delta_time : NSTimeInterval = 0
        if (prev_time == 0)
        {
            prev_time = currentTime
        }
        else
        {
            delta_time = currentTime - prev_time
            prev_time = currentTime
        }
        
        // If any of the pigs is outside of the frame other then the top of it, reset it
        for pig in all_pigs.values
        {
            if ( pig.position.y <= 0 || pig.position.x >= 1100 || pig.position.x <= -50)
            {
                reset_pig(pig)
            }
        }
        
        // Add new pigs over time untill limit is hit. 
        // Use delta time to update a "cooldown" over which pigs aren't spawning, for a cleaner look
        timer = timer - delta_time
        if (all_pigs.count < MAX_PIGS && timer < 0)
        {
            create_a_pig(all_pigs.count)
            timer = NSTimeInterval(arc4random_uniform( MAX_TIMER ) + 1) // Put a random cooldown, of at least 1 second
        }
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
            if name == "multiplayer_button"
            {
                askPlayerSide()
                this_game_mode = GameMode.MULTIPLAYER
            }
            else if name == "attacker_button"
            {
                debugPrint("Player chose to be an attacker!")
                select_role(GameRole.attacker)
                touchedNode.alpha = 0.5

            }
            else if name == "defender_button"
            {
                debugPrint("Player chose to be a defender!")
                select_role(GameRole.defender)
                touchedNode.alpha = 0.5
            }
            else if name == "fill_button"
            {
                debugPrint("Player chose to fill a role!")
                select_role(GameRole.fill)
            }
            else if name == "back_button"
            {
                self.removeChildrenInArray([bg])
            }

        }
    }
    
    var bg: SKShapeNode!
    func askPlayerSide()
    {
        let bg_width = 550
        let bg_height = 185
        let bg_x = Int(self.frame.width/2) - bg_width/2
        let bg_y = Int(self.frame.height/2) - bg_height/2
        let bg_rect = CGRect(x: bg_x, y: bg_y , width: bg_width, height: bg_height)
        bg = SKShapeNode(rect: bg_rect)
        bg.fillColor = UIColor.grayColor().colorWithAlphaComponent(0.8)
        bg.strokeColor = UIColor.blackColor()
        bg.zPosition = ZPositions.OverlayButton.rawValue
        
        let attacker_button = SKSpriteNode(texture: SKTexture(imageNamed: "attacker_button"))
        attacker_button.xScale = 2
        attacker_button.yScale = 2
        attacker_button.name = "attacker_button"
        
        let defender_button = SKSpriteNode(texture: SKTexture(imageNamed: "defender_button"))
        defender_button.xScale = 2
        defender_button.yScale = 2
        defender_button.name = "defender_button"
        
        let back_button = SKSpriteNode(texture: SKTexture(imageNamed: "back_button"))
        back_button.name = "back_button"
        
        attacker_button.position = CGPointMake( CGFloat(bg_x + bg_width/2) - attacker_button.frame.width + 35.0, CGFloat(bg_y + bg_height) - attacker_button.frame.height - 30.0)
        defender_button.position = CGPointMake( CGFloat(bg_x + bg_width/2) + attacker_button.frame.width + 140.0 - defender_button.frame.width, CGFloat(bg_y + bg_height) - defender_button.frame.height - 30.0)

        back_button.position = CGPointMake( CGFloat(bg_x + bg_width/2) - back_button.frame.width  + 47.0, CGFloat(bg_y) + 15.0)
        
        bg.addChild(attacker_button)
        bg.addChild(defender_button)
        bg.addChild(back_button)
        
        self.addChild(bg)
    }
    
    func loadSandboxScene()
    {
        if let scene = GameScene(fileNamed:"GameScene")
        {
            scene.scaleMode = scaleMode
            network_inst.mode = GameMode.SANDBOX
            
            let reveal = SKTransition.fadeWithDuration(1)
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    func loadNextScene()
    {
        if let scene = GameScene(fileNamed:"GameScene")
        {
            scene.scaleMode = scaleMode
            network_inst.mode = GameMode.MULTIPLAYER
            
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
        
        cloud.zPosition = ZPositions.Cloud.rawValue
        
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
    
    func reset_pig( pig : SKSpriteNode )
    {
        var x =  CGFloat(arc4random_uniform( 2 ))
        var x_force : CGFloat = 0.0
        if (x == 0)
        {
            x = -25
            x_force = 250
        }
        else
        {
            x = 1100
            x_force = -250
        }
        let y = CGFloat(arc4random_uniform( 400 )) + 25.0
        let y_force = 400 - y
        
        pig.position = CGPointMake(x, y)
        pig.physicsBody!.velocity = CGVectorMake(0, 0)
        pig.physicsBody!.applyImpulse(CGVectorMake(x_force,y_force))
    }
    
    // Creates a random pig to throw
    func create_a_pig(num : Int)
    {
        let texture : SKTexture
        let move_textures : [SKTexture]
     
        let rand = arc4random_uniform( 30 ) // Better distribution then 0 to 2
        if (rand < 10)
        {
            texture = SKTexture(imageNamed: "dirty_pig_left_0")
            move_textures = [SKTexture(imageNamed: "dirty_pig_left_0"), SKTexture(imageNamed: "dirty_pig_left_1"), SKTexture(imageNamed: "dirty_pig_left_0"), SKTexture(imageNamed: "dirty_pig_left_2")]
        }
        else if (rand < 20)
        {
            texture = SKTexture(imageNamed: "fancy_pig_left_0")
            move_textures = [SKTexture(imageNamed: "fancy_pig_left_0"), SKTexture(imageNamed: "fancy_pig_left_1"), SKTexture(imageNamed: "fancy_pig_left_0"), SKTexture(imageNamed: "fancy_pig_left_2")]
        }
        else
        {
            texture = SKTexture(imageNamed: "hat_pig_left_0")
            move_textures = [SKTexture(imageNamed: "hat_pig_left_0"), SKTexture(imageNamed: "hat_pig_left_1"), SKTexture(imageNamed: "hat_pig_left_0"), SKTexture(imageNamed: "hat_pig_left_2")]
        }
        
        create_dirty_pig(num, texture: texture, move_textures: move_textures)
    }
    
    let MAX_ANIM_SPEED : UInt32 = 2
    func create_dirty_pig(num : Int, texture : SKTexture, move_textures: [SKTexture])
    {
        let pig = SKSpriteNode(texture: texture)
        pig.name = "pig"
        pig.zPosition = ZPositions.Pig.rawValue
        pig.xScale = 3
        pig.yScale = 3
        
        let body = SKPhysicsBody()
        body.dynamic = true
        pig.physicsBody = body;
        
        let speed = NSTimeInterval(arc4random_uniform( MAX_ANIM_SPEED )) + 1.0
        
        let timePerFrame = speed / NSTimeInterval(move_textures.count)
        let spritePlay = SKAction.animateWithTextures(move_textures, timePerFrame: timePerFrame)
        let rotate = SKAction.rotateByAngle(-6.28319, duration: speed)
        
        let group = SKAction.group([spritePlay, rotate])
        let repeat_act = SKAction.repeatActionForever(group)
        
        pig.runAction(repeat_act)
        
        self.addChild(pig)
        all_pigs[num] = pig
    }
    
    // MARK: Network functions
    
    func updateFromNetwork(msg: String)
    {
        debugPrint("Raw message: " + msg)
        
        let data = (msg as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let json = JSON(data: data! )
        let type = json["msgType"].stringValue
        
        debugPrint("Type was " + type)
        
        if (type == msgType.LogIn.rawValue)
        {
            let logIn = LogInMsg(role: json["role"].stringValue)
            network_inst.update_role(logIn.role)
            loadNextScene()
        }
    }
    
    func select_role(role: GameRole)
    {
        let log_in_req = LogInRequestMsg(role: role, username: self.alias, uniqueId: self.player_id)
        
        network_inst.update_role(role)
        writeToNet(log_in_req)
    }
    
    func writeToNet(msg: NetMessage)
    {
        network_inst.writeToNet(msg)
    }
    
    // MARK: EGC functions
    var alias = ""
    var player_id = ""
    let use_game_center = false
    
    func getPlayerInfo()
    {
        if (use_game_center)
        {
            let localPlayer = GKLocalPlayer.localPlayer()
            
            localPlayer.authenticateHandler =
                {
                    (viewController, error) -> Void in
                    if (viewController != nil)
                    {
                        self.view!.window?.rootViewController?.presentViewController(viewController!, animated: true, completion: nil)
                    }
                    else
                    {
                        debugPrint((GKLocalPlayer().authenticated))
                        
                        self.alias = localPlayer.alias!
                        self.player_id = localPlayer.playerID!
                        
                        debugPrint("Local player name: \(self.alias)")
                        debugPrint("Player id: \(self.player_id)")
                    }
            }
        }
        else
        {
            let num = arc4random_uniform(1000000)
            self.alias = "simulator_\(num)"
            self.player_id = "simulator_id_\(num)"
            
            debugPrint("Local player name: \(self.alias)")
            debugPrint("Player id: \(self.player_id)")
        }
        

    }
    
}
