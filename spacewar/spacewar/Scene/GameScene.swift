//
//  GameScene.swift
//  Dodgeit
//
//  Created by YuankaiLiu on 12/1/18.
//  Copyright © 2018 YuankaiLiu. All rights reserved.
//
import CoreMotion
import SpriteKit
import GameplayKit
import CoreML


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    //Variables for shake control
    var ringBuffer = RingBuffer()
    let motionOperationQueue = OperationQueue()
    var isCalibrating = false
    var isWaitingForMotionData = true
    var modelRf = RandomForestAccel()
    // setup motionManager
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    // backgroundNode
    var bgNode1:SKSpriteNode!
    var bgNode2:SKSpriteNode!
    // time control
    var lastUpdateTimeInterval:TimeInterval = 0
    var deltaTime:TimeInterval = 0
    var startTime = 0.0
    var intervalTime:TimeInterval = 0
    // label variables
    var cBomb:Int = 3
    var cScore:Double = 0
    var currentScore:SKLabelNode!
    var bombCount:SKLabelNode!
    // physicsCategory bit mask
    struct  PhysicsCategory {
        static let enemy     :UInt32 = 0x1 << 3
        static let SpaceShip :UInt32 = 0x1 << 4
        static let Emitt     :UInt32 = 0x1 << 5
        static let None      :UInt32 = 0
    }
    // mainplane
    var playerNode:SKSpriteNode!
    
    
    //same as example in lab6
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        if self.motionManager.isDeviceMotionAvailable{
            self.motionManager.deviceMotionUpdateInterval = 1.0/200
            self.motionManager.startDeviceMotionUpdates(to: motionOperationQueue, withHandler: self.handleMotion )
        }
    }
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let accel = motionData?.userAcceleration {
            self.ringBuffer.addNewData(xData: accel.x, yData: accel.y, zData: accel.z)
            let mag = fabs(accel.x)+fabs(accel.y)+fabs(accel.z)
            // choose 0.5 because the shake amplitude should be very large
            if mag > 0.5 {
                // buffer up a bit more data and then notify of occurrence
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    // something large enough happened to warrant
                    self.largeMotionEventOccurred()
                })
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        startMotionUpdates()
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        setupPlayer()
        startTime = Date().timeIntervalSince1970
        currentScore = childNode(withName: "currentScore") as! SKLabelNode
        bombCount = childNode(withName: "bombCount") as!SKLabelNode
        
        let bgMusic = SKAudioNode(fileNamed: "game_music.mp3")
        bgMusic.autoplayLooped = true
        addChild(bgMusic)
        bombCount.text = "Bomb:\(self.cBomb)"
        

    }
     
        

    func setDelayedWaitingToTrue(_ time:Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.isWaitingForMotionData = true
        })
    }
    
     func toMLMultiArray(_ arr: [Double]) -> MLMultiArray {
        guard let sequence = try? MLMultiArray(shape:[150], dataType:MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray could not be created")
        }
        let size = Int(truncating: sequence.shape[0])
        for i in 0..<size {
            sequence[i] = NSNumber(floatLiteral: arr[i])
        }
        return sequence
    }
    
    func largeMotionEventOccurred(){
        
        if(self.isWaitingForMotionData)
        {
            self.isWaitingForMotionData = false
            //predict a label
            let seq = toMLMultiArray(self.ringBuffer.getDataAsVector())
            guard let outputRf = try? modelRf.prediction(input: seq) else {
                fatalError("Unexpected runtime error.")
            }
            
            switch outputRf.classLabel{
            case "right" :
                self.xAcceleration = 1
            case "left" :
                self.xAcceleration = -1
            case "down":
                self.bomb()
            default :
                break
            }
            setDelayedWaitingToTrue(0.5)
            
            
        }
    }
    
    
    func setupPlayer(){
        
        playerNode = childNode(withName: "playerNode") as! SKSpriteNode
        playerNode.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mainPlane"), size: CGSize(width: CGFloat(150), height: CGFloat(100)))
        playerNode.physicsBody?.affectedByGravity = false
        playerNode.physicsBody?.isDynamic = true
        playerNode.physicsBody?.categoryBitMask    = PhysicsCategory.SpaceShip
        playerNode.physicsBody?.collisionBitMask   = PhysicsCategory.None
        playerNode.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        
        
    }
    
    func spawnenemy() {
        let i = Int(CGFloat(arc4random()).truncatingRemainder(dividingBy: 2) + 1)
        let imageName = "Enemy0\(i)"
        let enemy  = SKSpriteNode(imageNamed: imageName)
        enemy.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        enemy.zPosition   = 1
        enemy.name = "enemy"
        enemy.size = CGSize(width: CGFloat(90), height: CGFloat(90))
        var xPosition:CGFloat = 0.0
        xPosition = CGFloat.random(min: -self.frame.size.width / 2 + enemy.size.width, max: self.frame.size.width / 2  - enemy.size.width)
        enemy.position = CGPoint(x: xPosition, y: self.frame.size.height / 2  + enemy.size.height * 2)
        self.addChild(enemy)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask   = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask =  PhysicsCategory.SpaceShip
        enemy.physicsBody?.collisionBitMask   = PhysicsCategory.None
       
        //set the speed of enemy plane
        let duration = CGFloat.random(min: CGFloat(2*UserDefaults.standard.float(forKey: "OPTION")), max: CGFloat(4))
        let actionDown = SKAction.move(to: CGPoint(x: xPosition, y: -self.frame.size.height), duration: TimeInterval(duration))
        // use SKAction sequence to remove the node
        enemy.run(SKAction.sequence([actionDown,
                                     SKAction.run({
                                        enemy.removeFromParent();
                                     })]))
        
    }
    
    
    func stopMonitoringAcceleration(){
        if motionManager.isAccelerometerAvailable && motionManager.isAccelerometerActive {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    //update the position of the plane
    override func didSimulatePhysics() {
        // judge if we need to use gesture control
        if (UserDefaults.standard.string(forKey: "CON") == "Gesture"){
        switch UserDefaults.standard.string(forKey: "GESTURE") {
        case "left":
            self.xAcceleration = -1
        case "right":
            self.xAcceleration = 1
        case "five":
            self.bomb()
        case "rock":
            self.xAcceleration = 0
        default:
            break
            }}
        self.playerNode.position.x += self.xAcceleration * 20
        // control the edge of the plane
        let xMinPosition = -self.frame.size.width / 2 + self.playerNode.size.width
        let xMaxPosition = self.frame.size.width / 2 - self.playerNode.size.width
        if self.playerNode.position.x < xMinPosition {
            self.playerNode.position.x = xMinPosition
        }
        if self.playerNode.position.x >   xMaxPosition {
            self.playerNode.position.x =  xMaxPosition
        }
       
    }
    // endless background
    func  updateBackground(deltaTime:TimeInterval){
        
        self.bgNode1 = childNode(withName: "BG1") as! SKSpriteNode
        self.bgNode2 = childNode(withName: "BG2") as! SKSpriteNode
        self.bgNode1.position.y -= CGFloat(deltaTime * 300)
        self.bgNode2.position.y -= CGFloat(deltaTime * 300)
    
        if self.bgNode1.position.y  < -bgNode1.size.height {
            self.bgNode1.position.y = bgNode2.position.y + bgNode2.size.height
        }
        
        if self.bgNode2.position.y  < -bgNode2.size.height {
            self.bgNode2.position.y = bgNode1.position.y + bgNode1.size.height
        }
        
    }
    override func update(_ currentTime: TimeInterval){
        
        if self.lastUpdateTimeInterval == 0 {
            self.lastUpdateTimeInterval = currentTime
        }
        self.deltaTime = currentTime - lastUpdateTimeInterval
        self.lastUpdateTimeInterval = currentTime
        self.intervalTime = self.intervalTime + self.deltaTime
        updateBackground(deltaTime: deltaTime) // endless 无限循环星空背景
        
        let optionDifficulty = UserDefaults.standard.double(forKey: "OPTION")
        print(optionDifficulty)
        if (self.intervalTime>optionDifficulty){
            self.spawnenemy()
            self.intervalTime = 0
        }
        
        self.cScore = Date().timeIntervalSince1970-startTime
        self.cScore = self.cScore*100/optionDifficulty
        let label = String(format: "%.0f", self.cScore)
        DispatchQueue.main.async{
            self.currentScore.text = "Score:"+label
        }
        
        UserDefaults.standard.set(cScore,forKey:"CURRENTSCORE")

}
    
    func enemyHitSpaceShip(nodeA:SKSpriteNode,nodeB:SKSpriteNode){
        if (nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy  || nodeB.physicsBody?.categoryBitMask == PhysicsCategory.enemy) && (nodeA.physicsBody?.categoryBitMask == PhysicsCategory.SpaceShip || nodeB.physicsBody?.categoryBitMask == PhysicsCategory.SpaceShip) {
            
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = nodeA.position
            self.addChild(explosion)
            explosion.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.run {
                    explosion.removeFromParent()
                }]))
            
            nodeA.removeFromParent()
            nodeB.removeFromParent()
            let loseMusicAction = SKAction.playSoundFileNamed("game_over.mp3", waitForCompletion: false)
            self.run(SKAction.sequence([
                loseMusicAction,
                SKAction.wait(forDuration: TimeInterval(0.7)),
                SKAction.run {
                    let reveal = SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(0.5))
                    let loseScene = LoseScene(fileNamed: "LoseScene")
                    loseScene?.size = self.size
                    loseScene?.scaleMode = .aspectFill
                    self.view?.presentScene(loseScene!, transition: reveal)
                }]))
            
        }
        
    }
    
    func bomb() {
        
        if (self.cBomb>0)
        {
            self.enumerateChildNodes(withName: "enemy"){
                (node,error) in
                guard let sprite = node as? SKSpriteNode else {
                return
                }
                sprite.removeFromParent()
                let explosion = SKEmitterNode(fileNamed: "Explosion")!
                explosion.position = sprite.position
                explosion.particleTexture = SKTexture(imageNamed: "Enemy01")
                self.addChild(explosion)
                explosion.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.3),
                    SKAction.run {
                        explosion.removeFromParent()
                    }]))
            }
            let actionColision = SKAction.playSoundFileNamed("boom.mp3", waitForCompletion: false)
            run(actionColision)
            self.cBomb-=1
            bombCount.text = "Bomb:\(self.cBomb)"
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        enemyHitSpaceShip(nodeA: contact.bodyA.node as! SKSpriteNode, nodeB: contact.bodyB.node as! SKSpriteNode)
       
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.xAcceleration = 0
    }

    

    
}

extension UIImage {
    func pixelBuffer() -> CVPixelBuffer? {
        let width = 120
        let height = 120
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_OneComponent8,
                                         attrs,
                                         &pixelBuffer)
        
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        
        let grayColorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: grayColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
                                        return nil
        }
        
        context.translateBy(x: 0, y: 120)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
    
}

extension UIImage{
    
    func resizeImage() -> UIImage {
        let newSize = CGSize(width: 160, height: 90)
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
