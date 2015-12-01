//
//  AttackScene.swift
//  GameApp
//  Created by User on 2015-10-21.
//  Copyright © 2015 Eric. All rights reserved.
//

import Foundation
import SpriteKit
import Alamofire
import SwiftyJSON

var lifeCount : Int = 3
var goldCount : Int = 500
var gameOver : Bool = false

class GameScene: SKScene
{
    var sceneCamera : SKCameraNode = SKCameraNode()
    
    var max_x : CGFloat = 0.0
    var min_x : CGFloat = 0.0
    var max_y : CGFloat = 0.0
    var min_y : CGFloat = 0.0
    
    var all_pigs : Dictionary<Int, Pig> = Dictionary<Int, Pig>()
    var all_units : Dictionary<Int, Unit> = Dictionary<Int, Unit>()
    var all_buildings : Dictionary<Int, Building> = Dictionary<Int, Building>()
    
    var gameStartTime : Int = 0
    var prevGameTimeEplased : Int = 0
    var totalGameTime : Int = 600
    var currentGameTime : Int = 0
    var gameTimeElapsed : Int = 0
    var tempCount : Int = 0
    
    var startTimer : Bool = true
    
    var goldImageTexture : SKTexture!
    var coinImageTexture : SKTexture!
    var attackImageTexture : SKTexture!
    var livesImageTexture : SKTexture!
    var goldImage : SKSpriteNode!
    var livesImage : SKSpriteNode!
    
    var goldLabel : SKLabelNode!
    var livesLabel : SKLabelNode!
    var timeLabel : SKLabelNode!
    var endGameLabel : SKLabelNode!
    
    // Side panel stuff
    var buyButton : SKSpriteNode!
    var sidePanel: SKShapeNode!
    
    var tileNums : [[Int]]!
    var tiles : [[Tile]]!
    
    let debug = true
    
    // MARK: Placeholder stuff, used to support demo
    
    enum BuildMode : Int
    {
        case Orc = 0
        case BasicTower = 1
        case AdvancedTower = 2
        case RegularTower = 3
        case FireTower = 4
        case IceTower = 5
        case DefenderPowerSource = 6
        case DirtyPig = 7
        case HatPig = 8
        case FancyPig = 9
    }
    var current_build_mode : BuildMode!
    
    var buttons: [Int:SKSpriteNode] = [:]
    
    enum ZPosition : CGFloat
    {
        case Map = 0
        case MazeUnit = 1
        case Tower = 2
        case GUI = 3
        case Overlay = 4
        case OverlayButton = 5
    }
    
    // MARK: Moved to view (initializer)
    
    var camera_viewport_width : CGFloat = 0
    var camera_viewport_height : CGFloat = 0
    
    override func didMoveToView(view: SKView)
    {
        // Example of how to send a request.
        //send_request("/")
        
        // Initiate the camera and viewport sizes
        init_camera()
        
        // Get the logic parsed from the JSON file
        getJSONFile()
        
        // Initiate all the GUI elementes
        init_GUI()
    }
    
    // Initiates the scene's camera
    func init_camera()
    {
        sceneCamera.position = CGPointMake(frame.width/2, frame.height/2)
        self.addChild(sceneCamera)
        
        sceneCamera.xScale = 0.5
        sceneCamera.yScale = 0.5
        
        camera_viewport_width = frame.width * sceneCamera.xScale
        camera_viewport_height = frame.height * sceneCamera.yScale
        
        let camera_half_width = (camera_viewport_width / 2 )
        let camera_half_height = (camera_viewport_height / 2 )
        
        max_x = frame.width - camera_half_width
        min_x = 2.5 * Tile.tileWidth
        
        max_y = frame.height - camera_half_height + 15
        min_y = 0 + camera_half_height
        
        self.camera = sceneCamera;
    }
    
