//
//  GameScene.swift
//  Runny-Horse
//
//  Created by Miguel Teixeira on 19/02/2020.
//  Copyright © 2020 Miguel Teixeira. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var jumpHorse = SKSpriteNode()
    var runHorse = SKSpriteNode()
    
    var jumpAtlas = SKTextureAtlas()
    var jumpTextureArray = [SKTexture]()
    
    var runAtlas = SKTextureAtlas()
    var runTextureArray = [SKTexture]()
    
    override func didMove(to view: SKView) {
        createBackground()
        
        physicsWorld.gravity = CGVector(dx:0, dy:-2)
        runAtlas = SKTextureAtlas(named: "Run")
        jumpAtlas = SKTextureAtlas(named: "Jump")
        
        runHorse = SKSpriteNode(imageNamed: runAtlas.textureNames[0])
        runHorse.size = CGSize(width: 135, height: 135)
        runHorse.position.x = frame.minX + 100
        runHorse.position.y = frame.minY + 80
        runHorse.physicsBody = SKPhysicsBody(texture: runHorse.texture!, size: runHorse.texture!.size())
        
        addChild(runHorse)
        
        for i in 1...jumpAtlas.textureNames.count {
            let name = "jump_\(i).png"
            jumpTextureArray.append(SKTexture(imageNamed: name))
        }
        
        for i in 1...runAtlas.textureNames.count {
            let name = "run_\(i).png"
            runTextureArray.append(SKTexture(imageNamed: name))
        }
        runHorse.run(SKAction.repeatForever(SKAction.animate(with: runTextureArray, timePerFrame: 0.1)))
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        runHorse.run(SKAction.repeat(SKAction.animate(with: jumpTextureArray, timePerFrame: 0.1), count: 1))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveGround()
    }
    
    func createBackground() {
        let back = SKSpriteNode(imageNamed: "back")
        back.size = CGSize(width: frame.width, height: frame.height)
        back.zPosition = -3
        addChild(back)
        
        for i in 0...3 {
            let background = SKSpriteNode(imageNamed: "background")
            background.name = "Background"
            background.size = CGSize(width: frame.width, height: frame.height)
            background.zPosition = -1
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            addChild(background)
        }
    }
    
    func moveGround() {
        enumerateChildNodes(withName: "Background") { (node, error) in
            node.position.x -= 1.75
            
            if node.position.x <= -(self.scene?.size.width)! {
                node.position.x += (self.scene?.size.width)! * 3
            }
        }
    }
}
