//
//  Tile.swift
//  SwiftSweeper
//
//  Created by chuck on 9/29/14.
//  Copyright (c) 2014 Chuck Gaffney. All rights reserved.
//

import Foundation

class Tile{
    
    // row/column static properties
    
    let row : Int
    let column : Int
    
    //bool flags
    var isTileDown = false
    var isFlagged = false
    
    var isAMine = false
    
    //Mines counter
    var nearbyMines:Int = 0
    
    init(row:Int, col: Int){
        
        self.row = row
        self.column = col
        
    }
    
}