    // Initiates the GUI labels
    func init_GUI()
    {
        // Add the 'Gold Label' to the camera view and place it in the top left corner
        goldLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        goldLabel.text = String(goldCount)
        goldLabel.fontSize = 150
        goldLabel.fontColor = UIColor(red: 248/255, green: 200/255, blue: 0, alpha: 1)
        goldLabel.position = CGPointMake(500, 500)
        goldLabel.zPosition = ZPosition.GUI.rawValue
        sceneCamera.addChild(goldLabel)
        
        // Add the 'Lives Label' to the camera view and place it in the top right corner
        livesLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        livesLabel.text = String(lifeCount)
        livesLabel.fontSize = 150
        livesLabel.fontColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        livesLabel.position = CGPointMake(0, 0)
        livesLabel.zPosition = ZPosition.GUI.rawValue
        sceneCamera.addChild(livesLabel)
        
        // Add the 'Time Label' to the camera view and place it in the middle
        timeLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        timeLabel.fontSize = 150
        timeLabel.fontColor = UIColor.whiteColor()
        timeLabel.position = CGPointMake(0, 0)
        timeLabel.zPosition = ZPosition.GUI.rawValue
        sceneCamera.addChild(timeLabel)
        
        // Add the gold image texture
        goldImageTexture = SKTexture(imageNamed: "GoldImage")
        goldImage = SKSpriteNode(texture: goldImageTexture)
        goldImage.position = CGPointMake(100, 200)
        goldImage.xScale = 8
        goldImage.yScale = 8
        goldImage.zPosition = ZPosition.GUI.rawValue
        sceneCamera.addChild(goldImage)
        
        // Add the lives image texture
        livesImageTexture = SKTexture(imageNamed: "LivesImage")
        livesImage = SKSpriteNode(texture: livesImageTexture)
        livesImage.position = CGPointMake(0, 0)
        livesImage.xScale = 8
        livesImage.yScale = 8
        livesImage.zPosition = ZPosition.GUI.rawValue
        sceneCamera.addChild(livesImage)
        
        // Init the orc and tower buttons
        init_buttons()
        init_buy_panel()
    }
    
