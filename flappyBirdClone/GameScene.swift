//
//  GameScene.swift
//  flappyBirdClone
//
//  Created by Scott Yoshimura on 8/25/15.
//  Copyright (c) 2015 west coast dev. All rights reserved.
//
//  Sprite kit has a physics engine inside of it, and you can use it to apply gravity.



import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    //once we add the SKPhysicsContactDelegate we can use it to establish groups of objects and do something when those groups colide with each other. and once we have categorized our Sprites, we can have them do something when they collide.
    
    //lets create a variable for a score
    var score = 0
    
    //and lets create a label for a score. notice for using a label, you cant just drag and drop like we used to in other labels, you have to do it this way with sprite kit.
    var scoreLabel = SKLabelNode()
    
    //and lets create a label for when the game is over
    var gameOverLabel = SKLabelNode()
    
    //lets create a sprite nod for us to access the label that appears at game over
    var labelHolder = SKSpriteNode()
    
    //lets start by creating a variable to reference to our sprite
    var bird = SKSpriteNode()
    //lets create a variable. in game development, your normally refer to images as textures. for siOS development we can think of it as an image. so lets create a SKTexture(imageNamed: )  note how we put the whole file name reference in the imageNamed column.
    
    //lets create a birdGroup of type UInt32, so that we can reference this variable for our categories rather than
    let birdGroup:UInt32 = 1
    
    //lets create an object group of type UInt32 so we can reference this later
    let objectGroup:UInt32 = 2
    
    //lets create an object coupr of type UInt 32 so we can reference this later. notice we use a different syntax object. this is a bitMask. it is an object that reduce an integer into its binary string. it becomes useful to compare a number of groups that are in a number of different groups, and not necisarrily all of them.
    let gapGroup:UInt32 = 0 << 3
    
    //lets set up a variable for us to use when a collision occures
    var gameOver = 0
    
    //now we want to to stop all the moving objects including the pipes and background when the game is over. we don't know how many pipes will be out there, and we don't currently have a way to access all of them. so lets create a node that will act as a group that all the objects belong to.
    var movingObjects = SKNode()
    
    
    override func didMoveToView(view: SKView) {
        //lets set up the delegate at load, so that we get some collissions happening
        self.physicsWorld.contactDelegate = self
        
        //below is how we change the severity of gravity in the game. we don't want to effect the horizontal movement, so we make x 0, and we make Y -5
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        
        //lets add the movingObjects node to the scene.
        self.addChild(movingObjects)
        
        //now lets add the label Holder node to the scene
        self.addChild(labelHolder)
        
        //lets add the background to the scene using a function
        makeBackground()
        
        //lets also create our SKLabelNode. Now just like our
        scoreLabel.fontName = "Optima"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        //lets move the label to the cetner of the screen at the top. so we need to use CGRectGetMidX(self.frame) which will put it right in the middle, and for Y self.frame.size.height - 70 pixels will put label somewhere near the top
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        //and lets move the score text in front of the pipes
        scoreLabel.zPosition = 9
        //and lets add it to the scene
        self.addChild(scoreLabel)
        
        var birdTexture1 = SKTexture(imageNamed: "img/flappy1.png")
        var birdTexture2 = SKTexture(imageNamed: "img/flappy2.png")
            //now lets assign the texture to the bird.
            bird = SKSpriteNode(texture: birdTexture1)
        //lets actually animate the sprite using an SKAction and we want to animate with textures from above
        var animation = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.1)
        //lets create an instruction using an SKAction that runs animation forever
        var makeBirdFlap = SKAction.repeatActionForever(animation)
        //now lets assign the sprite a position. we will use a CGPoint, with an X coordinate CGRectGetMidX. CGRectGetMidX gets the middle of whatever we put in its argument. and we want to get the middle of the frame that we are in so we use self. we will get hte same ting and for the y point
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        //now lets set the position of hte background. note we are putting it in the center, just like
        //now lets actually make the makeBirdFlap action occur
        bird.runAction(makeBirdFlap)
        //now let's actually add the sprite to the screen. the add child command. adds a new object on the screen to the scene that we are working with. in this case we are adding a sprite.
        
        //now lets add some physics to the bird. the radius is half of hte diameter or half the height
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        //we make the bird dynamic to give it gravity
        bird.physicsBody?.dynamic = true
        //we don't want the bird to spin
        bird.physicsBody?.allowsRotation = false
        //lets add a categories for groups with a categoryBitMask, which is a number, which is a category number for a group. so for example, anything we give a category of 1, they will be in the same category. instead of just using the integer 1, we established the categories in our universal variables.
        bird.physicsBody?.categoryBitMask = birdGroup
        //now that we have the bird in its own category and everthing else in their own, we can set a collision instance on one of them. we set the collisionBitMask to the objectGroup
        bird.physicsBody?.collisionBitMask = objectGroup
        //we also set up a contact, we can now detect when a collision happens between the bird and the objects. we need to do something when that happens.
        bird.physicsBody?.contactTestBitMask = objectGroup
        //now lets also setup an interaction with the gaps. the bird tand the gap won't collide because the rules are that any two objects with the same collisionBitMask will not collide they will just pass through eachother
        bird.physicsBody?.collisionBitMask = gapGroup
        
        //each sprite has a layer system called zed. anything with a higher zed position will appear in front other sprites with a zed value. so since we set it to 10 to get the value
        bird.zPosition = 10
        //now note below, we are not adding the bird to the scene through self, we are using it through movingObjects
        self.addChild(bird)
        
        //lets create a timer that we can use for that is targeting the makePipes method
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipes"), userInfo: nil, repeats: true)
        
        
        //lets create a new node that will be represented as the ground
        var ground = SKNode()
        //we want it to start at hte bottom left of the screen
        ground.position = CGPointMake(0, 0)
        //lets give it some physics. this time we will make a rectangle. the width of the screen is the width. the height can be just one pixel. we don't want the ground to be effected by gravity
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        //lets turn off the gravity for the ground SKNode
        ground.physicsBody?.dynamic = false
        //lets add a categories for groups with a categoryBitMask, which is a number, which is a category number for a group. so for example, anything we give a category of 1, they will be in the same category. instead of just using the integer 1, we established the categories in our universal variables.
        ground.physicsBody?.categoryBitMask = objectGroup
        
        //and lets add it to the scene
        self.addChild(ground)
        
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        //now before contact code happens, we want to make sure it is the bird that makes contact. if it is a gap contact we want to add to the score, else it is a game over function call. if either bodyA or bodyB is the gap
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup{
            
            if gameOver == 0 {
                println("gap contact")
                //and lets have the score increment everytime the bird contacts bodyA or bodyB
                score++
                //and lets set the scoreLabel.text to be the score
                scoreLabel.text = "\(score)"
            }
           
            
        } else {
            //there is only one type of contact that can happen here, between the bird and other objects, so we dont need to check what type of contact has happened, in other games we may want to see who contacts who
            
            //below we will check to see if gamveOver is zero, so that xcode only tries to do the below process once.
            if gameOver == 0 {
                gameOver = 1
                //and because we have a node that we set up to access all moving components we can stop them
                movingObjects.speed = 0
                
                //lets also create our SKLabelNode for the end of the game. we borrowed it from the label
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 25
                gameOverLabel.text = "Game Over. Tap to play again"
                //lets move the label to the cetner of the screen at the top. so we need to use CGRectGetMidX(self.frame) which will put it right in the middle, and for Y self.frame.size.height - 70 pixels will put label somewhere near the top
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                //and lets move the score text in front of the pipes
                gameOverLabel.zPosition = 8
                //and lets add the gameOverLabel to the Sprite labelHolder
                labelHolder.addChild(gameOverLabel)

            }

        }
        

        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //we only allow the movement if the game is not over
        if gameOver == 0 {
            //when the user touches on the bird we want to have the sprite stop in gravity and then be given a boost. the firt tap will set the speed to zero and give a boost everytime after
            bird.physicsBody?.velocity = CGVectorMake(0, 0)// we want to set the speed bck to zero
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        } else {
            // the below will run when the game is over, and they tap on the screen
            //so lets set the score to 0
            score = 0
            //and lets set the label text to 0
            scoreLabel.text = "0"
            
            //we want to get rid of the pipes, but we don't want to get the background of the background
            //lets get rid of all moving objects
            movingObjects.removeAllChildren()
            //and then lets add back in the background
            makeBackground()
            
            //and lets move the bird to back where it was when we started
            //now lets assign the sprite a position. we will use a CGPoint, with an X coordinate CGRectGetMidX. CGRectGetMidX gets the middle of whatever we put in its argument. and we want to get the middle of the frame that we are in so we use self. we will get hte same ting and for the y point
            bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            
            //and because the label is tide to a node, we can remove all the children in the node
            labelHolder.removeAllChildren()

            //and lets change the bird velocity
            bird.physicsBody?.velocity = CGVectorMake(0, 0)// we want to set the speed bck to zero
            
            //lets set gameOver to 0
            gameOver = 0
            
            //and lets restart the movingObjects node, which has all the moving ojbects tied to it.
            movingObjects.speed = 1
        }
        

  
    }
    
    func makeBackground() {
        //now lets create a texture for the background
        var bgTexture = SKTexture(imageNamed: "img/bg.png")
        
        //lets create a new action to actually make the background move
        var moveBackground = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        //now lets create a new action to replace the background when the background nuls out
        var replaceBackground = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        //and lets create a new action to make it keep moving by repeating the above two variables in sequence
        var moveBackgroundForever = SKAction.repeatActionForever(SKAction.sequence([moveBackground, replaceBackground]))
        
        //lets do a for loop to set up for the background to scroll completely on devices. note how we define i as a CGFloat
        for var i:CGFloat=0; i<3; i++ {
            
            //lets create a variable for the background
            var backGround = SKSpriteNode()
            
            //now lets assign the texture to the background
            backGround = SKSpriteNode(texture: bgTexture)
            //now lets place the background. note that we use bgTexture.size().width/2 to get the image to be positioned 450 pixels to the left
            backGround.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            //one thing we want to do is stretch out hte background to fill the screen
            backGround.size.height = self.frame.height
            //and lets add the background to the scene movingObjects node
            movingObjects.addChild(backGround)
            
            //and lets add it to the background
            backGround.runAction(moveBackgroundForever)
            
        }
    }
    
    func makePipes() {
        
        if gameOver == 0 {
        
        //lets set the variable for the gap height of the pipes. note how we made it 4x the bird
        let gapHeight = bird.size.height * 4
        //lets create a variable that varies in value so that we can use it to create the pipes randomly. it is a random number with a maximum value of half the screen.
        var movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        //and lets create a pipe offset, the amount the pipes actually are moving
        var pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        //we have a random number thati s between zero and half the screen height and then shifting it down a quarter of the screen. this will give us a random number with a max value of a 1/4 of screen up and a minimum value with a quarter down
        //lets create a new action to actually make the background move. if we want them to move 100 pixels per second.
        var movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        //now lets apply the removal of the pipes.
        var removePipes = SKAction.removeFromParent()
        //and lets create a new action to make it keep moving by repeating the above two variables in sequence
        var moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        
        //now lets create the first pipe
        var pipe0Texture = SKTexture(imageNamed: "img/pipe1.png")
        var pipe0 = SKSpriteNode(texture: pipe0Texture)
        //lets give the pipe some physics
        pipe0.physicsBody = SKPhysicsBody(rectangleOfSize: pipe0.size)
        //lets turn off the gravity for the ground SKNode
        pipe0.physicsBody?.dynamic = false
        //now lets create the position
        pipe0.physicsBody?.categoryBitMask = objectGroup
        pipe0.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipe0.size.height/2 + gapHeight/2 + pipeOffset)
        pipe0.runAction(moveAndRemovePipes)
        movingObjects.addChild(pipe0)
        
        //now lets create the first pipe
        var pipe1Texture = SKTexture(imageNamed: "img/pipe2.png")
        var pipe1 = SKSpriteNode(texture: pipe1Texture)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe0.size)
        //lets turn off the gravity for the ground SKNode
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody?.categoryBitMask = objectGroup
        //now lets create the position
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe1.size.height/2 - gapHeight/2 + pipeOffset)
        pipe1.runAction(moveAndRemovePipes)
        movingObjects.addChild(pipe1)
            
            //now we will also need a mechanism to score in this game. for this game, lets score the user, everytime they cross a gap, and a gap is the space between both pipes that spawned. so it is appropriate for us to put this here.
            var gap = SKNode()
                //we can make it an SKNode, not a SKSpriteNode because it will be invisible, that is, not visible to the user
            //lets set up the gap position. we can use the same x coordinate position as the pipes that are spawened, but for hte y coordinate because the pipe offset tis the amount we moved the pipe either up or down.
            gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
            //and we want to run moveAndRemovePipes because we want the gap to be moved and removed along with the pipes
            gap.runAction(moveAndRemovePipes)
            //we also want to give the rectangle a size. we can use the width of the pipe, the height is just the gap height, which is 4x the size of the bird.
            gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
            //lets also make the gap not have gravity
            gap.physicsBody?.dynamic = false
            //unlike the pipes we want the bird to move through the gap
            gap.physicsBody?.collisionBitMask = gapGroup
            //and lets give the gap a category, it can be teh same as the collisionBitMask
            gap.physicsBody?.categoryBitMask = gapGroup
            //and we want to konw whenever this gap contacts the bord.
            gap.physicsBody?.contactTestBitMask = birdGroup
            
            //lets add the gap to moving objects
            movingObjects.addChild(gap)

            
            
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
