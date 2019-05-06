//
//  LoseScene.swift
//  Dodgeit
//
//  Created by YuankaiLiu on 12/2/18.
//  Copyright © 2018 YuankaiLiu. All rights reserved.
//

import SpriteKit

class OptionScene:SKScene {
    private var easy :SKSpriteNode!
    private var hard : SKSpriteNode!
    private var shake :SKSpriteNode!
    private var gesture : SKSpriteNode!
    
    override func didMove(to view: SKView) {
       
        self.easy = childNode(withName: "Easy") as! SKSpriteNode
        self.hard = childNode(withName: "Hard") as! SKSpriteNode
        self.shake = childNode(withName: "Shake") as! SKSpriteNode
        self.gesture = childNode(withName: "Gesture") as! SKSpriteNode

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        if self.easy.contains(touchLocation) {
            UserDefaults.standard.set(1,forKey : "OPTION")
            let reveal = SKTransition.doorsOpenVertical(withDuration: TimeInterval(0.5))
            let scene = SKScene(fileNamed: "StartScene")
            scene?.size = self.size
            scene?.scaleMode = .aspectFill
            self.view?.presentScene(scene!, transition: reveal)
            
        }
        
        if self.hard.contains(touchLocation) {
            
            UserDefaults.standard.set(0.5,forKey : "OPTION")
            let reveal = SKTransition.doorsOpenVertical(withDuration: TimeInterval(0.5))
            let scene = SKScene(fileNamed: "StartScene")
            scene?.size = self.size
            scene?.scaleMode = .aspectFill
            self.view?.presentScene(scene!, transition: reveal)
            
        }
        
        if self.shake.contains(touchLocation) {
            //UserDefaults.standard.set(0.5,forKey : "OPTION")
            UserDefaults.standard.set("Shake",forKey : "CON")
            let reveal = SKTransition.doorsOpenVertical(withDuration: TimeInterval(0.5))
            let scene = SKScene(fileNamed: "StartScene")
            scene?.size = self.size
            scene?.scaleMode = .aspectFill
            self.view?.presentScene(scene!, transition: reveal)
            print(UserDefaults.standard.string(forKey: "CON"))
        }
        
        if self.gesture.contains(touchLocation) {
            
            UserDefaults.standard.set( "Gesture" , forKey: "CON")
            let reveal = SKTransition.doorsOpenVertical(withDuration: TimeInterval(0.5))
            let scene = SKScene(fileNamed: "StartScene")
            scene?.size = self.size
            scene?.scaleMode = .aspectFill
            self.view?.presentScene(scene!, transition: reveal)
            print(UserDefaults.standard.string(forKey: "CON"))
            
        }
        
    }
    
}
