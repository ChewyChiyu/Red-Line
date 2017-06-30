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
                //gonna put start menu here
                
                
                
                
                
                //applying physics Body to red lines
                applyPhysics()
                
                
                
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
                cube.runAction(SCNAction.moveBy(x: 0, y: 30, z: 0, duration: 1), completionHandler: {
                    //loading in new map after jump animation
                    //right now only MapFormationA is avaiable
                    
                    //loading in objects from selected new formation
                    let newScene = SCNScene(named: "MapFormationA.scn")
                    for newChild in (newScene?.rootNode.childNodes)!{
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
                //removing all sprites from scene
                for child in gameScene.rootNode.childNodes{
                    if(child.name == "redLine" || child.name == "goal"){
                        child.removeFromParentNode()

                    }
                }
                //adding from a master scene
                let newScene = SCNScene(named: "MasterScene.scn")
                for newChild in (newScene?.rootNode.childNodes)!{
                    if(newChild.name == "redLine" || newChild.name == "goal"){
                        gameScene.rootNode.addChildNode(newChild)
                    }
                }
                
                applyPhysics()
                
                
                self.gameState = .inStart
                
                //setting cube back to start with fall down animation
                self.cube.position = SCNVector3(0,2,-1)
                
                //setting friction to max to stop all previous motion
                cube.physicsBody?.friction = 1000
                
                
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
                //cube.physicsBody?.velocity.x = Float(data.acceleration.x)
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
        gameCamera.runAction(SCNAction.moveBy(x: 0, y: 0, z: -CGFloat(cube.position.z), duration: 1))
        
        
        
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
        //tap to begin the game
        if(gameState == .inStart){
            gameState = .inGame
            cube.physicsBody?.applyForce(SCNVector3(0,0,-1), asImpulse: true)
        }
        else if(gameState == .inGame){
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
