//
//  StartScene.swift
//  Dodgeit
//
//  Created by YuankaiLiu on 12/2/18.
//  Copyright © 2018 YuankaiLiu. All rights reserved.
//

import SpriteKit

class StartScene:SKScene {
    
    private var playButton:SKSpriteNode!
    private var optionButton :SKSpriteNode!
   
//
    override func didMove(to view: SKView) {
        
        self.playButton = childNode(withName: "PlayButton") as! SKSpriteNode
        self.optionButton = childNode(withName: "Option") as! SKSpriteNode
        if !UserDefaults.standard.bool(forKey: "HIGHSCORE") {
            UserDefaults.standard.set(0, forKey: "CURRENTSCORE")
            UserDefaults.standard.set(0, forKey: "HIGHSCORE")
        }
        UserDefaults.standard.set(0, forKey: "CURRENTSCORE")
        if !UserDefaults.standard.bool(forKey:"OPTION")
        {
         UserDefaults.standard.set(1,forKey:"OPTION")
        }
        
        let bgMusic = SKAudioNode(fileNamed: "game_music.mp3")
        bgMusic.autoplayLooped = true
        addChild(bgMusic)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard  let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if  playButton.contains(touchLocation) {
            
            let reveal = SKTransition.fade(withDuration: TimeInterval(0.5))
            let startScene = GameScene(fileNamed: "GameScene")
            startScene?.size = self.size
            startScene?.scaleMode = .aspectFill
            self.view?.presentScene(startScene!, transition: reveal)
        }
        
        if  optionButton.contains(touchLocation) {
            
            let reveal = SKTransition.fade(withDuration: TimeInterval(0.5))
            let startScene = SKScene(fileNamed: "OptionScene")
            startScene?.size = self.size
            startScene?.scaleMode = .aspectFill
            self.view?.presentScene(startScene!, transition: reveal)
        }
        
        
        
    }
}
