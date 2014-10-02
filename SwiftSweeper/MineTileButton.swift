//
//  MineTileButton.swift
//  SwiftSweeper
//
//  Created by Chuck Gaffney on 9/29/14.
//
//  used to cast button functonality over a Tile object

import UIKit

class MineTileButton : UIButton {
    var tile:Tile
    let tileSize:CGFloat
    var isFlagged = false
    
    init(tileButton:Tile, size:CGFloat) {
        self.tile = tileButton
        self.tileSize = size
        
        let x = CGFloat(self.tile.column) * tileSize
        let y = CGFloat(self.tile.row) * tileSize
        let tileBoundingFrame = CGRectMake(x, y, tileSize, tileSize)
        
        super.init(frame: tileBoundingFrame)
    }
    
    //needed since XCode beta 5; just a call to a default init() to maintain the UIButton object hieriarchy and type safety implemented by Swift
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //button text; 
      //replace button with an SKSprite for better GUI interface?
    func getTileLabelText() -> String {
        if !self.tile.isAMine {
            if self.tile.nearbyMines == 0 {
                return "0"
            }else {
                return "\(self.tile.nearbyMines)"
            }
        }
        return "💥"
    }
    
}
