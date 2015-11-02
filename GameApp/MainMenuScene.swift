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
        backgroundColor = SKColor.redColor()
        
        let myLabel = SKLabelNode(fontNamed: "Chalkduster")
        myLabel.text = "Tap to start"
        myLabel.fontSize = 70
        myLabel.position = CGPoint(x: frame.width/2, y: frame.height/2)
        
        addChild(myLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if let scene = GameScene(fileNamed:"GameScene")
        {
            scene.scaleMode = scaleMode
            
            let reveal = SKTransition.fadeWithDuration(1)
            self.view?.presentScene(scene, transition: reveal)
        }
    }
   
}
