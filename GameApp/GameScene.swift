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

var lifeCount : Int = 10
var goldCount : Int = 0
var gameOver : Bool = false

class GameScene: SKScene
{
    var sceneCamera : SKCameraNode = SKCameraNode()
    
    var max_x : CGFloat = 0.0
    var min_x : CGFloat = 0.0
    var max_y : CGFloat = 0.0
    var min_y : CGFloat = 0.0
    
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
    var livesImageTexture : SKTexture!
    var goldImage : SKSpriteNode!
    var livesImage : SKSpriteNode!
    
    var goldLabel : SKLabelNode!
    var livesLabel : SKLabelNode!
    var timeLabel : SKLabelNode!
    var endGameLabel : SKLabelNode!
    
    var tileNums : [[Int]]!
    var tiles : [[Tile]]!
    
    let debug = true
    
    // MARK: Placeholder stuff, used to support demo
    
    enum buildMode
    {
        case Orc
        case Tower
    }
    var current_build_mode : buildMode!
    var orcButton: SKSpriteNode!
    var towerButton: SKSpriteNode!
    
    func reset_orc_button()
    {
        self.removeChildrenInArray([orcButton])
        orcButton.removeAllActions()
        
        init_orc_button()
    }
    
    func init_orc_button()
    {
        orcButton = SKSpriteNode(texture: SKTexture(imageNamed: "left_0"))
        orcButton.name = "orcButton"
        orcButton.size = CGSize(width: 64*3 ,height: 64*3)
        orcButton.position = CGPointMake(-850, -1250)
        orcButton.zPosition = 3
        
        sceneCamera.addChild(orcButton)
    }
    
    func reset_tower_button()
    {
        self.removeChildrenInArray([towerButton])
        towerButton.removeAllActions()
        
        init_tower_button()
    }
    
    func init_tower_button()
    {
        towerButton = SKSpriteNode(texture: SKTexture(imageNamed: "BasicTower"))
        towerButton.name = "towerButton"
        towerButton.size = CGSize(width: 64*3,height: 64*3)
        towerButton.position = CGPointMake(-850+164, -1250)
        towerButton.zPosition = 3
        
        sceneCamera.addChild(towerButton)
    }
    
