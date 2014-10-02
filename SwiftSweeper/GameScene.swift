//
//  GameScene.swift
//  SwiftSweeper
//  A Swift version of MineSweeper
//  A simple programming test game
//  Created by Chuck Gaffney on 9/28/14.
//

import SpriteKit

class GameScene: SKScene {
    
    //====PROPERTIES====
    
    enum gameState{
        
        case Instructions, DifficultyMenu, MineTap , FlagPlanting, GameOver, WIN
        
    }
    
    //an example of Swift's mutating functions within an enum type; used in this case for just simple flag button
    // a bit overkill for a single on/off button; just a show of additional code functionality
    enum OnOffSwitch {
        case Off, On
        mutating func toggle() {
            switch self {
            case Off:
                self = On
            case On:
                self = Off
            }
        }
    }
  
    var currentGameState_ : gameState!
    
    var currentDifficulty_ : GameBoard.difficulty?
    
    
    //Views
    weak var stageView_: SKView!    //background view, where the game board takes place
    var  backDropView_ : UIView!
    
    var HUD: SKNode!
    
    var mineBoard_: GameBoard!
    
    //2D array of buttons to cast over Tiles
    var tileButtons_:[MineTileButton] = []
    
    
    //labels
    let timerLabel_ = SKLabelNode(fontNamed:"DamascusBold")
    
    let statusLabel_ = SKLabelNode(fontNamed:"Georgia-BoldItalic")
    
    let movesLabel_ = SKLabelNode(fontNamed:"DamascusBold")

    
    //button used for planting flags
    let flagButton_ = SKSpriteNode(imageNamed:"flagButton.png")
    var flagSwitch_ = OnOffSwitch.Off
    
    let flagStatusLabel_ = SKLabelNode(fontNamed:"Chalkduster")
    
    //timer properties 
     //Note: timer could be it's own class
    var playerTimer_:NSTimer?
    var timerStopped_ = true
    
    //Instructions Image
    let instructionsSprite_ = SKSpriteNode(imageNamed: "SwiftSweeperInstructions")
    
    //bool used tell if first game already started; used to prevent board from being reinitialized during a retry
    var didFirstGameLoad_ = false
    
    //difficulty menu buttons
    var difficultySprite_ : SKSpriteNode?
    
    let difficultyButton_   = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let easyButton_   = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let mediumButton_   = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let hardButton_   = UIButton.buttonWithType(UIButtonType.System) as UIButton
    
    //player time records
    var bestTimeEasy_:Int?, bestTimeMedium_:Int?, bestTimeHard_:Int?
    
    var gotNewTimeRecord_:Bool = false

    

    //Getters
    
    var playerTime_:Int = 0 {
        didSet {
            self.timerLabel_.text = "Time: \(playerTime_)"
            
            //max time of 9999 seconds
            if playerTime_ >= 9999{
                
                playerTime_ = 9999
                
                
            }
          }
    }
    
    var moves_:Int = 0 {
        didSet {
            
            //automatically update the moves_ text when moves_ changes
            self.movesLabel_.text = "Moves: \(moves_)"
            
            //begin timer once player makes the first move
              //also checks game status in the event the first move hits a mine
            if moves_ == 1 && currentGameState_ == .MineTap {
                beginTimer()
            }
            
            //Player Wins if they unlock all of the tiles that are not mines
               //checks for GameOver to cover the instance where the player hits a mine in their final move
            if (moves_>=mineBoard_.numOfTappedTilesToWin_ && currentGameState_ != .GameOver){
                
                killTimer()
                winSequence()
                
            }
        }
    }
    
    //===================================
    
    
    //----MAIN Function---
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.whiteColor()
        
        stageView_ = view
        
