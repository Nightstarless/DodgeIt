//
//  random.swift
//  Dodgeit
//
//  Created by YuankaiLiu on 12/1/18.
//  Copyright © 2018 YuankaiLiu. All rights reserved.
//
import CoreGraphics
import SpriteKit

public extension CGFloat {
    
    #if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
    #endif
    
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
    
}
