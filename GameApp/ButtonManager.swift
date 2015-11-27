//
//  ButtonManager.swift
//  GameApp
//
//  Created by User on 2015-11-25.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

public class ButtonManager
{
    static func reset_button(scene: SKScene, button: SKSpriteNode)
    {
        scene.removeChildrenInArray([button])
        button.removeAllActions()
    }
    
    static func init_button(camera: SKCameraNode, img_name: String, button_name: String, index: Int) -> SKSpriteNode
    {
        let button = SKSpriteNode(texture: SKTexture(imageNamed: img_name))
        button.name = button_name
        button.size = CGSize(width: 64*3 ,height: 64*3)
        button.position = CGPointMake(CGFloat(-850 + 200 * index) , -1250)
        button.zPosition = 3
        
        camera.addChild(button)
        
        return button
    }

}