    let buy_panel_width : CGFloat = 600 // This is how wide the buy panel is
    func init_buy_panel()
    {
        let frame = CGRect(x: camera_viewport_width, y: (-camera_viewport_height), width: buy_panel_width, height: camera_viewport_height*2) // Use the camera_viewport that is calculated at the start to determine how big the frame is
        sidePanel = SKShapeNode(rect: frame) // Create a SKShapeNode from the frame
        sidePanel.zPosition = ZPosition.Overlay.rawValue
            
        sidePanel.fillColor = UIColor.blackColor().colorWithAlphaComponent(0.5) // This is the fill color, 0.5 is transperency
        sidePanel.strokeColor = UIColor.blackColor() // This is the border color
        
        //var goldCostLabel: SKLabelNode!
        //var goldCostImage: SKSpriteNode!
        
        /*
        // Add basicTower Buy button
        let basicTower = SKSpriteNode(texture: SKTexture(imageNamed: "BasicTower"), size: CGSize(width: 400 ,height: 400))
        var x_buy_button = camera_viewport_width + basicTower.frame.width - 150
        var y_buy_button = camera_viewport_height - basicTower.frame.height - 50
        
        basicTower.position = CGPointMake(x_buy_button, y_buy_button)
        basicTower.zPosition = ZPosition.OverlayButton.rawValue
        basicTower.name = "BuyBasicTower"
        
        // Create cost image
        createLableNode(goldCostLabel, labelFont: "Arial-BoldMT", labelText: basicTowerCost, labelColour: "Gold", labelFontSize: 100, xPosition: x_buy_button + 25, yPosition: y_buy_button - 300, zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create gold label
        createNode(goldCostImage, uiTexture: goldImageTexture, scaleX: 3.5, scaleY: 3.5, xPosition: x_buy_button - 150, yPosition: y_buy_button - 260, nodeName: "GoldImage", zPosition: "OverlayButton", childOf: "SidePanel")
        */

        // Add regularTower Buy button
        let regularTower = SKSpriteNode(texture: SKTexture(imageNamed: "RegularTower"), size: CGSize(width: 400 ,height: 400))
        var x_buy_button = camera_viewport_width + regularTower.frame.width - 275
        var y_buy_button = camera_viewport_height - regularTower.frame.height - 50
        
        regularTower.position = CGPointMake(x_buy_button, y_buy_button)
        regularTower.zPosition = ZPosition.OverlayButton.rawValue
        regularTower.name = "BuyRegularTower"
        
        // Create gold image
        coinImageTexture = SKTexture(imageNamed: "CoinImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 150, yPosition: y_buy_button + 100, nodeName: "CoinImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: regularTowerCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 250, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create attack image
        attackImageTexture = SKTexture(imageNamed: "AttackValueImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 150, yPosition: y_buy_button, nodeName: "AttackValueImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: regularTowerDamage, labelColour: "White", labelFontSize: 75, xPosition: x_buy_button + 250, yPosition: y_buy_button - 25, zPosition: "OverlayButton", childOf: "SidePanel")
        
        
        
        // Add fireTower buy button
        let fireTower = SKSpriteNode(texture: SKTexture(imageNamed: "FireTower"), size: CGSize(width: 400 ,height: 400))
        x_buy_button = camera_viewport_width + regularTower.frame.width - 275
        y_buy_button = camera_viewport_height - regularTower.frame.height - 500
        
        fireTower.position = CGPointMake(x_buy_button, y_buy_button)
        fireTower.zPosition = ZPosition.OverlayButton.rawValue
        fireTower.name = "BuyFireTower"
        
        // Create gold image
        coinImageTexture = SKTexture(imageNamed: "CoinImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 150, yPosition: y_buy_button + 100, nodeName: "CoinImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: fireTowerCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 255, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create attack image
        attackImageTexture = SKTexture(imageNamed: "AttackValueImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 150, yPosition: y_buy_button, nodeName: "AttackValueImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: fireTowerDamage, labelColour: "White", labelFontSize: 75, xPosition: x_buy_button + 250, yPosition: y_buy_button - 25, zPosition: "OverlayButton", childOf: "SidePanel")

        
        // Add iceTower buy button
        let iceTower = SKSpriteNode(texture: SKTexture(imageNamed: "IceTower"), size: CGSize(width: 400 ,height: 400))
        x_buy_button = camera_viewport_width + regularTower.frame.width - 275
        y_buy_button = camera_viewport_height - regularTower.frame.height - 1000
        
        iceTower.position = CGPointMake(x_buy_button, y_buy_button)
        iceTower.zPosition = ZPosition.OverlayButton.rawValue
        iceTower.name = "BuyIceTower"
        
        // Create gold image
        coinImageTexture = SKTexture(imageNamed: "CoinImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 150, yPosition: y_buy_button + 100, nodeName: "CoinImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: iceTowerCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 255, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create attack image
        attackImageTexture = SKTexture(imageNamed: "AttackValueImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 150, yPosition: y_buy_button, nodeName: "AttackValueImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: iceTowerDamage, labelColour: "White", labelFontSize: 75, xPosition: x_buy_button + 250, yPosition: y_buy_button - 25, zPosition: "OverlayButton", childOf: "SidePanel")
        
        
        // Add defenderPowerSource buy button
        let defenderPowerSource = SKSpriteNode(texture: SKTexture(imageNamed: "DefenderPowerSource"), size: CGSize(width: 265 ,height: 300))
        x_buy_button = camera_viewport_width + regularTower.frame.width - 275
        y_buy_button = camera_viewport_height - regularTower.frame.height - 1500
        
        defenderPowerSource.position = CGPointMake(x_buy_button, y_buy_button)
        defenderPowerSource.zPosition = ZPosition.OverlayButton.rawValue
        defenderPowerSource.name = "BuyDefenderPowerSource"
        
        // Create gold image
        coinImageTexture = SKTexture(imageNamed: "CoinImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 150, yPosition: y_buy_button + 100, nodeName: "CoinImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: defenderPowerSrcCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 250, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "SidePanel")
        
        
        /*
        // Add advancedTower buy button
        let advancedTower = SKSpriteNode(texture: SKTexture(imageNamed: "AdvancedTower"), size: CGSize(width: 400 ,height: 400))
        
        x_buy_button = camera_viewport_width + basicTower.frame.width - 150
        y_buy_button = camera_viewport_height - basicTower.frame.height - 800
        
        advancedTower.position = CGPointMake(x_buy_button, y_buy_button)
        advancedTower.zPosition = ZPosition.OverlayButton.rawValue
        advancedTower.name = "BuyAdvancedTower"
        
        // Create cost image
        createNode(goldCostImage, uiTexture: goldImageTexture, scaleX: 3.5, scaleY: 3.5, xPosition: x_buy_button - 150, yPosition: y_buy_button - 260, nodeName: "GoldImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode(goldCostLabel, labelFont: "Arial-BoldMT", labelText: advancedTowerCost, labelColour: "Gold", labelFontSize: 100, xPosition: x_buy_button + 25, yPosition: y_buy_button - 300, zPosition: "OverlayButton", childOf: "SidePanel")
        */
        
        
        
        /*
        // Add defenderPowerSource buy button
        let defenderPowerSource = SKSpriteNode(texture: SKTexture(imageNamed: "DefenderPowerSource"), size: CGSize(width: 400 ,height: 400))
        
        x_buy_button = camera_viewport_width + basicTower.frame.width - 150
        y_buy_button = camera_viewport_height - basicTower.frame.height - 1600
        
        defenderPowerSource.position = CGPointMake(x_buy_button, y_buy_button)
        defenderPowerSource.zPosition = ZPosition.OverlayButton.rawValue
        defenderPowerSource.name = "BuyDefenderPowerSource"
        
        // Create cost image
        createNode(goldCostImage, uiTexture: goldImageTexture, scaleX: 3.5, scaleY: 3.5, xPosition: x_buy_button - 125, yPosition: y_buy_button - 260, nodeName: "GoldImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode(goldCostLabel, labelFont: "Arial-BoldMT", labelText: defenderPowerSrcCost, labelColour: "Gold", labelFontSize: 100, xPosition: x_buy_button + 25, yPosition: y_buy_button - 300, zPosition: "OverlayButton", childOf: "SidePanel")
        */
        
        
        
        //sidePanel.addChild(basicTower)
        sidePanel.addChild(regularTower)
        sidePanel.addChild(fireTower)
        sidePanel.addChild(iceTower)
        sidePanel.addChild(defenderPowerSource)
        //sidePanel.addChild(advancedTower)
        //sidePanel.addChild(goldCostLabel)
        //sidePanel.addChild(goldImage)
        
        
        sceneCamera.addChild(sidePanel) // Add child to the camera
    }
    
    let colorize = SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 0.5, duration: 0.5)
    func init_buttons()
    {
        // This is the buy button for the side panel
        buyButton = SKSpriteNode(texture: SKTexture(imageNamed: "BuyButton"))
        buyButton.xScale = 1
        buyButton.yScale = 1
        buyButton.position = CGPointMake(0, 0)
        buyButton.name = "BuyButton"
        buyButton.zPosition = ZPosition.OverlayButton.rawValue
        sceneCamera.addChild(buyButton)
        
        // These are the sandbox buttons, at the lower part of the screen
        buttons[BuildMode.Orc.rawValue] = ButtonManager.init_button(camera!, img_name: "orc_left_0", button_name: "orcButton", index: BuildMode.Orc.rawValue)
        
        buttons[BuildMode.BasicTower.rawValue] = ButtonManager.init_button(camera!, img_name: "BasicTower", button_name: "basicTowerButton", index: BuildMode.BasicTower.rawValue)
        
        buttons[BuildMode.AdvancedTower.rawValue] = ButtonManager.init_button(camera!, img_name: "AdvancedTower", button_name: "advancedTowerButton", index: BuildMode.AdvancedTower.rawValue)
        
        buttons[BuildMode.RegularTower.rawValue] = ButtonManager.init_button(camera!, img_name: "RegularTower", button_name: "regularTowerButton", index: BuildMode.RegularTower.rawValue)
        
        buttons[BuildMode.FireTower.rawValue] = ButtonManager.init_button(camera!, img_name: "FireTower", button_name: "fireTowerButton", index: BuildMode.FireTower.rawValue)
        
        buttons[BuildMode.IceTower.rawValue] = ButtonManager.init_button(camera!, img_name: "IceTower", button_name: "iceTowerButton", index: BuildMode.IceTower.rawValue)
        
        
        buttons[BuildMode.DefenderPowerSource.rawValue] = ButtonManager.init_button(camera!, img_name: "DefenderPowerSource", button_name: "defenderPowerSourceButton", index: BuildMode.DefenderPowerSource.rawValue)
        
        buttons[BuildMode.DirtyPig.rawValue] = ButtonManager.init_button(camera!, img_name: "dirty_pig_left_0", button_name: "dirtyPigButton", index: BuildMode.DirtyPig.rawValue)
        
        buttons[BuildMode.HatPig.rawValue] = ButtonManager.init_button(camera!, img_name: "hat_pig_left_0", button_name: "hatPigButton", index: BuildMode.HatPig.rawValue)
        
        buttons[BuildMode.FancyPig.rawValue] = ButtonManager.init_button(camera!, img_name: "fancy_pig_left_0", button_name: "fancyPigButton", index: BuildMode.FancyPig.rawValue)
        
        // Start in Orc mode
        self.current_build_mode = .Orc
        buttons[BuildMode.Orc.rawValue]!.runAction(colorize)
    }
    
    // MARK: Update method

    var seconds : Int = 0
    override func update(currentTime: NSTimeInterval)
    {
        if (!gameOver)
        {
            // Update all units that walk on the maze
            for unit in all_units.values
            {
                unit.update()
            }
            
            // Update all the pigs
            for pig in all_pigs.values
            {
                pig.update()
            }
            
            // Update all the buildings
            for building in all_buildings.values
            {
                building.update()
            }
            
            livesLabel.text = String(lifeCount)
            
            // Calculate and display time count
            updateTimerAndGold(Int(currentTime))

            // Game ends when time reaches 10:00 minutes
            if (gameTimeElapsed == totalGameTime || lifeCount == 0)
            {
                doGameOver()
            }
        }
    }
    
    func updateTimerAndGold(currentTime: Int)
    {
        // Update Timer
        if startTimer == true
        {
            gameStartTime = currentTime
            startTimer = false
        }
        gameTimeElapsed = currentTime - gameStartTime
        
        
        let (m, s) = timeInMinutesSeconds(gameTimeElapsed)
        if s < 10
        {
            self.timeLabel.text = ("\(m):0\(s)")
        }
        else
        {
            self.timeLabel.text = ("\(m):\(s)")
        }
        
        // Update Gold every 5 seconds
        var doAddGold : Bool = s % 5 == 0
        if seconds == s && doAddGold
        {
            doAddGold = false
            
        }
        
        seconds = s
        if doAddGold
        {
            goldCount += 5
        }
        
        goldLabel.text = String(goldCount)
    }
    
    func doGameOver()
    {
        endGameLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        endGameLabel.fontSize = 150
        endGameLabel.zPosition = ZPosition.GUI.rawValue
        endGameLabel.position = CGPointMake(1200, 100)
        if (gameTimeElapsed == totalGameTime) {
            endGameLabel.text = "GAME OVER" + " Defender Wins!"
            endGameLabel.fontColor = UIColor.blueColor()
        }
        if (lifeCount == 0) {
            endGameLabel.text = "GAME OVER" + " Attacker Wins!"
            endGameLabel.fontColor = UIColor.redColor()
        }
        sceneCamera.addChild(endGameLabel)
        gameOver = true
    }
    
    // MARK: Handle touches ( moved and begin ) methods
    
    var prevLocation: CGPoint = CGPointMake(0, 0)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let touchPoint = touch.locationInView(self.view)
            let scenePoint = scene!.convertPointFromView(touchPoint)
            let touchedNode = self.nodeAtPoint(scenePoint)
            
            prevLocation = touchPoint
            
            var gui_element_clicked = false
            var entity_clicked = false
            
            if let name = touchedNode.name
            {
                gui_element_clicked = true
                if name == "BuyButton"
                {
                    buyButtonPushed()
                }
                if (name == "BuyBasicTower")
                {
                    current_build_mode! = .BasicTower
                }
                if (name == "BuyAdvancedTower")
                {
                    current_build_mode! = .AdvancedTower
                }
                if (name == "BuyRegularTower")
                {
                    current_build_mode! = .RegularTower
                }
                if (name == "BuyFireTower")
                {
                    current_build_mode! = .FireTower
                }
                if (name == "BuyIceTower")
                {
                    current_build_mode! = .IceTower
                }
                if (name == "BuyDefenderPowerSource")
                {
                    current_build_mode! = .DefenderPowerSource
                }
                else if name.containsString("Button")
                {
                    // Reset old clicked button
                    ButtonManager.reset_button(self.scene!, button: buttons[current_build_mode.rawValue]!)
                    
                    switch (current_build_mode!)
                    {
                    case .Orc:
                        buttons[current_build_mode.rawValue] = ButtonManager.init_button(sceneCamera, img_name: "orc_left_0", button_name: "orcButton", index: 0)
                        
                    case .BasicTower:
                        buttons[BuildMode.BasicTower.rawValue] = ButtonManager.init_button(camera!, img_name: "BasicTower", button_name: "basicTowerButton", index: BuildMode.BasicTower.rawValue)
                    
                    case .AdvancedTower:
                        buttons[BuildMode.AdvancedTower.rawValue] = ButtonManager.init_button(camera!, img_name: "AdvancedTower", button_name: "advancedTowerButton", index: BuildMode.AdvancedTower.rawValue)
                    
                    case .RegularTower:
                        buttons[BuildMode.RegularTower.rawValue] = ButtonManager.init_button(camera!, img_name: "RegularTower", button_name: "regularTowerButton", index: BuildMode.RegularTower.rawValue)
                    
                    case .FireTower:
                        buttons[BuildMode.FireTower.rawValue] = ButtonManager.init_button(camera!, img_name: "FireTower", button_name: "fireTowerButton", index: BuildMode.FireTower.rawValue)
                    
                    case .IceTower:
                        buttons[BuildMode.IceTower.rawValue] = ButtonManager.init_button(camera!, img_name: "IceTower", button_name: "iceTowerButton", index: BuildMode.IceTower.rawValue)
                        
                    case .DefenderPowerSource:
                        buttons[BuildMode.DefenderPowerSource.rawValue] = ButtonManager.init_button(camera!, img_name: "DefenderPowerSource", button_name: "DefenderPowerSrcButton", index: BuildMode.DefenderPowerSource.rawValue)
                        
                    case .DirtyPig:
                        buttons[BuildMode.DirtyPig.rawValue] = ButtonManager.init_button(camera!, img_name: "dirty_pig_left_0", button_name: "dirtyPigButton", index: BuildMode.DirtyPig.rawValue)
                        
                    case .HatPig:
                        buttons[BuildMode.HatPig.rawValue] = ButtonManager.init_button(camera!, img_name: "hat_pig_left_0", button_name: "hatPigButton", index: BuildMode.HatPig.rawValue)
                        
                    case .FancyPig:
                        buttons[BuildMode.FancyPig.rawValue] = ButtonManager.init_button(camera!, img_name: "fancy_pig_left_0", button_name: "fancyPigButton", index: BuildMode.FancyPig.rawValue)
                    }
                    
                    // Find which button was clicked
                    for var index = 0 ; index < buttons.count; index++
                    {
                        if (buttons[index]!.name == name)
                        {
                            buttons[index]!.runAction(colorize)
                            current_build_mode = BuildMode(rawValue: index)
                            break
                        }
                    }
                }
                else if let entity_id = Int(name)
                {
                    entity_clicked = true
                    
                    if let building_entity = all_buildings[entity_id]
                    {
                        (building_entity as! Tower).visualizeMazeTiles()
                    }
                }
            }
            
            if (!gui_element_clicked && !entity_clicked)
            {
                switch (current_build_mode! )
                {
                case .Orc:
                    spawnOrc(scenePoint)
                case .BasicTower:
                    place_temp_building()
                    
                case .AdvancedTower:
                    if (advancedTowerCost > goldCount)
                    {
                        debugPrint("You Do not have enough gold to purchase Basic Tower")
                    }
                    else
                    {
                        spawnAdvancedTurret(scenePoint)
                    }
                case .RegularTower:
                    if (regularTowerCost > goldCount)
                    {
                        debugPrint("You Do not have enough gold to purchase Basic Tower")
                    }
                    else
                    {
                        spawnRegularTower(scenePoint)
                    }
                case .FireTower:
                    if (fireTowerCost > goldCount)
                    {
                        debugPrint("You Do not have enough gold to purchase Basic Tower")
                    }
                    else
                    {
                        spawnFireTower(scenePoint)
                    }
                case .IceTower:
                    if (iceTowerCost > goldCount)
                    {
                        debugPrint("You Do not have enough gold to purchase Basic Tower")
                    }
                    else
                    {
                        spawnIceTower(scenePoint)
                    }

                    
                case .DefenderPowerSource:
                    if (defenderPowerSrcCost > goldCount)
                    {
                        debugPrint("You Do not have enough gold to purchase Basic Tower")
                    }
                    else
                    {
                        spawnDefenderPowerSource(scenePoint)
                    }
                    
                case .DirtyPig:
                    spawnDirtyPig(scenePoint)
                case .HatPig:
                    spawnHatPig(scenePoint)
                case .FancyPig:
                    spawnFancyPig(scenePoint)
                }
                
                if (debug)
                {
                    let pos_on_grid = coordinateForPoint(scenePoint)
                    let tile = Tile.getTile(tiles, pos: pos_on_grid)
                    
                }
            }
        }
    }
    
