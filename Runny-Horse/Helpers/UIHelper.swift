//
//  UIHelper.swift
//  Runny-Horse
//
//  Created by Miguel Teixeira on 26/02/2020.
//  Copyright © 2020 Miguel Teixeira. All rights reserved.
//

import UIKit
import SpriteKit

enum UIHelper {
    static func createBackground(in scene: SKScene) {
        let background = SKSpriteNode(imageNamed: "background")
        background.name = "Background"
        background.size = CGSize(width: scene.frame.width, height: scene.frame.height)
        background.zPosition = -2
        scene.addChild(background)
        
        for i in 0...3 {
            let foreground = SKSpriteNode(imageNamed: "foreground")
            foreground.name = "Foreground"
            foreground.size = CGSize(width: scene.frame.width, height: scene.frame.height)
            foreground.zPosition = -1
            foreground.position = CGPoint(x: CGFloat(i) * background.size.width, y: -20)
            scene.addChild(foreground)
        }
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(arc4random() / 0xFFFFFFFF) * (max - min) + min
    }
    
    static func configureMovement(starting: CGFloat) -> SKAction {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: starting, y: 0))
        
        let speed = UIHelper.random(min: 200, max: 450)
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: speed)
        return movement
    }
}
