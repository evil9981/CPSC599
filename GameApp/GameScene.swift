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

var lifeCount : Int = 300
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
    var buyButton_attack: SKSpriteNode!
    var sidePanel: SKShapeNode!
    var sidePanel_attack: SKShapeNode!
    
    // Game menu stuff
    var towerMenu : SKShapeNode!
    var buildingMenu : SKShapeNode!
    
    var tileNums : [[Int]]!
    var tiles : [[Tile]]!
    
    let debug = true
    
    // MARK: Placeholder stuff, used to support demo
    
    enum BuildMode : Int
    {
        case Orc = 0
        case None = 1
        case RegularTower = 2
        case FireTower = 3
        case IceTower = 4
        case DefenderPowerSource = 5
        case OrcBuliding = 6
        case GoblinBuilding = 7
        case TrollBuilding = 8
        case AttackerPowerSource = 9
    }
    var current_build_mode : BuildMode!
    
    var buttons: [Int:SKSpriteNode] = [:]
    
    enum ZPosition : CGFloat
    {
        case Map = 0
        case MazeUnit = 1
        case Tower = 2
        case Ammo = 3
        case GUI = 4
        case Overlay = 5
        case OverlayButton = 6
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
        
        // Spawns the 3 pigs
        spawn_pigs()
        
        var spawn_point = pointForCoordinate(int2(107,27))
        var building = spawnDefenderPowerSource(spawn_point, spawn_free: true)
        
        // Add temp building to tiles
        for pos in [int2(107,27), int2(108,27), int2(107,28), int2(108,28)]
        {
            let tile = Tile.getTile(tiles, pos: pos)
            tile.building_on_tile = building!
        }
        
        spawn_point = pointForCoordinate(int2(34,37))
        building = spawnAttackerPowerSource(spawn_point, spawn_free: true)
        
        // Add temp building to tiles
        for pos in [int2(34,37), int2(35,37), int2(34,38), int2(35,38)]
        {
            let tile = Tile.getTile(tiles, pos: pos)
            tile.building_on_tile = building!
        }
        
        // Add teleporters 
        var tile = Tile.getTile(tiles, pos: int2(2,9))
        tile.moveOpt = TileOpts.Teleport
        tile.teleportDestination = Tile.getTile(tiles, pos: int2(146,20))
        
        tile = Tile.getTile(tiles, pos: int2(2,6))
        tile.moveOpt = TileOpts.Teleport
        tile.teleportDestination = Tile.getTile(tiles, pos: int2(146,23))
    }
    
    func spawn_pigs()
    {
        let positions: [int2] = [int2(113, 27), int2(115, 24), int2(117, 20)]
        spawnDirtyPig( pointForCoordinate ( positions[0] ) )
        spawnFancyPig( pointForCoordinate ( positions[1] ) )
        spawnHatPig( pointForCoordinate ( positions[2] ) )
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
        // Give temp buttons names
        temp_ok_button.name = "ok_building"
        temp_cancel_button.name = "cancel_building"
        
        // Add the 'Gold Label' to the camera view and place it in the top left corner
        goldLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        goldLabel.text = String(goldCount)
        goldLabel.fontSize = 150
        goldLabel.fontColor = UIColor(red: 248/255, green: 200/255, blue: 0, alpha: 1)
        goldLabel.position = CGPointMake(750, 1235)
        goldLabel.zPosition = ZPosition.GUI.rawValue
        sceneCamera.addChild(goldLabel)
        
        // Add the 'Lives Label' to the camera view and place it in the top right corner
        livesLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        livesLabel.text = String(lifeCount)
        livesLabel.fontSize = 150
        livesLabel.fontColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        livesLabel.position = CGPointMake(4100, 1235)
        livesLabel.zPosition = ZPosition.GUI.rawValue
        sceneCamera.addChild(livesLabel)
        
        // Add the 'Time Label' to the camera view and place it in the middle
        timeLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        timeLabel.fontSize = 150
        timeLabel.fontColor = UIColor.whiteColor()
        timeLabel.position = CGPointMake(2350, 1230)
        timeLabel.zPosition = ZPosition.GUI.rawValue
        sceneCamera.addChild(timeLabel)
        
        // Add the gold image texture
        goldImageTexture = SKTexture(imageNamed: "GoldImage")
        goldImage = SKSpriteNode(texture: goldImageTexture)
        goldImage.position = CGPointMake(450, 1300)
        goldImage.xScale = 8
        goldImage.yScale = 8
        goldImage.zPosition = ZPosition.GUI.rawValue
        sceneCamera.addChild(goldImage)
        
        // Add the lives image texture
        livesImageTexture = SKTexture(imageNamed: "LivesImage")
        livesImage = SKSpriteNode(texture: livesImageTexture)
        livesImage.position = CGPointMake(3850, 1300)
        livesImage.xScale = 8
        livesImage.yScale = 8
        livesImage.zPosition = ZPosition.GUI.rawValue
        sceneCamera.addChild(livesImage)
        
        // Init the orc and tower buttons
        init_buttons()
        init_buy_panel()
        init_buy_panel_attack()
        
        // Building and tower menus
        init_tower_menu()
    }
    
    let buy_panel_width : CGFloat = 600 // This is how wide the buy panel is
    func init_buy_panel()
    {
        let frame = CGRect(x: camera_viewport_width, y: (-camera_viewport_height), width: buy_panel_width, height: camera_viewport_height*2) // Use the camera_viewport that is calculated at the start to determine how big the frame is
        sidePanel = SKShapeNode(rect: frame) // Create a SKShapeNode from the frame
        sidePanel.zPosition = ZPosition.Overlay.rawValue
            
        sidePanel.fillColor = UIColor.blackColor().colorWithAlphaComponent(0.5) // This is the fill color, 0.5 is transperency
        sidePanel.strokeColor = UIColor.blackColor() // This is the border color

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
        createLableNode("Arial-BoldMT", labelText: RegularTower.towerCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 250, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create attack image
        attackImageTexture = SKTexture(imageNamed: "AttackValueImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 150, yPosition: y_buy_button, nodeName: "AttackValueImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: RegularTower.towerDamage, labelColour: "White", labelFontSize: 75, xPosition: x_buy_button + 250, yPosition: y_buy_button - 25, zPosition: "OverlayButton", childOf: "SidePanel")
        
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
        createLableNode("Arial-BoldMT", labelText: FireTower.towerCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 255, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create attack image
        attackImageTexture = SKTexture(imageNamed: "AttackValueImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 150, yPosition: y_buy_button, nodeName: "AttackValueImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: FireTower.towerDamage, labelColour: "White", labelFontSize: 75, xPosition: x_buy_button + 250, yPosition: y_buy_button - 25, zPosition: "OverlayButton", childOf: "SidePanel")

        
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
        createLableNode("Arial-BoldMT", labelText: IceTower.towerCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 255, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create attack image
        attackImageTexture = SKTexture(imageNamed: "AttackValueImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 150, yPosition: y_buy_button, nodeName: "AttackValueImage", zPosition: "OverlayButton", childOf: "SidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: IceTower.towerDamage, labelColour: "White", labelFontSize: 75, xPosition: x_buy_button + 250, yPosition: y_buy_button - 25, zPosition: "OverlayButton", childOf: "SidePanel")
        
        
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
        createLableNode("Arial-BoldMT", labelText: DefenderPowerSource.buildingCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 250, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "SidePanel")
        
        sidePanel.addChild(regularTower)
        sidePanel.addChild(fireTower)
        sidePanel.addChild(iceTower)
        sidePanel.addChild(defenderPowerSource)
        
        
        sceneCamera.addChild(sidePanel) // Add child to the camera
    }
    
    func init_buy_panel_attack()
    {
        let frame = CGRect(x: -920, y: (-camera_viewport_height), width: buy_panel_width, height: camera_viewport_height*2) // Use the camera_viewport that is calculated at the start to determine how big the frame is
        sidePanel_attack = SKShapeNode(rect: frame) // Create a SKShapeNode from the frame
        sidePanel_attack.zPosition = ZPosition.Overlay.rawValue
        
        sidePanel_attack.fillColor = UIColor.blackColor().colorWithAlphaComponent(0.5) // This is the fill color, 0.5 is transperency
        sidePanel_attack.strokeColor = UIColor.blackColor() // This is the border color
        
        // Add orcBuilding Buy button
        let orcBuilding = SKSpriteNode(texture: SKTexture(imageNamed: "Orc_Building"), size: CGSize(width:400, height: 400))
        var x_buy_button = -920 + orcBuilding.frame.width - 200
        var y_buy_button = camera_viewport_height - orcBuilding.frame.height - 50
        orcBuilding.position = CGPointMake(x_buy_button, y_buy_button)
        orcBuilding.zPosition = ZPosition.OverlayButton.rawValue
        orcBuilding.name = "BuyOrcBuilding"
        
        // Create gold image
        coinImageTexture = SKTexture(imageNamed: "CoinImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 200, yPosition: y_buy_button + 100, nodeName: "CoinImage", zPosition: "OverlayButton", childOf: "AttackSidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: RegularTower.towerCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 300, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "AttackSidePanel")
        
        // Add goblinBuilding buy button
        let goblinBuilding = SKSpriteNode(texture: SKTexture(imageNamed: "Goblin_Building"), size: CGSize(width: 400 ,height: 400))
        x_buy_button = -920 + orcBuilding.frame.width - 200
        y_buy_button = camera_viewport_height - orcBuilding.frame.height - 500
        
        goblinBuilding.position = CGPointMake(x_buy_button, y_buy_button)
        goblinBuilding.zPosition = ZPosition.OverlayButton.rawValue
        goblinBuilding.name = "BuyGoblinBuilding"
        
        // Create gold image
        coinImageTexture = SKTexture(imageNamed: "CoinImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 200, yPosition: y_buy_button + 100, nodeName: "CoinImage", zPosition: "OverlayButton", childOf: "AttackSidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: FireTower.towerCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 305, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "AttackSidePanel")
        
        // Add trollBuilding buy button
        let trollBuilding = SKSpriteNode(texture: SKTexture(imageNamed: "Troll_Building"), size: CGSize(width: 400 ,height: 400))
        x_buy_button = -920 + orcBuilding.frame.width - 200
        y_buy_button = camera_viewport_height - orcBuilding.frame.height - 1000
        
        trollBuilding.position = CGPointMake(x_buy_button, y_buy_button)
        trollBuilding.zPosition = ZPosition.OverlayButton.rawValue
        trollBuilding.name = "BuyTrollBuilding"
        
        // Create gold image
        coinImageTexture = SKTexture(imageNamed: "CoinImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 200, yPosition: y_buy_button + 100, nodeName: "CoinImage", zPosition: "OverlayButton", childOf: "AttackSidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: IceTower.towerCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 305, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "AttackSidePanel")
        
        // Add attackerPowerSource buy button
        let attackerPowerSource = SKSpriteNode(texture: SKTexture(imageNamed: "AttackerPowerSource"), size: CGSize(width: 265 ,height: 300))
        x_buy_button = -920 + orcBuilding.frame.width - 200
        y_buy_button = camera_viewport_height - orcBuilding.frame.height - 1500
        
        attackerPowerSource.position = CGPointMake(x_buy_button, y_buy_button)
        attackerPowerSource.zPosition = ZPosition.OverlayButton.rawValue
        attackerPowerSource.name = "BuyAttackerPowerSource"
        
        // Create gold image
        coinImageTexture = SKTexture(imageNamed: "CoinImage")
        createNode(coinImageTexture, scaleX: 6.5, scaleY: 6.5, xPosition: x_buy_button + 200, yPosition: y_buy_button + 100, nodeName: "CoinImage", zPosition: "OverlayButton", childOf: "AttackSidePanel")
        
        // Create cost label
        createLableNode("Arial-BoldMT", labelText: DefenderPowerSource.buildingCost, labelColour: "Gold", labelFontSize: 75, xPosition: x_buy_button + 300, yPosition: y_buy_button + 75, zPosition: "OverlayButton", childOf: "AttackSidePanel")
        
        sidePanel_attack.addChild(orcBuilding)
        sidePanel_attack.addChild(goblinBuilding)
        sidePanel_attack.addChild(trollBuilding)
        sidePanel_attack.addChild(attackerPowerSource)
        
        sceneCamera.addChild(sidePanel_attack) // Add child to the camera
    }

    // initialize tower menu
    let tower_menu_height : CGFloat = 600  // how high the menu is
    func init_tower_menu()
    {
        let frame = CGRect(x: 0, y: 0, width: buy_panel_width, height: tower_menu_height)
        towerMenu = SKShapeNode(rect: frame)
        towerMenu.zPosition = ZPosition.Overlay.rawValue
        
        let x = camera_viewport_width/2
        let y = -camera_viewport_height - tower_menu_height
        towerMenu.position = CGPointMake(x, y)
        
        // Colors
        towerMenu.fillColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        towerMenu.strokeColor = UIColor.blackColor()

        // Add to camera
        sceneCamera.addChild(towerMenu)
    }
    
    let colorize = SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 0.5, duration: 0.5)
    func init_buttons()
    {
        // This is the buy button for the side panel
        buyButton = SKSpriteNode(texture: SKTexture(imageNamed: "BuyButton"))
        buyButton.xScale = 1
        buyButton.yScale = 1
        buyButton.position = CGPointMake(4000, -1000)
        buyButton.name = "BuyButton"
        buyButton.zPosition = ZPosition.OverlayButton.rawValue
        sceneCamera.addChild(buyButton)
        
        buyButton_attack = SKSpriteNode(texture: SKTexture(imageNamed: "BuyButton"))
        buyButton_attack.xScale = 1
        buyButton_attack.yScale = 1
        buyButton_attack.position = CGPointMake(450, -1000)
        buyButton_attack.name = "Attacker BuyButton"
        buyButton_attack.zPosition = ZPosition.OverlayButton.rawValue
        sceneCamera.addChild(buyButton_attack)
        
        // These are the sandbox buttons, at the lower part of the screen
        buttons[BuildMode.Orc.rawValue] = ButtonManager.init_button(camera!, img_name: "orc_left_0", button_name: "orcButton", index: BuildMode.Orc.rawValue)
        
        buttons[BuildMode.None.rawValue] = ButtonManager.init_button(camera!, img_name: "buy_no", button_name: "NoneButton", index: BuildMode.None.rawValue)
        
        // Start in Orc mode
        self.current_build_mode = .Orc
        buttons[BuildMode.Orc.rawValue]!.runAction(colorize)
    }
    
    // MARK: Update method

    var seconds : Int = 0
    var prevTime: NSTimeInterval = 0
    override func update(currentTime: NSTimeInterval)
    {
        var delta : NSTimeInterval
        if (prevTime == 0)
        {
            delta = 0
        }
        else
        {
            delta = currentTime - prevTime
        }
        prevTime = currentTime
        
        if (!gameOver)
        {
            // Update all units that walk on the maze
            for unit in all_units.values
            {
                unit.update(delta)
            }
            
            // Update all the pigs
            for pig in all_pigs.values
            {
                pig.update()
            }
            
            // Update all the buildings
            for building in all_buildings.values
            {
                building.update(delta)
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
            
            let pos_on_grid = coordinateForPoint(scenePoint)
            let point = pointForCoordinate(pos_on_grid)
            
            let tile = Tile.getTile(tiles, pos: pos_on_grid)
            debugPrint("Position on grid: \(pos_on_grid)")
            debugPrint("Tile at position: \(tile)")
            debugPrint("Tile has power source: \(tile.towerInRange)")
            
            debugPrint("Scene Point: \(scenePoint) , new point: \(point)")
            
            prevLocation = touchPoint
            
            var gui_element_clicked = false
            var entity_clicked = false
            
            
            let building = tile.building_on_tile
            
            if (building != nil)
            {
                entity_clicked = true
                
                buildingMenuPushed( building! )
            }
            else if let name = touchedNode.name
            {
                gui_element_clicked = true
                let make_point = CGPointMake(sceneCamera.position.x + camera_viewport_width/4, sceneCamera.position.y)
                
                if name == "show_range_tower"
                {
                    Tower.visualizeMazeTiles(self)
                }
                else if name == "show_range_power_source"
                {
                    show_power_source_range = !show_power_source_range
                    PowerSource.visualizePowerSourceArea(self, show_shapes: show_power_source_range)
                }
                else if name == "spawn_orc"
                {
                    let spawner = building_selected as! Spawner
                    let scene_spawn_point = pointForCoordinate( spawner.selected_spawn_point )
                    spawnOrc(scene_spawn_point)
                }
                else if name == "spawn_troll"
                {
                    let spawner = building_selected as! Spawner
                    let scene_spawn_point = pointForCoordinate( spawner.selected_spawn_point)
                    spawnTroll(scene_spawn_point)
                }
                else if name == "spawn_goblin"
                {
                    let spawner = building_selected as! Spawner
                    let scene_spawn_point = pointForCoordinate( spawner.selected_spawn_point)
                    spawnGoblin(scene_spawn_point)
                }
                else if name == "change_spawn_point"
                {
                    changeSpawnButtonPushed()
                }
                else if name.containsString("BlueShape_")
                {
                    let spawner = building_selected as! Spawner
                    spawner.selected_spawn_point = coordinateForPoint( touchedNode.position )
                    
                    // Clean up the flags
                    // Clean up the flags
                    for flag in flag_points
                    {
                        flag.destroy()
                    }
                    flag_points.removeAll()
                    
                    // Clean up the blue shapes
                    scene!.removeChildrenInArray(blue_positions)
                    blue_positions.removeAll()
                    
                    // Spawn new flags
                    for spawn_pos in Spawner.spawn_points
                    {
                        let scene_pos = pointForCoordinate(spawn_pos)
                        
                        if (spawn_pos.x == spawner.selected_spawn_point.x && spawn_pos.y == spawner.selected_spawn_point.y)
                        {
                            spawnFlagUp(scene_pos)
                        }
                        else
                        {
                            spawnFlagDown(scene_pos)
                        }
                    }
                    
                }
                else if name == "ok_building"
                {
                    if (can_build)
                    {
                        var building : Building?

                        switch (current_build_mode! )
                        {
                        case .RegularTower:
                            building = spawnRegularTower(temp_building!.visualComp.node.position)

                        case .FireTower:
                            building = spawnFireTower(temp_building!.visualComp.node.position)
                            
                        case .IceTower:
                            building = spawnIceTower(temp_building!.visualComp.node.position)
                            
                        case .DefenderPowerSource:
                            building = spawnDefenderPowerSource(temp_building!.visualComp.node.position)
                           
                        case .OrcBuliding:
                            building = spawnOrcBuilding(temp_building!.visualComp.node.position)
                            
                        case .GoblinBuilding:
                            building = spawnGoblinBuilding(temp_building!.visualComp.node.position)
                            
                        case .TrollBuilding:
                            building = spawnTrollBuilding(temp_building!.visualComp.node.position)
                            
                        case .AttackerPowerSource:
                            building = spawnAttackerPowerSource(temp_building!.visualComp.node.position)
                            
                        default:
                            debugPrint("Wrong Build Mode: \(current_build_mode)")
                            break
                        }
                        
                        for temp_node in tileIndicators
                        {
                            let pos = coordinateForPoint(temp_node.position)
                            let tile = Tile.getTile(tiles, pos: pos)
                            tile.building_on_tile = building!
                        }
                        
                        destroy_temp_building()
                    }
                }
                else if name == "cancel_building"
                {
                    destroy_temp_building()
                }
                else if name == "BuyButton"
                {
                    buyButtonPushed()
                }
                else if name == "Attacker BuyButton"
                {
                    attBuyButtonPushed()
                }
                else if (name == "BuyRegularTower")
                {
                    current_build_mode! = .RegularTower
                    
                    place_temp_building(make_point)
                }
                else if (name == "BuyFireTower")
                {
                    current_build_mode! = .FireTower
                    
                    place_temp_building(make_point)
                }
                else if (name == "BuyIceTower")
                {
                    current_build_mode! = .IceTower
                    
                    place_temp_building(make_point)
                }
                else if (name == "BuyDefenderPowerSource")
                {
                    current_build_mode! = .DefenderPowerSource
                    
                    place_temp_building(make_point)
                }
                else if (name == "BuyOrcBuilding")
                {
                    current_build_mode! = .OrcBuliding
                    
                    place_temp_building(make_point)
                }
                else if (name == "BuyGoblinBuilding")
                {
                    current_build_mode! = .GoblinBuilding
                    
                    place_temp_building(make_point)
                }
                else if (name == "BuyTrollBuilding")
                {
                    current_build_mode! = .TrollBuilding
                    
                    place_temp_building(make_point)
                }
                else if (name == "BuyAttackerPowerSource")
                {
                    current_build_mode! = .AttackerPowerSource
                    
                    place_temp_building(make_point)
                }
                else if name.containsString("Button")
                {
                    // Reset old clicked button
                    ButtonManager.reset_button(self.scene!, button: buttons[current_build_mode.rawValue]!)
                    
                    switch (current_build_mode!)
                    {
                    case .Orc:
                        buttons[current_build_mode.rawValue] = ButtonManager.init_button(sceneCamera, img_name: "orc_left_0", button_name: "orcButton", index: 0)
                        
                    case .None:
                        buttons[BuildMode.None.rawValue] = ButtonManager.init_button(camera!, img_name: "buy_no", button_name: "NoneButton", index: BuildMode.None.rawValue)
                
                    default:
                        break
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
            }
            else if (temp_building != nil)
            {
                place_temp_building(scenePoint)
            }

            if (!gui_element_clicked && !entity_clicked)
            {
                switch (current_build_mode! )
                {
                case .Orc:
                    spawnOrc(scenePoint)
                    
                default:
                    break
                }
            }
        }
    }
    
    var tileIndicators : [SKShapeNode] = []
    var can_build = true
    var temp_building : Building?
    
    let temp_ok_button = SKSpriteNode(texture: SKTexture(imageNamed: "buy_yes"), size: CGSize(width: 100,height: 100))
    let temp_cancel_button = SKSpriteNode(texture: SKTexture(imageNamed: "buy_no"), size: CGSize(width: 100,height: 100))
    
    func place_temp_building(point : CGPoint)
    {
        can_build = true
        if (temp_building != nil)
        {
            let backup_build_mode = current_build_mode
            destroy_temp_building()
            current_build_mode = backup_build_mode
        }
        
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        var isAttacker = false
        var isDefender = false
        
        
        // Init the tower
        switch (current_build_mode! )
        {
        case .RegularTower:
            temp_building = RegularTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, temp: true)
            isAttacker = false
            isDefender = true
        case .FireTower:
            temp_building = FireTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, temp: true)
            isAttacker = false
            isDefender = true
        case .IceTower:
            temp_building = IceTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, temp: true)
            isAttacker = false
            isDefender = true
        case .DefenderPowerSource:
            temp_building = DefenderPowerSource(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, temp: true)
            isAttacker = false
            isDefender = true
        case .OrcBuliding:
            temp_building = OrcBuilding(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, temp: true)
            isAttacker = true
            isDefender = false
        case .GoblinBuilding:
            temp_building = GoblinBuilding(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, temp: true)
            isAttacker = true
            isDefender = false
        case .TrollBuilding:
            temp_building = TrollBuilding(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, temp: true)
            isAttacker = true
            isDefender = false
        case .AttackerPowerSource:
            temp_building = AttackerPowerSource(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, temp: true)
            isAttacker = true
            isDefender = false
    
            
        default:
            debugPrint("Wrong Build Mode: \(current_build_mode)")
            return
        }
        
        let node = temp_building!.visualComp.node
        let num_vert_tiles = Int(node.frame.width / Tile.tileWidth)
        let num_horizontal_tiles = Int(node.frame.height / Tile.tileHeight)
        
        // Add the buy and cancel buttons
        let x_dist = (Tile.tileWidth * (CGFloat(num_horizontal_tiles))/2)
        let y_dist = (Tile.tileHeight * (CGFloat(num_vert_tiles)-0.25)/2)
        
        scene!.addChild(temp_ok_button)
        temp_ok_button.position = CGPointMake(node.position.x - x_dist + 0.5 * Tile.tileWidth, node.position.y - y_dist)
        temp_ok_button.zPosition = ZPosition.Tower.rawValue + 0.5
        temp_ok_button.anchorPoint = CGPointMake(0,0)
        
        scene!.addChild(temp_cancel_button)
        temp_cancel_button.position = node.position
        temp_cancel_button.position = CGPointMake(node.position.x + x_dist + 0.5 * Tile.tileWidth, node.position.y - y_dist)
        temp_cancel_button.zPosition = ZPosition.Tower.rawValue + 0.5
        temp_cancel_button.anchorPoint = CGPointMake(0,0)
        
        // Add the tiles indicating if you can build
        for (var row = 0; row < num_horizontal_tiles ; row++)
        {
            for (var column = 0; column < num_vert_tiles ; column++)
            {
                let tile_pos = int2(Int32(pos_on_grid.x + column), Int32(pos_on_grid.y + row))
                
                let temp_node = SKShapeNode(rect: CGRect(origin: CGPointMake(0,0), size: CGSize(width: Tile.tileWidth, height: Tile.tileHeight)))
                temp_node.strokeColor = UIColor.clearColor()
                temp_node.zPosition = ZPosition.Tower.rawValue + 0.25
                let temp_pos = pointForCoordinate(tile_pos)
                temp_node.position = CGPointMake(temp_pos.x, temp_pos.y )
                
                let tile = Tile.getTile(tiles, pos: tile_pos)
                let tile_ok_to_build = check_tile(tile)
                let tile_ok_to_build_att = check_tile_att(tile)
                
                
                if (tile_ok_to_build && isDefender && !isAttacker)
                {
                    can_build = can_build && true
                    temp_node.fillColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
                }
                else if (tile_ok_to_build_att && isAttacker && !isDefender)
                {
                    can_build = can_build && true
                    temp_node.fillColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
                }
                else
                {
                    can_build = false
                    temp_node.fillColor = UIColor.redColor().colorWithAlphaComponent(0.3)

                }
                
                tileIndicators.append(temp_node)
                scene!.addChild(temp_node)
            }
        }
    }

    
    func destroy_temp_building()
    {
        temp_building!.destroy()
        scene!.removeChildrenInArray(tileIndicators)
        tileIndicators.removeAll()
        
        scene!.removeChildrenInArray([temp_ok_button, temp_cancel_button])
        temp_building = nil
        
        current_build_mode! = .None
    }
    
    func check_tile(tile: Tile) -> Bool
    {
        if !(tile is DefenderTile)
        {
            return false
        }
        
        if tile.building_on_tile != nil
        {
            return false
        }
        
        return tile.powerSourceInRange
    }
    
    func check_tile_att(tile: Tile) -> Bool
    {
        if !(tile is AttackerTile)
        {
            return false
        }
        
        if (tile.building_on_tile != nil)
        {
            return false
        }
        
        return tile.powerSourceInRange
    }
    
    var side_panel_open = false
    var show_power_source_range = false
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
        
        show_power_source_range = side_panel_open
        PowerSource.visualizePowerSourceArea(self, show_shapes: side_panel_open)
    }
    
    var attack_side_panel_open = false
    func attBuyButtonPushed()
    {
        if (!attack_side_panel_open)
        {
            let slideIn = SKAction.moveByX(buy_panel_width, y: 0, duration: 1.0) // Define the action to slide it 600 units to the right
            
            sidePanel_attack.runAction(slideIn) // Run the action
            
            attack_side_panel_open = true // Set so that we don't open it multiple times
        }
        else // If it is already open, slide it back
        {
            let slideOut = SKAction.moveByX(-buy_panel_width, y: 0, duration: 1.0) // Define the action to slide it 600 units to the left
            sidePanel_attack.runAction(slideOut) // Run the action
            
            attack_side_panel_open = false
        }
        
        show_power_source_range = attack_side_panel_open
        PowerSource.visualizePowerSourceArea(self, show_shapes: show_power_source_range)
    }
    
    // MARK: Building Menu
    let slideUp = SKAction.moveBy(CGVector(dx: 0, dy: 600), duration: 1.0)
    let slideDown = SKAction.moveBy(CGVector(dx: 0, dy: -600), duration: 1.0)
    
    func close_building_menu(building: Building)
    {
        towerMenu.runAction(slideDown)
        building_menu_open = false
        building_selected = nil
        
        // Clean up
        towerMenu.removeAllChildren()
        
        // Clean up the flags
        for flag in flag_points
        {
            flag.destroy()
        }
        flag_points.removeAll()
        
        // Clean up the blue shapes
        scene!.removeChildrenInArray(blue_positions)
        blue_positions.removeAll()
    }
    
    func open_building_menu(building: Building)
    {
        towerMenu.runAction(slideUp)
        building_menu_open = true
        
        if (building is Tower)
        {
            add_tower_buttons()
        }
        else if (building is Spawner)
        {
            add_spawner_buttons()
        }
        else
        {
            add_power_source_buttons()
        }
    }
    
    var building_menu_open = false
    var building_selected : Building?
    func buildingMenuPushed(building: Building)
    {
        if (building_selected != nil)
        {
            if (building_selected!.entity_id != building.entity_id)
            {
                close_building_menu(building_selected!)
            }
        }
        building_selected = building
        
        
        if (building_menu_open)
        {
           close_building_menu(building)
        }
        else
        {
            open_building_menu(building)
        }
    }
    
    func add_tower_buttons()
    {
        let show_range = SKSpriteNode(imageNamed: "BuildingShowRange")
        show_range.xScale = 5
        show_range.yScale = 5
        show_range.zPosition = ZPosition.OverlayButton.rawValue
        show_range.position  = CGPointMake(towerMenu.frame.width / 2, tower_menu_height - show_range.frame.height - 10)
        show_range.name = "show_range_tower"
        
        towerMenu.addChild(show_range)
    }
    
    func add_spawner_buttons()
    {
        let spawner = building_selected as! Spawner
        if (building_selected is OrcBuilding)
        {
            let spawn_orc = SKSpriteNode(imageNamed: "orc_down_1")
            spawn_orc.xScale = 7
            spawn_orc.yScale = 7
            spawn_orc.zPosition = ZPosition.OverlayButton.rawValue
            spawn_orc.position  = CGPointMake(towerMenu.frame.width / 2, tower_menu_height - spawn_orc.frame.height + 80)
            spawn_orc.name = "spawn_orc"
            
            towerMenu.addChild(spawn_orc)
            
            let choose_spawn_point = SKSpriteNode(imageNamed: "BuildingChangePoint")
            choose_spawn_point.xScale = 5
            choose_spawn_point.yScale = 5
            choose_spawn_point.zPosition = ZPosition.OverlayButton.rawValue
            choose_spawn_point.position  = CGPointMake(towerMenu.frame.width / 2,
                tower_menu_height - spawn_orc.frame.height - 5 - choose_spawn_point.frame.height)
            choose_spawn_point.name = "change_spawn_point"
            
            towerMenu.addChild(choose_spawn_point)
        }
        
        else if(building_selected is GoblinBuilding)
        {
            let spawn_goblin = SKSpriteNode(imageNamed: "goblin_down_1")
            spawn_goblin.xScale = 10
            spawn_goblin.yScale = 10
            spawn_goblin.zPosition = ZPosition.OverlayButton.rawValue
            spawn_goblin.position  = CGPointMake(towerMenu.frame.width / 2, tower_menu_height - spawn_goblin.frame.height + 75)
            spawn_goblin.name = "spawn_goblin"
            
            towerMenu.addChild(spawn_goblin)
            
            let choose_spawn_point = SKSpriteNode(imageNamed: "BuildingChangePoint")
            choose_spawn_point.xScale = 5
            choose_spawn_point.yScale = 5
            choose_spawn_point.zPosition = ZPosition.OverlayButton.rawValue
            choose_spawn_point.position  = CGPointMake(towerMenu.frame.width / 2,
                tower_menu_height - spawn_goblin.frame.height - 20 - choose_spawn_point.frame.height)
            choose_spawn_point.name = "change_spawn_point"
            
            towerMenu.addChild(choose_spawn_point)
        }
        
        if (building_selected is TrollBuilding)
        {
            let spawn_troll = SKSpriteNode(imageNamed: "troll_down_1")
            spawn_troll.xScale = 10
            spawn_troll.yScale = 10
            spawn_troll.zPosition = ZPosition.OverlayButton.rawValue
            spawn_troll.position  = CGPointMake(towerMenu.frame.width / 2, tower_menu_height - spawn_troll.frame.height + 75)
            spawn_troll.name = "spawn_troll"
            
            towerMenu.addChild(spawn_troll)
            
            let choose_spawn_point = SKSpriteNode(imageNamed: "BuildingChangePoint")
            choose_spawn_point.xScale = 5
            choose_spawn_point.yScale = 5
            choose_spawn_point.zPosition = ZPosition.OverlayButton.rawValue
            choose_spawn_point.position  = CGPointMake(towerMenu.frame.width / 2,
                tower_menu_height - spawn_troll.frame.height - 20 - choose_spawn_point.frame.height)
            choose_spawn_point.name = "change_spawn_point"
            
            towerMenu.addChild(choose_spawn_point)
        }

        
        for spawn_pos in Spawner.spawn_points
        {
            let scene_pos = pointForCoordinate(spawn_pos)
            
            if (spawn_pos.x == spawner.selected_spawn_point.x && spawn_pos.y == spawner.selected_spawn_point.y)
            {
                spawnFlagUp(scene_pos)
            }
            else
            {
                spawnFlagDown(scene_pos)
            }
        }
    }
    
    var flag_points: [Building] = []
    func spawnFlagUp (point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPointFromTemp(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        
        // Init the tower
        let building = FlagUp(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
        
        // Keep track of it
        flag_points.append( building )
    }
    
    func spawnFlagDown (point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPointFromTemp(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        
        // Init the tower
        let building = FlagDown(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
        
        // Keep track of it
        flag_points.append( building )
    }

    
    func changeSpawnButtonPushed()
    {
        let spawner = building_selected as! Spawner
        
        for spawn_pos in Spawner.spawn_points
        {
            let scene_pos = pointForCoordinate(spawn_pos)
            let tile = Tile.getTile(tiles, pos: spawn_pos)
            
            if (tile.powerSourceInRange)
            {
                if (spawn_pos.x == spawner.selected_spawn_point.x && spawn_pos.y == spawner.selected_spawn_point.y)
                {
                    spawnFlagUp(scene_pos)
                }
                else
                {
                    spawn_blue_position(scene_pos)
                }
            }
        }
    }
    
    var blue_positions : [SKShapeNode] = []
    func spawn_blue_position(point: CGPoint)
    {
        let shape = SKShapeNode(rect: CGRect(origin: CGPointMake(0,0), size: CGSize(width: Tile.tileWidth, height: Tile.tileHeight)))
        
        shape.position = point
        shape.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
        shape.strokeColor = UIColor.clearColor()
        
        shape.zPosition = ZPosition.Overlay.rawValue
        shape.name = "BlueShape_\(blue_positions.count)"
        blue_positions.append(shape)
        scene?.addChild(shape)
    }

    
    func add_power_source_buttons()
    {
        let show_range = SKSpriteNode(imageNamed: "BuildingShowRange")
        show_range.xScale = 5
        show_range.yScale = 5
        show_range.zPosition = ZPosition.OverlayButton.rawValue
        show_range.position  = CGPointMake(towerMenu.frame.width / 2, tower_menu_height - show_range.frame.height - 10)
        show_range.name = "show_range_power_source"
        
        towerMenu.addChild(show_range)
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let currentLocation = touch.locationInView(self.view)
            let scenePoint = scene!.convertPointFromView(currentLocation)
            
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
            
            if (temp_building != nil)
            {
                place_temp_building(scenePoint)
            }
            else
            {
                sceneCamera.position = CGPointMake( new_x, new_y )
            }
            
        }
    }
    
    func timeInMinutesSeconds (seconds : Int) -> (Int, Int)
    {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func coordinateForPointFromTemp(point: CGPoint) -> int2
    {
        return int2(Int32( (point.x + (Tile.tileWidth/2)) / Tile.tileWidth), Int32((point.y  + (Tile.tileHeight/2)) / Tile.tileHeight))
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
        if (childOf == "AttackSidePanel")
        {
            sidePanel_attack.addChild(uiNode)
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
        if (childOf == "AttackSidePanel")
        {
            sidePanel_attack.addChild(uiLabelNode)
        }
        
    }
    
    // MARK: Spawn methods for different units
    
    func spawnOrc(point: CGPoint)
    {
        if (goldCount >= Orc.cost)
        {
            // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
            let pos_on_grid = coordinateForPoint(point)
            
            // Fix the position to be on the grid
            let fixed_pos = pointForCoordinate(pos_on_grid)
            let tile = Tile.getTile(tiles, pos: pos_on_grid)
            debugPrint(tile.position)
            
            if (tile is MazeTile)
            {
                // Init the orc
                let orc = Orc(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, speed: 1)
                
                // Keep track of it in a dictionary
                all_units[orc.entity_id] = orc
                
                goldCount -= Orc.cost
            }
            else
            {
                debugPrint("Not a maze tile!")
            }
        }
    }
    
    func spawnGoblin(point: CGPoint)
    {
        if (goldCount >= Goblin.cost)
        {
            // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
            let pos_on_grid = coordinateForPoint(point)
            
            // Fix the position to be on the grid
            let fixed_pos = pointForCoordinate(pos_on_grid)
            let tile = Tile.getTile(tiles, pos: pos_on_grid)
            if (tile is MazeTile)
            {
                // Init the orc
                let goblin = Goblin(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, speed: 0.7)
                
                // Keep track of it in a dictionary
                all_units[goblin.entity_id] = goblin
                
                goldCount -= Goblin.cost
            }
            else
            {
                debugPrint("Not a maze tile!")
            }
        }
    }
    
    func spawnTroll(point: CGPoint)
    {
        if (goldCount >= Troll.cost)
        {
            // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
            let pos_on_grid = coordinateForPoint(point)
            
            // Fix the position to be on the grid
            let fixed_pos = pointForCoordinate(pos_on_grid)
            let tile = Tile.getTile(tiles, pos: pos_on_grid)
            if (tile is MazeTile)
            {
                // Init the orc
                let troll = Troll(scene: self, grid_position: pos_on_grid, world_position: fixed_pos, speed: 1.4)
                
                // Keep track of it in a dictionary
                all_units[troll.entity_id] = troll
                
                goldCount -= Troll.cost
            }
            else
            {
                debugPrint("Not a maze tile!")
            }
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
            debugPrint("Not a goal tile!")
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
    
    func spawnDefenderPowerSource (point: CGPoint, spawn_free: Bool = false) -> Building?
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPointFromTemp(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the tower
            let building = DefenderPowerSource(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[building.entity_id] = building
            if (!spawn_free)
            {
                goldCount -= building.buildingCost
                PowerSource.visualizePowerSourceArea(self, show_shapes: true)
            }
            
            return building
        }
        else
        {
            debugPrint("Not a defender tile!")
            return nil
        }
    }
    
    func spawnRegularTower (point: CGPoint) -> Building?
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPointFromTemp(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the tower
            let tower = RegularTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[tower.entity_id] = tower
            goldCount -= tower.buildingCost
            
            return tower
        }
        else
        {
            debugPrint("Not a defender tile!")
            
            return nil
        }
        
        
    }

    func spawnFireTower (point: CGPoint) -> Building?
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPointFromTemp(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the tower
            let tower = FireTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[tower.entity_id] = tower
            goldCount -= tower.buildingCost
            
            return tower
        }
        else
        {
            debugPrint("Not a defender tile!")
            
            return nil
        }
    }
    
    func spawnIceTower (point: CGPoint) -> Building?
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPointFromTemp(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the tower
            let tower = IceTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[tower.entity_id] = tower
            goldCount -= tower.buildingCost
            
            return tower
        }
        else
        {
            debugPrint("Not a defender tile!")
            
            return nil
        }
    }
    
    
    func spawnAttackerPowerSource (point: CGPoint, spawn_free: Bool = false) -> Building?
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPointFromTemp(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is AttackerTile)
        {
            // Init the tower
            let building = AttackerPowerSource(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[building.entity_id] = building
            
            if (!spawn_free)
            {
                goldCount -= building.buildingCost
                PowerSource.visualizePowerSourceArea(self, show_shapes: true)
            }
            
            return building
        }
        else
        {
            debugPrint("Not a attacker tile!")
            return nil
        }
    }
    
    func spawnOrcBuilding (point: CGPoint) -> Building?
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPointFromTemp(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is AttackerTile)
        {
            // Init the tower
            let building = OrcBuilding(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[building.entity_id] = building
            goldCount -= building.buildingCost
            
            return building
        }
        else
        {
            debugPrint("Not a attacker tile!")
            
            return nil
        }
        
    }

    func spawnGoblinBuilding (point: CGPoint) -> Building?
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPointFromTemp(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is AttackerTile)
        {
            // Init the tower
            let building = GoblinBuilding(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[building.entity_id] = building
            goldCount -= building.buildingCost
            
            return building
        }
        else
        {
            debugPrint("Not a attacker tile!")
            
            return nil
        }
        
    }
    
    func spawnTrollBuilding (point: CGPoint) -> Building?
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPointFromTemp(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is AttackerTile)
        {
            // Init the tower
            let building = TrollBuilding(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[building.entity_id] = building
            goldCount -= building.buildingCost
            
            return building
        }
        else
        {
            debugPrint("Not a attacker tile!")
            
            return nil
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