        loadInstructions()
        
        
    }
    
    //could also go in it's own class/node for better control / separation for main game board
    func loadHUD(){
        
        HUD = SKNode()
        
        loadTitleText()
        
        loadFlagButton()
        
        self.addChild(HUD)
        
    }
    
    func loadInstructions(){
        
        instructionsSprite_.zPosition = 100
        instructionsSprite_.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height / 2)
        instructionsSprite_.setScale(0.45)
        instructionsSprite_.alpha = 0.0
        
        self.addChild(instructionsSprite_)
        
        //fade-in transition
        instructionsSprite_.runAction(SKAction.fadeInWithDuration(1.0))
        
        currentGameState_ = .Instructions
    }
    
    func removeInstructions(){
        
        let transitionTime = 0.6
        
        //fade and delete instructions
        instructionsSprite_.runAction(SKAction.sequence(
            [SKAction.fadeOutWithDuration(transitionTime),
            SKAction.runBlock(deleteInstructions)]
            ))
        
        //move to choosing the difficulty
        
        //delayed to give a little better transision.
        let delayedTransition = NSTimer.scheduledTimerWithTimeInterval(transitionTime, target: self, selector: Selector("chooseDifficultyMenu"), userInfo: nil, repeats: false)
        
        //chooseDifficultyMenu()
    }
    
    func deleteInstructions(){
        instructionsSprite_.removeFromParent()
    }
    
    
    //loads the buttons to select difficulty
      //Note: could be cleaned up more & simplified.
    func chooseDifficultyMenu(){
        
        self.currentGameState_ = .DifficultyMenu
        
        //BUG: difficultySprite_ hidden under stageView_.. using yOffset to shift the buttons up for now
        var yOffset:CGFloat
        
        if(didFirstGameLoad_){
            yOffset = 40
        }
        else{
            yOffset = 0
        }
        
        backDropView_ = UIView()
        
        //"fades" the background a bit to make the menu stick out
        backDropView_.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        
        backDropView_.backgroundColor = UIColor.blackColor()
        
        backDropView_.alpha = 0.4
        
        //backDropView_.layer.zPosition
        
        
        //only place backdrop to darken already loaded game stage
        if(didFirstGameLoad_){
        stageView_.addSubview(backDropView_)
        }
        
        //template image used for the buttons; would rather use sprites in images folder though
        let image = UIImage(named: "chooseDifficulty")
        
        difficultyButton_.frame = CGRectMake(15, 40, image.size.width * 0.58, image.size.height * 0.6)
        
        //Bug: Doesn't show after stage loads
        difficultySprite_ = SKSpriteNode(imageNamed: "chooseDifficulty")
        difficultySprite_?.position = CGPointMake(self.frame.width/2, self.frame.height*0.9)
        difficultySprite_?.zPosition = 100
        self.addChild(difficultySprite_!)
        
        easyButton_.frame = CGRectMake(15, 120-yOffset, image.size.width * 0.58, image.size.height * 0.6)
        easyButton_.addTarget(self, action: "easyDifficultySelected", forControlEvents:.TouchUpInside)
        easyButton_.setTitle("EASY", forState: .Normal)
        easyButton_.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        easyButton_.backgroundColor = UIColor.greenColor()
        
        mediumButton_.frame = CGRectMake(15, 220-yOffset, image.size.width * 0.58, image.size.height * 0.6)
        mediumButton_.addTarget(self, action: "mediumDifficultySelected", forControlEvents:.TouchUpInside)
        mediumButton_.setTitle("MEDIUM", forState: .Normal)
        mediumButton_.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mediumButton_.backgroundColor = UIColor.orangeColor()
        
        hardButton_.frame = CGRectMake(15, 320-yOffset, image.size.width * 0.58, image.size.height * 0.6)
        hardButton_.addTarget(self, action: "hardDifficultySelected", forControlEvents:.TouchUpInside)
        hardButton_.setTitle("HARD", forState: .Normal)
        hardButton_.setTitleColor(UIColor.blackColor(), forState: .Normal)
        hardButton_.backgroundColor = UIColor.redColor()
        
    

        stageView_.addSubview(difficultyButton_)
        stageView_.addSubview(easyButton_)
        stageView_.addSubview(mediumButton_)
        stageView_.addSubview(hardButton_)

        
    }
    
    func easyDifficultySelected(){
        currentDifficulty_ = .easy
        removeDifficultyMenu()
    }
    
    func mediumDifficultySelected(){
        currentDifficulty_ = .medium
        removeDifficultyMenu()
    }
    
    func hardDifficultySelected(){
        currentDifficulty_ = .hard
        removeDifficultyMenu()
    }
    
    
    func removeDifficultyMenu(){
        
        difficultySprite_!.removeFromParent()
        difficultyButton_.removeFromSuperview()
        easyButton_.removeFromSuperview()
        mediumButton_.removeFromSuperview()
        hardButton_.removeFromSuperview()
        
        if(didFirstGameLoad_){
            backDropView_.removeFromSuperview()
        }
        
        //delayed to give a little better transision.  Could be improved with scene transitions and SKAction fades
        let delayedStart = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("delayedGameStart"), userInfo: nil, repeats: false)
        
    }
    
    func delayedGameStart(){
        
        //two types of beginnings in order eventually have the abilty to do all of the asset loading in beginGame() while resetBoard() can simply reuse assets without needing to reload / reallocate assets
        
        //Note: could also make use of restarting/transitioning scenes; making sure strong variables are not still around to cause a memory leak
        
        if(!didFirstGameLoad_){
            beginGame()
        }
        else{
            resetBoard()
        }
        
        
    }
    
    
    
    func beginGame(){
        
        didFirstGameLoad_ = true
        loadHUD()
        initializeBoard()
        self.backgroundColor = UIColor.lightGrayColor()
        
        currentGameState_ = .MineTap
        
    }
    
    func beginTimer(){
        
        playerTimer_ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("incrementTimer"), userInfo: nil, repeats: true)
        
        timerStopped_ = false
        
    }
    
    func incrementTimer(){
        playerTime_++
    }
    
    func initializeBoard() {
        
        mineBoard_ = GameBoard(selectedDifficulty: currentDifficulty_!)
        
        //beginTimer()
        
        //println("BoardSize: \(mineBoard.boardSize_)")
        
        for row in 0 ..< mineBoard_.boardSize_ {
            for col in 0 ..< mineBoard_.boardSize_ {
                
                let singleTile = mineBoard_.tiles[row][col]
                
                let tileSize:CGFloat = self.stageView_.frame.width / CGFloat(mineBoard_.boardSize_)
                
                let tileButton = MineTileButton(tileButton: singleTile, size: tileSize)
                
                tileButton.setTitle("◻", forState: .Normal)
                tileButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
                tileButton.backgroundColor = UIColor.whiteColor()
                tileButton.addTarget(self, action: "tileButtonTapped:", forControlEvents: .TouchUpInside)
                
                self.stageView_.addSubview(tileButton)
                
                self.tileButtons_.append(tileButton)
            }
        }
        
    }
    
    //Text/notifications in the HUD
    func loadTitleText(){
        let titleLabel = SKLabelNode(fontNamed:"Chalkduster")
        titleLabel.text = "~Swift Sweeper~"
        titleLabel.fontSize = 45
        titleLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:self.frame.height*0.25)
        
        HUD.addChild(titleLabel)
        
        //default status text
        statusLabel_.text = ""
        statusLabel_.fontSize = 40
        statusLabel_.position = CGPoint(x:CGRectGetMidX(self.frame), y:self.frame.height*0.15)
        
        HUD.addChild(statusLabel_)
        
        //text that tells the player if when they are in Flag Mode
        flagStatusLabel_.text = ""
        flagStatusLabel_.zPosition = 50
        flagStatusLabel_.fontSize = 30
        flagStatusLabel_.position = CGPoint(x:self.frame.width*0.40, y:self.frame.height*0.17)
        
        HUD.addChild(flagStatusLabel_)
        
        //text that tells the player how many moves they've made
        movesLabel_.zPosition = 50
        movesLabel_.fontSize = 36
        movesLabel_.position = CGPoint(x:self.frame.width*0.37, y:self.frame.height*0.05)
        movesLabel_.text = "Moves: \(moves_)"

        
        HUD.addChild(movesLabel_)
        
        //player timer
        //text that tells the player their time playing
        timerLabel_.zPosition = 50
        timerLabel_.fontSize = movesLabel_.fontSize
        timerLabel_.position = CGPoint(x:self.frame.width*0.60, y:movesLabel_.position.y)
        timerLabel_.text = "Time: \(playerTime_)"
        
        HUD.addChild(timerLabel_)
        

    }
    
    func loadFlagButton(){
        flagButton_.position = CGPoint(x: self.frame.width*0.70, y: self.frame.height*0.17)
        
        //places the flag button up top in the z-axis;
        flagButton_.zPosition = 50
        
        flagButton_.setScale(0.2)
        
        flagButton_.runAction(SKAction.fadeInWithDuration(0.6))

        
        HUD.addChild(flagButton_)
    }
    
    //====Touch Delegate / Button Functions ====
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            //flag button Pressed
            if CGRectContainsPoint(flagButton_.frame, touch.locationInNode(self)) {
                
              flagButtonPressed()
                
            }
            
            //instructions tapped
            if CGRectContainsPoint(instructionsSprite_.frame, touch.locationInNode(self)) && currentGameState_ == .Instructions {

                removeInstructions()
                
            }
            
        }
        
        
        
    }
    
    func tileButtonTapped(sender: MineTileButton) {
        
        //exit function if not playing the game
        if (currentGameState_ != .MineTap && currentGameState_ != .FlagPlanting){
            return
        }
        
        //reveals the underlying tile, only if the game is in the main state, aka MineTap
        if (!sender.tile.isTileDown && currentGameState_ == .MineTap) {
            sender.tile.isTileDown = true
            sender.setTitle("\(sender.getTileLabelText())", forState: .Normal)
            //sender.backgroundColor = UIColor.lightGrayColor()

            
            //mine HIT!
            if sender.tile.isAMine {
                //sender.backgroundColor = UIColor.orangeColor()
                self.mineHit()
            }
            
            //counts the moves; also used in calculating a win
            moves_++
        }
        else if (!sender.tile.isTileDown && currentGameState_ == .FlagPlanting){
            
            self.flagPlant(sender)
        }
        
    }
    
    func flagButtonPressed(){
        
        if (currentGameState_ != .MineTap && currentGameState_ != .FlagPlanting){
            return
        }
        
        //if flag button is originally off
        if flagSwitch_ == .Off{
            
            //set gamestate to planting flags
            currentGameState_ = .FlagPlanting
            flagStatusLabel_.text = "Flag Mode ON"
            
            
        }
        else{
            currentGameState_ = .MineTap
            flagStatusLabel_.text = ""
        }
        
        //flips the button back to opposite state
        flagSwitch_.toggle()
        
        //**animate button here**
        
        
    }
    
    
    func flagPlant(tileToFlag: MineTileButton){
        
        //println("flagPlant function Called")
        
        
        if !tileToFlag.isFlagged {
            tileToFlag.setTitle("🚩", forState: .Normal)
            tileToFlag.isFlagged = true
            self.runAction(SKAction.playSoundFileNamed("flagPlant.wav", waitForCompletion: false))

        }
        else{
            //sets the tile back to it's old text
            tileToFlag.setTitle("◻", forState: .Normal)
            tileToFlag.isFlagged = false
            self.runAction(SKAction.playSoundFileNamed("flagRemove.wav", waitForCompletion: false))
        }
        
    }
    
    
    func mineHit(){
        
        //mine explosion sound
        self.runAction(SKAction.playSoundFileNamed("mineExplosion.wav", waitForCompletion: false))
        
        statusLabel_.text = "You Lose! 😵"
        flagStatusLabel_.text = ""
        
        killTimer()
        gameOverSequence()
    }
    
    //stops the timer
    func killTimer(){
        
        if !timerStopped_{
            
            timerStopped_ = true
            playerTimer_!.invalidate()
            playerTimer_ = nil
            
        }
        
    }
    
    func gameOverSequence(){
        
        //Load retry button
        //button push resets board
        
        currentGameState_ = .GameOver
        
        //schedules the reset prompt
        let resetGame = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("newGamePrompt"), userInfo: nil, repeats: false)
        
    }
    
    func winSequence(){
        
        statusLabel_.text = "You Win! 😀"
        currentGameState_ = .WIN
        self.runAction(SKAction.playSoundFileNamed("win.wav", waitForCompletion: false))
        
        //Save the time if less than last time
        savePlayersTime()
        
        
        //schedules the reset prompt
        let resetGame = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("newGamePrompt"), userInfo: nil, repeats: false)
        
        
    }
    
    func resetBoard() {
        
        mineBoard_.implementDifficulty(currentDifficulty_!)
        mineBoard_.resetBoard()
        
        moves_ = 0
        playerTime_ = 0
        gotNewTimeRecord_ = false
        
        statusLabel_.text = ""
        flagStatusLabel_.text = ""
        
        //resets the button text to their default state; use SKSprite instead of text?
        for tileButton in self.tileButtons_ {
            tileButton.setTitle("◻", forState: .Normal)
            tileButton.backgroundColor = UIColor.whiteColor()
            tileButton.isFlagged = false
        }
        
        currentGameState_ = .MineTap
        
    }
    
    
    // Retry/NewGame function uses UIAlert
      //could also use UIButtons or touchDelegated SpriteNodes
    func newGamePrompt() {
        
        loadBestTimes()
        
        let bestScoresString = getBestScoresString()
        
        //tells the player if they got a new better time
        var newRecordText:String
        
        if (gotNewTimeRecord_){
            
            newRecordText = "\n\n NEW RECORD TIME! 🏆"
        }
        else{
            newRecordText = ""
        }
        
        
        // show an alert when you tap on a mine
        var alertView = UIAlertView()
        
        if(currentGameState_ == .WIN){
            
             alertView.addButtonWithTitle("New Game ↩")      //buttonIndex 0
             alertView.title = "You Win! 😊"
            
            //Note: best for a graphic than in this large alert string
             alertView.message = "You isolated all of the mines! \(bestScoresString) \(newRecordText)"
            
        }
        else{
             alertView.addButtonWithTitle("Retry ↩")         //buttonIndex 0
             alertView.title = "You Lose! 😵"
             alertView.message = "Oops, you landed on a mine \(bestScoresString) \(newRecordText)"
        }
        
        alertView.addButtonWithTitle("Change Difficulty 🎮")  //buttonIndex 1
        alertView.show()
        alertView.delegate = self
    }
        
        
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        
        switch buttonIndex{
        case 0:                                                  // Retry/NewGame Pressed
            resetBoard()
            break
        case 1:
            chooseDifficultyMenu()                               // Change Difficulty Pressed
            break
            
        default:
            resetBoard()
            
        }
        
}
    
    //accounts for nil player times and returns alert string
      //again, better in a graphic than all in an alert
    func getBestScoresString() -> (String){
        
        var easyTimeString : String
        var mediumTimeString : String
        var hardTimeString : String
        
        println("Best Time On Easy: \(bestTimeEasy_)")
        
        if bestTimeEasy_ != 0{
            easyTimeString = "\(bestTimeEasy_!) seconds"
        }
        else{
            easyTimeString = "No Best Time Yet"
        }
        
        if bestTimeMedium_ != 0{
            mediumTimeString = "\(bestTimeMedium_!) seconds"
        }
        else{
            mediumTimeString = "No Best Time Yet"
        }
        
        if bestTimeHard_ != 0{
            hardTimeString = "\(bestTimeHard_!) seconds"
        }
        else{
            hardTimeString = "No Best Time Yet"
        }

        
        return "\n\n Best Times 🕑 \n\n Easy:    \(easyTimeString) \n\n Medium: \(mediumTimeString) \n\n Hard:    \(hardTimeString)"
        
        
    }
    
    func savePlayersTime(){
        
        let bestTime = loadPlayersTime(currentDifficulty_!)
        
        println("Best Time: \(bestTime)")
        println("Player's Win Time: \(playerTime_)")

        
        //change best Time if lower; checks if zero since playerTime is initiated at 0
        if (bestTime == 0  || bestTime > playerTime_){
            
            gotNewTimeRecord_ = true
            
            var savedTimeKey:String
            
            switch currentDifficulty_!{
                
            case .easy:
                savedTimeKey = "bestTime_Easy"
                break
            case .medium:
                savedTimeKey = "bestTime_Medium"
            case .hard:
                savedTimeKey = "bestTime_Hard"
                break
                
            }
            
            //SAVE DATA for Best Time to user data
            let newBestScore : Void = NSUserDefaults.standardUserDefaults().setInteger(playerTime_, forKey: savedTimeKey)
            
        }

        
        
    }
    
    //Player Records
    func loadPlayersTime(difficulty:GameBoard.difficulty) -> (Int){
        
        //var didEarnBestScore = false
        
        var loadedTimeKey:String
        
        switch difficulty{
            
        case .easy:
            loadedTimeKey = "bestTime_Easy"
            break
        case .medium:
           loadedTimeKey =  "bestTime_Medium"
        case .hard:
            loadedTimeKey = "bestTime_Hard"
            break
            
        }

        
        //LOAD DATA for current Best Score
        let loadedBestTime = NSUserDefaults.standardUserDefaults().integerForKey(loadedTimeKey)
        //bestScore = loadedBestScore
        
        return loadedBestTime

    }
    
    func loadBestTimes(){
        
        bestTimeEasy_   = NSUserDefaults.standardUserDefaults().integerForKey("bestTime_Easy")
        bestTimeMedium_ = NSUserDefaults.standardUserDefaults().integerForKey("bestTime_Medium")
        bestTimeHard_   = NSUserDefaults.standardUserDefaults().integerForKey("bestTime_Hard")
        
    }
    
    /*
    //deletes the time records for a player
      //Note: would also be good to prompt another alert for this, IE: "Are You Sure You Want to Delete Records?"
    func deleteSavedData(){
        
        let defs = NSUserDefaults.standardUserDefaults()
        let dict = defs.dictionaryRepresentation()
        
        for key in dict{
            defs.removeObjectForKey(key)
        }
        
        defs.synchronize()
        
    }
*/


   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
}