    func place_temp_building()
    {
        debugPrint(current_build_mode)
    }
    
    var side_panel_open = false
    func buyButtonPushed()
    {
        if (!side_panel_open)
        {
            let slideIn = SKAction.moveByX(-buy_panel_width, y: 0, duration: 1.0) // Define the action to slide it 600 units to the left

            sidePanel.runAction(slideIn) // Run the action
            
            side_panel_open = true // Set so that we don't open it multiple times
        }
        else // If it is already open, slide it back
        {
            let slideOut = SKAction.moveByX(buy_panel_width, y: 0, duration: 1.0) // Define the action to slide it 600 units to the left
            sidePanel.runAction(slideOut) // Run the action
            
            side_panel_open = false
        }
        debugPrint("Buy button pushed!")
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
            var new_y = sceneCamera.position.y + dy * 2.5
            
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
    
    func timeInMinutesSeconds (seconds : Int) -> (Int, Int)
    {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func coordinateForPoint(point: CGPoint) -> int2
    {
        return int2(Int32( point.x / Tile.tileWidth), Int32(point.y / Tile.tileHeight))
    }
    
    func pointForCoordinate(point: int2) -> CGPoint
    {
        return CGPointMake(CGFloat(point.x) * Tile.tileWidth, CGFloat(point.y) * Tile.tileHeight)
    }
    
    // MARK: Json map parsing.
    
    var map_height : Int = -1
    var map_width : Int = -1
    enum Layers: Int
    {
        case ATTACKER = 0
        case DEFENDER = 1
        case ROAD = 2
        case DECO = 3
        case WAYPOINT = 4
        case GOAL = 5
    }
    
    func getJSONFile()
    {
        let filePath = NSBundle.mainBundle().pathForResource("Map", ofType: "json")
        
        do
        {
            let text = try NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)
            
            let parsedText = try NSJSONSerialization.JSONObjectWithData(text.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
            
            if let jsonContent = parsedText as? NSDictionary
            {
                map_height = jsonContent["height"] as! Int
                map_width = jsonContent["width"] as! Int
                
                // Put the values from file into a 2d array
                tileNums = [[Int]](count: map_height, repeatedValue: [Int](count: map_width, repeatedValue: 0))
                
                //debugPrint("Map dimensions: \(map_height) x \(map_width)")
                let layers = jsonContent["layers"] as! NSArray

                // Parse attacker layer
                parseLayer(layers, layer: Layers.ATTACKER.rawValue)
                
                // Parse defender layer
                parseLayer(layers, layer: Layers.DEFENDER.rawValue)
                
                // Parse road layer
                parseLayer(layers, layer: Layers.ROAD.rawValue)
                
                // Parse decorations layer
                parseLayer(layers, layer: Layers.DECO.rawValue)
                
                // Parse goal layer
                parseLayer(layers, layer: Layers.GOAL.rawValue)
                
                // Constract the tile array
                let init_int2 = int2(-1,-1)
                tiles = [[Tile]](count: map_height, repeatedValue: [Tile](count: map_width, repeatedValue: NonUsableTile(position: init_int2)))
                
                // Fill it with Tiles parsed from the tileNums
                for row in 0...(map_height-1)
                {
                    for column in 0...(map_width-1)
                    {
                        // Remember that the type num in tileNums is actually by 1 bigger then the actual type! 
                        // (since 0 = nil)
                        let current_num : Int = tileNums[row][column]
                        let pos = int2(Int32(column), Int32(row))
                        
                        tiles[row][column] = Tile.makeTileFromType(current_num, pos: pos)
                    }
                }
                
                parseWayPoints(layers, layer: Layers.WAYPOINT.rawValue)
            }
        }
        catch
        {
            debugPrint("Error reading JSON file")
        }
    }
    
    func parseWayPoints(layers: NSArray, layer: Int)
    {
        // Fill it with tile direction events parsed from the JSON element directly
        let arrows_layer = layers[layer] as! NSDictionary
        let arrows_layer_data = arrows_layer["data"] as! NSArray
        
        for row in 0...(map_height-1)
        {
            for column in 0...(map_width-1)
            {
                let flat_index = column + row * map_width
                let type: Int = arrows_layer_data[flat_index] as! Int
                let option: TileOpts = Tile.parseTileOpts(type)
                
                if (option != TileOpts.None)
                {
                    tiles[row][column].moveOpt = option
                }
            }
        }
    }
    
    func parseLayer(layers: NSArray, layer: Int)
    {
        let layer = layers[layer] as! NSDictionary
        let layer_data = layer["data"] as! NSArray
        
        for row in 0...(map_height-1)
        {
            for column in 0...(map_width-1)
            {
                let flat_index = column + row * map_width
                let num = layer_data[flat_index] as! Int
                
                if (num != 0)
                {
                    self.tileNums[row][column] = num
                }
            }
        }
    }
    
    // MARK: Generalized node function to create and initialize nodes
    
    func createNode(var uiTexture: SKTexture, let scaleX: CGFloat, let scaleY: CGFloat, let xPosition: CGFloat, let yPosition: CGFloat, let nodeName: String, let zPosition: String, let childOf: String)
    {
        
        uiTexture = SKTexture(imageNamed: nodeName)
        let uiNode = SKSpriteNode(texture: uiTexture)
        uiNode.position = CGPointMake(xPosition, yPosition)
        uiNode.xScale = scaleX
        uiNode.yScale = scaleY
        
        // Assign the zposition accordingly
        if (zPosition == "GUI")
        {
            uiNode.zPosition = ZPosition.GUI.rawValue
        }
        if (zPosition == "OverlayButton")
        {
            uiNode.zPosition = ZPosition.OverlayButton.rawValue
        }
        
        // add child to respective parent node
        if (childOf == "Camera")
        {
            sceneCamera.addChild(uiNode)
        }
        if (childOf == "SidePanel")
        {
            sidePanel.addChild(uiNode)
        }
        
    }
    
    func createLableNode(let labelFont: String, let labelText: Any, let labelColour: String, let labelFontSize: CGFloat, let xPosition: CGFloat, let yPosition: CGFloat, let zPosition: String, let childOf: String)
    {
        let uiLabelNode = SKLabelNode(fontNamed: labelFont)
        uiLabelNode.text = String(labelText)
        uiLabelNode.fontSize = labelFontSize

        uiLabelNode.position = CGPointMake(xPosition, yPosition)
        if (labelColour == "Gold")
        {
            uiLabelNode.fontColor = UIColor(red: 248/255, green: 200/255, blue: 0, alpha: 1)
        }
        if (labelColour == "Blue")
        {
            uiLabelNode.fontColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
        }
        if (labelColour == "White")
        {
            uiLabelNode.fontColor = UIColor.whiteColor()
        }
        
        // Assign the zposition accordingly
        if (zPosition == "GUI")
        {
            uiLabelNode.zPosition = ZPosition.GUI.rawValue
        }
        if (zPosition == "OverlayButton")
        {
            uiLabelNode.zPosition = ZPosition.OverlayButton.rawValue
        }
        
        // add child to respective parent node
        if (childOf == "Camera")
        {
            sceneCamera.addChild(uiLabelNode)
        }
        if (childOf == "SidePanel")
        {
            sidePanel.addChild(uiLabelNode)
        }
        
    }
    
    // MARK: Spawn methods for different units
    
    func spawnOrc(point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is MazeTile)
        {
            // Init the orc
            let orc = Orc(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, speed: 1)
            
            // Keep track of it in a dictionary
            all_units[orc.entity_id] = orc
        }
        else
        {
            debugPrint("Not a maze tile!")
        }
    }
    
    func spawnDirtyPig(point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is GoalTile)
        {
            // Init the orc
            let pig = DirtyPig(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, speed: 1)
            
            // Keep track of it in a dictionary
            all_pigs[pig.entity_id] = pig
        }
        else
        {
            debugPrint("Not a maze tile!")
        }
    }
    
