//
//  GameViewController.swift
//  Red Line
//
//  Created by Evan Chen on 6/29/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import CoreMotion

enum gameState{
    case inDefault, inStart, inGame, inTransit, inDeath
}

class GameViewController: UIViewController , SCNPhysicsContactDelegate{
    
    // core view and scene
    var gameScene: SCNScene!
    var gameView: SCNView!
    var gameCamera: SCNNode!
    
    
    //reset bools
    var reseting: Bool = false
    
    
    //master player
    var cube : SCNNode!
    
    //tilt detection with core motion
    let motionManager = CMMotionManager()
    var motionTimer: Timer!
    
    
    //game state set control
    var gameState: gameState = .inDefault{
        didSet{
            switch(gameState){
            case .inStart:
                
                //applying physics Body to red lines
                applyPhysics()
                
                //move back camera for motion effect
                
                
                
                //put start menu here
                //menu is spritekit scene overlaying a scene kit
                let startMenu = SKScene(fileNamed: "StartMenu.sks")
                //applying startMenu onto game scene
                gameView.overlaySKScene = startMenu
                
                //menu HUD
                let menu = startMenu?.childNode(withName: "Menu") as? SKSpriteNode
                let startButton = menu?.childNode(withName: "startButton") as? startButton
                
                menu?.alpha = 0
                //menu fade in animation
                menu?.run(SKAction.fadeAlpha(by: 1, duration: 1))
                
                
                startButton?.playAction = {
                    //removing menu HUD
                    print("hello")
                    
                    menu?.run(SKAction.move(by: CGVector(dx: 500, dy : 0), duration: 1)) //move off screen
                    
                    //shift camera towards cube
                    self.gameCamera.runAction( SCNAction.moveBy(x: 0, y: 0, z: CGFloat(self.cube.position.z) - 2, duration: 1), completionHandler: {
                        //remove HUD after shift
                        self.gameView.overlaySKScene = nil
                        //boost cube
                        self.cube.physicsBody?.applyForce(SCNVector3(0,0,-1), asImpulse: true)
                        self.gameState = .inGame
                    })
                }
                
                
                //TODO: laksjdfal
                
                //MARK: SWITCH CASE
                
                
                
                
                
                
                
                break
            case .inGame:
                //removing start menu here
                
                
                
                //nilling friction once again
                cube.physicsBody?.friction = 0
                
                
                //applying physics Body to red lines
                applyPhysics()
                
                break
            case .inTransit:
                //loading in next map
                
                //remove all nodes from previous map
                for child in gameScene.rootNode.childNodes{
                    if(child.name == "redLine" || child.name == "goal"){
                        //only keeping the cube
                        child.removeFromParentNode()
                    }
                }
                
                //hyper jump for load animation
                cube.runAction(SCNAction.moveBy(x: 0, y: 60, z: 0, duration: 1), completionHandler: {
                    //loading in new map after jump animation
                    
                    
                    //loading in objects from selected new formation
                    
                    
                    //switch arc random for "random" map generation
                    var newScene = SCNScene()
                    switch(Int(arc4random_uniform(2))){
                    case 0:
                        newScene = SCNScene(named: "MapFormationA.scn")!
                        break
                        
                    case 1:
                        newScene = SCNScene(named: "MapFormationB.scn")!
                        break
                    default:
                        break
                    }
                    for newChild in (newScene.rootNode.childNodes){
                        if(newChild.name == "redLine" || newChild.name == "goal"){
                            self.gameScene.rootNode.addChildNode(newChild)
                        }
                    }
                    
                    
                    //setting state back to game
                    self.gameState = .inGame
                    
                    //setting cube back to start with fall down animation
                    
                    self.cube.position = SCNVector3(0,30,-1)
                    
                    //setting reseting back to false
                    self.reseting = false
                })
                
                
                break
            case .inDeath:
                //load in death animation and prompt
                
                
                //setting friction to max to stop all previous motion
                self.cube.physicsBody?.friction = 1000
                
                
                //restartmenu is spritekit scene overlaying a scene kit
                let restartMenu = SKScene(fileNamed: "RestartMenu.sks")
                //applying startMenu onto game scene
                gameView.overlaySKScene = restartMenu
                
                
                //Restart HUD items
                let restart = restartMenu?.childNode(withName: "restartMenu") as? SKSpriteNode
                let restartButton = restart?.childNode(withName: "restartButton") as? startButton
                let exitButton = restart?.childNode(withName: "exitButton") as? startButton
                //restart menu animation
                restart?.run(SKAction.moveBy(x: 500, y: 0, duration: 1))
                
                
                //restart trigger
                restartButton?.playAction = {
                    //begin reset process
                    
                    //moving resetmenu off screen
                    restart?.run(SKAction.moveBy(x: 500, y: 0, duration: 1), completion: {
                        self.gameView.overlaySKScene = nil
                    })
                    
                    
                    //removing all sprites from scene
                    for child in self.gameScene.rootNode.childNodes{
                        if(child.name == "redLine" || child.name == "goal"){
                            child.removeFromParentNode()
                            
                        }
                    }
                    //adding from a master scene
                    let newScene = SCNScene(named: "MasterScene.scn")
                    for newChild in (newScene?.rootNode.childNodes)!{
                        if(newChild.name == "redLine" || newChild.name == "goal"){
                            self.gameScene.rootNode.addChildNode(newChild)
                        }
                    }
                    
                    
                    
                    
                    //setting cube back to start with move to animation
                    
                    self.cube.runAction(SCNAction.move(to: SCNVector3(0,1,-1)
                        , duration: 2), completionHandler: {
                            //apply physics to new nodes
                            self.applyPhysics()
                            //moving game state back to starting position in Game
                            self.cube.physicsBody?.friction = 0
                            //launch!
                            self.cube.physicsBody?.applyForce(SCNVector3(0,0,-1), asImpulse: true)
                            self.gameState = .inGame //setting gamestate back to game
                            
                            
                    })
                    
                    
                }
                
                exitButton?.playAction = {
                    //begin reset process
                    self.gameView.overlaySKScene = nil
                    //removing all sprites from scene
                    for child in self.gameScene.rootNode.childNodes{
                        if(child.name == "redLine" || child.name == "goal"){
                            child.removeFromParentNode()
                            
                        }
                    }
                    //adding from a master scene
                    let newScene = SCNScene(named: "MasterScene.scn")
                    for newChild in (newScene?.rootNode.childNodes)!{
                        if(newChild.name == "redLine" || newChild.name == "goal"){
                            self.gameScene.rootNode.addChildNode(newChild)
                        }
                    }
                    self.cube.runAction(SCNAction.move(to: SCNVector3(0,1,-1)
                        , duration: 0.01), completionHandler: {
                            //apply physics to new nodes
                            self.applyPhysics()
                            //moving game state back to starting position in Game
                            self.cube.physicsBody?.friction = 0
                            self.cube.addChildNode(self.gameCamera)
                            //reseting camera back to origonal position
                            self.gameCamera.position = SCNVector3(0,4.056,3.725)
                            self.gameCamera.position.z += 2 // move back camera
                            self.gameCamera.runAction(SCNAction.moveBy(x: 0, y: 0, z: -CGFloat(self.cube.position.z), duration: 1)) // dont know why I do this but yea
                            self.gameCamera.position.z += 4 // move back camera
                            self.gameState = .inStart
                            
                            
                    })
                }
                
                

                break
            default:
                
                break
            }
        }
    }
    
