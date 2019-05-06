//
//  LoseScene.swift
//  Dodgeit
//
//  Created by YuankaiLiu on 12/2/18.
//  Copyright © 2018 YuankaiLiu. All rights reserved.
//

import SpriteKit

class LoseScene:SKScene {
    private var play :SKSpriteNode!
    private var currentScore:SKLabelNode!
    private var highScore:SKLabelNode!
    private var menu : SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        self.menu = childNode(withName: "Menu") as! SKSpriteNode
        self.play = childNode(withName: "Play") as! SKSpriteNode
        self.currentScore = childNode(withName: "currentScore") as! SKLabelNode
        self.highScore    = childNode(withName: "highScore")    as! SKLabelNode
        self.currentScore.text = "SCORE:\(UserDefaults.standard.integer(forKey: "CURRENTSCORE"))"   // 取出当前分数
        let cScore = UserDefaults.standard.integer(forKey: "CURRENTSCORE")
        let hScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")
        
        if (cScore>hScore){
            UserDefaults.standard.set(cScore,forKey:"HIGHSCORE")
        }
        highScore.text    = "HIGH SCORE:\(UserDefaults.standard.integer(forKey: "HIGHSCORE"))" // 取出沙盒中的最高分数
        
       
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
  
        if self.play.contains(touchLocation) {
            let reveal = SKTransition.doorsOpenVertical(withDuration: TimeInterval(0.5))
            let scene = GameScene(fileNamed: "GameScene")
            scene?.size = self.size
            scene?.scaleMode = .aspectFill
            self.view?.presentScene(scene!, transition: reveal)
        }
        if self.menu.contains(touchLocation) {
            let reveal = SKTransition.doorsOpenVertical(withDuration: TimeInterval(0.5))
            let scene = SKScene(fileNamed: "StartScene")
            scene?.size = self.size
            scene?.scaleMode = .aspectFill
            self.view?.presentScene(scene!, transition: reveal)
        }

    }
    
}
