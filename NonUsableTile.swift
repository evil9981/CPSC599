//
//  NonUsableTile.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class NonUsableTile: Tile
{
    override init(position: int2)
    {
        super.init(position: position)
        self.type = TileType.NoneUsable
        self.moveOpt = TileOpts.None
    }
}
