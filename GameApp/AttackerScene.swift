//
//  AttackScene.swift
//  GameApp
//  Created by User on 2015-10-21.
//  Copyright © 2015 Eric. All rights reserved.
//

import Foundation
import SpriteKit

class AttackerScene: SKScene
{
    var sceneCamera : SKCameraNode = SKCameraNode()
    
    var max_x : CGFloat = 0.0
    var min_x : CGFloat = 0.0
    var max_y : CGFloat = 0.0
    var min_y : CGFloat = 0.0
    
    override func didMoveToView(view: SKView)
    {
        backgroundColor = SKColor.greenColor()
        
        let myLabel = SKLabelNode(fontNamed: "Chalkduster")
        myLabel.text = "Attacker side"
        myLabel.fontSize = 70
        myLabel.fontColor = SKColor.blackColor()
        
        myLabel.position = CGPoint(x: frame.width/2, y: frame.height/2)
        
        addChild(myLabel)
        
        sceneCamera.position = CGPointMake(scene!.frame.width/2, scene!.frame.height/2)
        sceneCamera.xScale = 0.5
        sceneCamera.yScale = 0.5
        self.addChild(sceneCamera)
        
        let texture = SKTexture(imageNamed: "defender_side_arrow")
        let node = SKSpriteNode(texture: texture)
        node.position = CGPointMake(800, -200)
        node.xScale = 3
        node.yScale = 3
        
        //let moveLeft = SKAction(named: "moveLeft")
        //node.runAction(SKAction.repeatAction(moveLeft!, count: 10))
        //self.addChild(node)
        sceneCamera.addChild(node)
        
        let camera_viewport_width = self.scene!.frame.width * sceneCamera.xScale
        let camera_viewport_height = self.scene!.frame.height * sceneCamera.yScale
        
        let camera_half_width = (camera_viewport_width / 2 )
        let camera_half_height = (camera_viewport_height / 2 )

        
        max_x = scene!.frame.width - camera_half_width
        min_x = 0 + camera_half_width
        
        max_y = scene!.frame.height - camera_half_height
        min_y = 0 + camera_half_height
        
        self.camera = sceneCamera;
        getJSONFile()
        
    }
    
    var prevLocation: CGPoint = CGPointMake(0, 0)
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let touchPoint = touch.locationInView(self.view)
            let scenePoint = scene!.convertPointFromView(touchPoint)
            let touchedNode = self.nodeAtPoint(scenePoint)
            
            prevLocation = touchPoint
            
            if let name = touchedNode.name
            {
                if name == "ToDefender"
                {
                    debugPrint("Button clicked")
                }
            }
            else
            {
                debugPrint("\(touchPoint.x) \(touchPoint.y)")
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let currentLocation = touch.locationInView(self.view)
            
            let dx = currentLocation.x - prevLocation.x
            let dy = currentLocation.y - prevLocation.y

            prevLocation = currentLocation

            var new_x = sceneCamera.position.x - dx * 2.5
            var new_y = sceneCamera.position.y + dy*2.5
            
            if new_x > max_x
            {
                new_x = max_x
            }
            else if new_x < min_x
            {
                new_x = min_x
            }
            
            if new_y > max_y
            {
                new_y = max_y
            }
            else if new_y < min_y
            {
                new_y = min_y
            }
            
            sceneCamera.position = CGPointMake( new_x, new_y )
            
        }
    }
    
    func getJSONFile()
    {
        let filePath = NSBundle.mainBundle().pathForResource("TowerMap", ofType: "json")
        
        do
        {
            let text = try NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)
            
            let parsedText = try NSJSONSerialization.JSONObjectWithData(text.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
            
            if let jsonContent = parsedText as? NSDictionary
            {
                if let height = jsonContent["height"]
                {
                    debugPrint(height)
                }
            }
        }
        catch
        {
            debugPrint("Error reading JSON file")
        }
    }
}