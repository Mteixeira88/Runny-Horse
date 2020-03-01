//
//  SKScene+Ext.swift
//  Runny-Horse
//
//  Created by Miguel Teixeira on 26/02/2020.
//  Copyright © 2020 Miguel Teixeira. All rights reserved.
//

import SpriteKit

extension SKScene {
    func moveGround(withImage background: String) {
        enumerateChildNodes(withName: background) { (node, error) in
            node.position.x -= 1.5
            
            if node.position.x <= -(self.scene?.size.width)! {
                node.position.x += (self.scene?.size.width)! * 3
            }
        }
    }
    
    func configureScene() {
        physicsWorld.gravity = CGVector(dx:0, dy: -3)
        
        let collisionFrame = CGRect(x: -1000, y: frame.minY + 30, width: size.width + 1000, height: size.height - 20)
        physicsBody = SKPhysicsBody(edgeLoopFrom: collisionFrame)
        physicsBody?.categoryBitMask = CollisionType.ground.rawValue
    }
}
