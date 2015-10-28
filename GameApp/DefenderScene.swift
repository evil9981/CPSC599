//
//  DefenderScene.swift
//  GameApp
//
//  Created by User on 2015-10-21.
//  Copyright © 2015 Eric. All rights reserved.
//

import Foundation
import SpriteKit

class DefenderScene: SKScene
{
    override func didMoveToView(view: SKView)
    {
        backgroundColor = SKColor.greenColor()
        
        let myLabel = SKLabelNode(fontNamed: "Chalkduster")
        myLabel.text = "Defender Side"
        myLabel.fontSize = 70
        myLabel.fontColor = SKColor.blueColor()
        
        myLabel.position = CGPoint(x: frame.width/2, y: frame.height/2)
        
        addChild(myLabel)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let touchPoint = touch.locationInView(self.view)
            let scenePoint = scene!.convertPointFromView(touchPoint)
            let touchedNode = self.nodeAtPoint(scenePoint)
            
            if let name = touchedNode.name
            {
                if name == "ToAttacker"
                {
                    loadAttackerScene()
                }
            }
        }
    }
    
    func loadAttackerScene()
    {
        if let scene = AttackerScene(fileNamed:"AttackerScene")
        {
            scene.scaleMode = scaleMode
            
            let reveal = SKTransition.fadeWithDuration(1)
            self.view?.presentScene(scene, transition: reveal)
        }
    }
}