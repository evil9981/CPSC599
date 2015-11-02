//
//  AttackScene.swift
//  GameApp
//  Created by User on 2015-10-21.
//  Copyright © 2015 Eric. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene
{
    var sceneCamera : SKCameraNode = SKCameraNode()
    
    var max_x : CGFloat = 0.0
    var min_x : CGFloat = 0.0
    var max_y : CGFloat = 0.0
    var min_y : CGFloat = 0.0
    
    var all_units : Dictionary<Int, Unit> = Dictionary<Int, Unit>()
    
    var tileNums : [[Int]]!
    var tiles : [[Tile]]!
    
    override func didMoveToView(view: SKView)
    {
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
            
            // Get position in the world (CGFloats in the whole scene)
            
            spawnOrc(scenePoint)
            let pos_on_grid = coordinateForPoint(scenePoint)
            
            let tile = Tile.getTile(tiles, pos: pos_on_grid)
            debugPrint("Pos: \(pos_on_grid) Type: \(tileNums![map_height-Int( pos_on_grid.y)-1][Int(pos_on_grid.x)]) Option: \(tile.moveOpt)")
            debugPrint( tile )
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
    
    override func update(currentTime: NSTimeInterval)
    {
        for unit in all_units.values
        {
            unit.update()
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
}