    let colorize = SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 0.5, duration: 0.5)    
    override func didMoveToView(view: SKView)
    {
        // Example of how to send a request.
        send_request("/")
        
        sceneCamera.position = CGPointMake(frame.width/2, frame.height/2)
        self.addChild(sceneCamera)
        
        sceneCamera.xScale = 0.5
        sceneCamera.yScale = 0.5
        
        let camera_viewport_width = frame.width * sceneCamera.xScale
        let camera_viewport_height = frame.height * sceneCamera.yScale
        
        let camera_half_width = (camera_viewport_width / 2 )
        let camera_half_height = (camera_viewport_height / 2 )
        
        max_x = frame.width - camera_half_width
        min_x = camera_half_width - 1/6*frame.width
        
        max_y = frame.height - camera_half_height
        min_y = 0 + camera_half_height
        
        self.camera = sceneCamera;

        // Init the orc and tower buttons
        init_orc_button()
        init_tower_button()
        
        // Start in orc mode
        self.current_build_mode = .Orc
        orcButton.runAction(colorize)

        getJSONFile()
        
        // Add the 'Gold Label' to the camera view and place it in the top left corner
        goldLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        goldLabel.text = String(goldCount)
        goldLabel.fontSize = 150
        goldLabel.fontColor = UIColor(red: 248/255, green: 200/255, blue: 0, alpha: 1)
        goldLabel.position = CGPointMake(-825, 1290)
        sceneCamera.addChild(goldLabel)
     
        // Add the 'Lives Label' to the camera view and place it in the top right corner
        livesLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        livesLabel.text = String(lifeCount)
        livesLabel.fontSize = 150
        livesLabel.fontColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        livesLabel.position = CGPointMake(3225, 1290)
        sceneCamera.addChild(livesLabel)
        
        // Add the 'Time Label' to the camera view and place it in the middle
        timeLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        timeLabel.fontSize = 150
        timeLabel.fontColor = UIColor.whiteColor()
        timeLabel.position = CGPointMake(1000, 1300)
        sceneCamera.addChild(timeLabel)
        
        // Add the gold image texture
        goldImageTexture = SKTexture(imageNamed: "GoldImage")
        goldImage = SKSpriteNode(texture: goldImageTexture)
        goldImage.position = CGPointMake(-1100, 1350)
        goldImage.xScale = 8
        goldImage.yScale = 8
        sceneCamera.addChild(goldImage)
        
        // add the lives image texture
        livesImageTexture = SKTexture(imageNamed: "LivesImage")
        livesImage = SKSpriteNode(texture: livesImageTexture)
        livesImage.position = CGPointMake(2950, 1350)
        livesImage.xScale = 8
        livesImage.yScale = 8
        sceneCamera.addChild(livesImage)
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
            
            var gui_element_clicked = false
            var entity_clicked = false
            
            if let name = touchedNode.name
            {
                if name == "orcButton"
                {
                    gui_element_clicked = true
                    
                    current_build_mode = .Orc
                    orcButton.runAction(colorize)
                    reset_tower_button()
                    
            
                    
                    debugPrint("Orc Button clicked")
                }
                else if name == "towerButton"
                {
                    gui_element_clicked = true
                    
                    current_build_mode = .Tower
                    towerButton.runAction(colorize)
                    reset_orc_button()
                    
                    debugPrint("Tower Button clicked")
                }
                
                if let entity_id = Int(name)
                {
                    entity_clicked = true
                    debugPrint(entity_id)
                    
                    if let building_entity = all_buildings[entity_id]
                    {
                        (building_entity as! Tower).visualizeMazeTiles()
                    }
                }
            }
            
            if (!gui_element_clicked && !entity_clicked)
            {
                if (current_build_mode == .Orc)
                {
                    spawnOrc(scenePoint)
                }
                else
                {
                    spawnBasicTurret(scenePoint)
                }
                
                if (debug)
                {
                    let pos_on_grid = coordinateForPoint(scenePoint)
                    let tile = Tile.getTile(tiles, pos: pos_on_grid)
                    
                    debugPrint("Pos: \(pos_on_grid) Type: \(tileNums![map_height-Int( pos_on_grid.y)-1][Int(pos_on_grid.x)]) Option: \(tile.moveOpt)")
                    debugPrint( tile )
                }
            }
        }
    }
    
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
    
    func spawnBasicTurret(point: CGPoint)
    {
        // Find the location on the grid (int2 [2 Int32s] in the underlying grid)
        let pos_on_grid = coordinateForPoint(point)
        
        // Fix the position to be on the grid
        let fixed_pos = pointForCoordinate(pos_on_grid)
        let tile = Tile.getTile(tiles, pos: pos_on_grid)
        if (tile is DefenderTile)
        {
            // Init the orc
            let tower = BasicTower(scene: self, grid_position: pos_on_grid, world_position: fixed_pos)
            
            // Keep track of it in a dictionary
            all_buildings[tower.entity_id] = tower
        }
        else
        {
            debugPrint("Not a defender tile!")
        }
    }
    
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
    
    func updateGoldByTime()
    {

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
        endGameLabel.zPosition = 4
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
    
    func timeInMinutesSeconds (seconds : Int) -> (Int, Int) {
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
                
                // Put the values from file into a 2d array
                tileNums = [[Int]](count: map_height, repeatedValue: [Int](count: map_width, repeatedValue: 0))
                
                debugPrint("Map dimensions: \(map_height) x \(map_width)")
                let layers = jsonContent["layers"] as! NSArray
                
                // Parse bottom layer first
                let bottom_layer = layers[0] as! NSDictionary
                let bottom_layer_data = bottom_layer["data"] as! NSArray
                
                for row in 0...(map_height-1)
                {
                    for column in 0...(map_width-1)
                    {
                        let flat_index = column + row * map_width
                        tileNums[row][column] = bottom_layer_data[flat_index] as! Int
                        
                        let sandTileType = 11
                        if (column > 32 && tileNums[row][column] == sandTileType)
                        {
                            tileNums[row][column] = 0
                        }
                    }
                }
                
                let mountain_layer = layers[1] as! NSDictionary
                let mountain_layer_data = mountain_layer["data"] as! NSArray
                
                for row in 0...(map_height-1)
                {
                    for column in 33...(map_width-1)
                    {
                        let flat_index = column + row * map_width
                        let current_num: Int = mountain_layer_data[flat_index] as! Int
                        
                        if (current_num != 0)
                        {
                            tileNums[row][column] = current_num
                        }
                    }
                }
                
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
                        let current_num : Int = tileNums[row][column] - 1
                        let pos = int2(Int32(column), Int32(row))
                        
                        tiles[row][column] = Tile.makeTileFromType(current_num, pos: pos)
                    }
                }
                
                // Fill it with tile direction events parsed from the JSON element directly
                let arrows_layer = layers[3] as! NSDictionary
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
        }
        catch
        {
            debugPrint("Error reading JSON file")
        }
    }
    
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