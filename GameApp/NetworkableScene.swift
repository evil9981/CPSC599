//
//  NetworkableScene.swift
//  GameApp
//
//  Created by User on 2016-02-03.
//  Copyright © 2016 Eric. All rights reserved.
//

import Foundation

protocol NetworkableScene
{
    func updateFromNetwork(msg: String)
    
    func writeToNet(msg: NetMessage)
}