    func applyPhysics(){
        //setting physics back to game
        for child in gameScene.rootNode.childNodes{
            if(child.name == "redLine"){
                child.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 1, height: 1, length: 15, chamferRadius: 0)))
                child.physicsBody?.isAffectedByGravity = false
                child.physicsBody?.restitution = 0
            }else if(child.name == "goal"){
                child.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)))
                child.physicsBody?.isAffectedByGravity = false
                //contact mask 1
                child.physicsBody?.contactTestBitMask = 1
            }else if(child.name == "floor"){
                child.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNFloor()))
                child.physicsBody?.isAffectedByGravity = false
                child.physicsBody?.contactTestBitMask = 1
            }
        }
    }
    func motionUpdate(){
        //accel moves if inGame and cube is moving already
        if(gameState == .inGame){
            if let data = motionManager.accelerometerData {
                cube.physicsBody?.applyForce(SCNVector3((data.acceleration.x*0.1),0,0), asImpulse: true)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loading game view
        gameView = self.view as? SCNView
        //gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        gameView.isPlaying = true
        gameView.showsStatistics = true
        //loading masterScene
        gameScene = SCNScene(named: "MasterScene.scn")
        gameView.scene = gameScene
        
        //loading camera from masterScene
        gameCamera = gameScene.rootNode.childNode(withName: "camera", recursively: true)
        
        //handel contact masks to self
        gameScene.physicsWorld.contactDelegate = self
        
        
        
        //loading in sprite nodes from master scene
        cube = gameScene.rootNode.childNode(withName: "box", recursively: true)
        
        //adding physicsBody
        cube.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)))
        cube.physicsBody?.isAffectedByGravity = true
        cube.physicsBody?.friction = 0
        cube.physicsBody?.damping = 0
        cube.physicsBody?.angularDamping = 0
        cube.physicsBody?.angularVelocityFactor = SCNVector3Zero
        
        //contact mask 1, restitution 0 for no bounce
        cube.physicsBody?.contactTestBitMask = 1
        cube.physicsBody?.restitution = 0
        
        
        //lock camera to cube
        self.cube.addChildNode(self.gameCamera)
        self.gameCamera.position.z += 2 // move back camera
        gameCamera.runAction(SCNAction.moveBy(x: 0, y: 0, z: -CGFloat(cube.position.z), duration: 1)) // dont know why I do this but yea
        self.gameCamera.position.z += 4 // move back camera
        
        //starting accel detection
        motionManager.startAccelerometerUpdates()
        //timer to seak for tilt real time
        motionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.motionUpdate), userInfo: nil, repeats: true)
        
        
        
        //transition to start sequence
        gameState = .inStart
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let contactA = contact.nodeA
        let contactB = contact.nodeB
        
        //contact between floor and the cube
        if(contactA.name == "floor" && contactB.name == "box" || contactB.name == "floor" && contactA.name == "box" ){
            //death
            gameState = .inDeath
        }
        //contact between goal and cube
        if((contactA.name == "goal" && contactB.name == "box" || contactB.name == "goal" && contactA.name == "box") && !reseting ){
            //move to next config
            reseting = true
            gameState = .inTransit
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(gameState == .inGame){
            cube.physicsBody?.applyForce(SCNVector3(0,2,0), asImpulse: true)
        }
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
