//
//  DefenderTile.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//
import SpriteKit
import GameplayKit

class DefenderTile: Tile
{
    override init(position: int2)
    {
        super.init(position: position)
        self.type = TileType.Defender
        self.moveOpt = TileOpts.None
    }
}
