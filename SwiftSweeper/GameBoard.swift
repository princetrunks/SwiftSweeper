//
//  TileBoard.swift
//  SwiftSweeper
//
//  Created by Chuck Gaffney on 9/29/14.
//
// game Model logic for the board of Tiles

import Foundation


class GameBoard {
    
    //default board size 10 x 10 game board
    
    enum difficulty{
        case easy, medium, hard
    }
    
    var boardSize_ = 10
    
    var totalTiles_ : Int
    
    var numOfTappedTilesToWin_ : Int?
    
    // 1/mineRandomizer chance of a tile becoming a mine; default is 10
    var mineRandomizer:UInt32 = 10
    
    //2D array, Matrix
    var tiles:[[Tile]] = []
    
    
    //counts the mines on the board; used in win calculation
    var mineCount = 0
    
    //default init with default properties
    init(selectedDifficulty:difficulty){
        
        totalTiles_ = boardSize_ * boardSize_ // since it's an even sqaure board
        
        implementDifficulty(selectedDifficulty)
        
        //2 layer for-loop to create the default 10 X 10 board
        for row in 0 ..< boardSize_ {
            var tilesRow:[Tile] = []
                for col in 0 ..< boardSize_ {
                    let tile = Tile(row: row, col: col)
                    tilesRow.append(tile)
                }
            tiles.append(tilesRow)
        }
        
        resetBoard()
        
    }
    
    //the lower the mineRandomizer, the more frequent mines will be created
    func implementDifficulty(choosenDifficulty:difficulty){
        
        switch (choosenDifficulty) {
        case .easy:
            mineRandomizer = 8
            break
            
        case .medium:
            mineRandomizer = 5
            break
            
        case .hard:
            mineRandomizer = 3
            break

         default:
    
        mineRandomizer = 10
    
            break
        }
    }
    
    func createRandomMineTiles(tile: Tile) {
        tile.isAMine = ((arc4random()%mineRandomizer) == 0)
        
        //increment mine count if the selected tile became a mine
        if tile.isAMine{
            mineCount++
        }
        
    }
    
    func calculateNearbyMines(currentTile : Tile) {
        // calculate the nearby tiles
        // based on the location on the board, it could be as much as 8 ajacent tiles
        let surroundingTiles = getNearbyTiles(currentTile)
        
        //start count of nearby mines at 0
        var nearbyMines = 0
        
        // for each neighbor with a mine, add 1 to this square's count
        for nearbyTile in surroundingTiles {
            if nearbyTile.isAMine {
                nearbyMines++
            }
        }
        
        //assign this number to each tiles to then be revealed for the player once unlocked
        currentTile.nearbyMines = nearbyMines
    }

    
    
    //returns an array of Tile objects that surround the selected Tile; could be 3-8 tiles based on the location of the selected tiles on the board
    func getNearbyTiles(selectedTile : Tile) -> [Tile] {
        
        //an array of Tile objects
        var nearbyTiles:[Tile] = []
        
        // array of (row,column) tuples that repesent all possible surrounding Tile locations
        let nearbyTileOffsets =
        
        [(-1,-1), //bottom left corner from selected tile
         (0,-1),  //directly below
         (1,-1),  //bottom right corner
         (-1,0),  //directly left
         (1,0),   //directly right
         (-1,1),  //top left corner
         (0,1),   //directly above
          (1,1)]  //top right corner
        
        for (rowOffset,columnOffset) in nearbyTileOffsets {
            
            //optional since tiles in the corners/edges could have less than 8 surrounding tiles and thus could have a nil value
            let ajacentTile:Tile? = getAjacentTileLocation(selectedTile.row+rowOffset, col: selectedTile.column+columnOffset)
           
            
            //if validAjacentTile isn't nil, add the Tile object to the nearby Tile array
            if let validAjacentTile = ajacentTile {
                nearbyTiles.append(validAjacentTile)
            }
        }
        return nearbyTiles
    }
    
    
    // returns the location of an ajacent tile via a Tile (row/col) type; iterated through the possible offsets.
    func getAjacentTileLocation(row : Int, col : Int) -> Tile? {
        
        //checks if the location selected by the offset is in bounds to the board's size
        if row >= 0 && row < boardSize_ && col >= 0 && col < boardSize_ {
            return tiles[row][col]
        }
        
        //returns a nil Tile if the location is out of bounds/the offset pointed to a nonexistant tile, 
        //ie: the selected tile was a corner tile that would only have 3 ajacent tiles.
        else {
            return nil
        }
    }
    
    
    //resets all tiles to be down/not tapped in board matrix
    func resetBoard() {
        
        mineCount = 0
        
        for row in 0 ..< boardSize_ {
            for column in 0 ..< boardSize_ {
                self.createRandomMineTiles(tiles[row][column])
                tiles[row][column].isTileDown = false
                
            }
        }
        
        //saves the number of tiles that are not mines; used with the player's move count to determine a win
        numOfTappedTilesToWin_ = totalTiles_ - mineCount
        
        /*=============
        
        could also write the for-loops in C style loop as oppose to the Swift styled for-in loop;
        
        ie:
        
        for var row = 0; index < boardSize_; ++row {
          for var column = 0; column < boardSize_; ++column {
                          .........
             }
        }
        
        ================
        */
        
        // counts the nearby tiles that have mines
        //done in resetBoard() as oppose to during the Tile's reveal so that all nearby mine numbers are already known internally
        for row in 0 ..< boardSize_ {
            for column in 0 ..< boardSize_ {
                self.calculateNearbyMines(tiles[row][column])
            }
        }
        
        
    }



}