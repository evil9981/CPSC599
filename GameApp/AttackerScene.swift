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
        sceneCamera.position = CGPointMake(frame.width/2, frame.height/2)
        sceneCamera.xScale = 0.5
        sceneCamera.yScale = 0.5
        self.addChild(sceneCamera)
        
        //let texture = SKTexture(imageNamed: "defender_side_arrow")
        //let node = SKSpriteNode(texture: texture)
        //node.position = CGPointMake(800, -200)
        //node.xScale = 3
        //node.yScale = 3
        
        //let moveLeft = SKAction(named: "moveLeft")
        //node.runAction(SKAction.repeatAction(moveLeft!, count: 10))
        //self.addChild(node)
        //sceneCamera.addChild(node)
        
        let camera_viewport_width = frame.width * sceneCamera.xScale
        let camera_viewport_height = frame.height * sceneCamera.yScale
        
        let camera_half_width = (camera_viewport_width / 2 )
        let camera_half_height = (camera_viewport_height / 2 )

        
        max_x = frame.width - camera_half_width
        min_x = 0
        
        max_y = frame.height - camera_half_height
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
    
    var map_height : Int = -1
    var map_width : Int = -1
    func getJSONFile()
    {
        let filePath = NSBundle.mainBundle().pathForResource("TowerMap", ofType: "json")
        
        do
        {
            let text = try NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)
            
            let parsedText = try NSJSONSerialization.JSONObjectWithData(text.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
            
            if let jsonContent = parsedText as? NSDictionary
            {
                map_height = jsonContent["height"] as! Int
                map_width = jsonContent["width"] as! Int
                
                //debugPrint("Map dimensions: \(map_height) x \(map_width)")
                let layers = jsonContent["layers"] as! NSArray
                let bottom_layer = layers[0] as! NSDictionary
                let bottom_layer_data = bottom_layer["data"] as! NSArray
                
                debugPrint(bottom_layer_data[0])
                
            }
        }
        catch
        {
            debugPrint("Error reading JSON file")
        }
    }
}