    func spawnHatPig(point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is GoalTile)
        {
            // Init the orc
            let pig = HatPig(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, speed: 1)
            
            // Keep track of it in a dictionary
            all_pigs[pig.entity_id] = pig
        }
        else
        {
            debugPrint("Not a maze tile!")
        }
    }
    
    func spawnFancyPig(point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is GoalTile)
        {
            // Init the orc
            let pig = FancyPig(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, speed: 1)
            
            // Keep track of it in a dictionary
            all_pigs[pig.entity_id] = pig
        }
        else
        {
            debugPrint("Not a maze tile!")
        }
    }
    
    func spawnBasicTurret(point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the tower
            let tower = BasicTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[tower.entity_id] = tower
            goldCount -= basicTowerCost
        }
        else
        {
            debugPrint("Not a defender tile!")
        }
    }
    
    
    func spawnAdvancedTurret (point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the tower
            let tower = AdvancedTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[tower.entity_id] = tower
            goldCount -= advancedTowerCost
        }
        else
        {
            debugPrint("Not a defender tile!")
        }
    }
    
    func spawnDefenderPowerSource (point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the tower
            let tower = DefenderPowerSource(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[tower.entity_id] = tower
                goldCount -= defenderPowerSrcCost
        }
        else
        {
            debugPrint("Not a defender tile!")
        }
    }
    
    func spawnRegularTower (point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the tower
            let tower = RegularTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[tower.entity_id] = tower
            goldCount -= regularTowerCost
        }
        else
        {
            debugPrint("Not a defender tile!")
        }
    }

    func spawnFireTower (point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the tower
            let tower = FireTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[tower.entity_id] = tower
            goldCount -= fireTowerCost
        }
        else
        {
            debugPrint("Not a defender tile!")
        }
    }
    
    func spawnIceTower (point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the tower
            let tower = IceTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[tower.entity_id] = tower
            goldCount -= iceTowerCost
        }
        else
        {
            debugPrint("Not a defender tile!")
        }
    }
    
    // MARK: Network requests
    
    func send_request(request: String)
    {
        let par = ["teat": "Test!"]
        Alamofire.request(.GET, "http://192.168.0.15/", parameters: par).responseJSON
            {
                response in
                switch response.result
                {
                case .Success (let data):
                    let json = JSON(data)
                    let name = json["name"].stringValue
                    print(name)
                    
                case .Failure (let error):
                    print("Request failed with error: \(error)")
                }
        }

    }
}