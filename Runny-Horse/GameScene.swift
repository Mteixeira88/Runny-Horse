//
//  GameScene.swift
//  Runny-Horse
//
//  Created by Miguel Teixeira on 19/02/2020.
//  Copyright © 2020 Miguel Teixeira. All rights reserved.
//

import SpriteKit
import GameplayKit

enum CollisionType: UInt32 {
    case horse = 1
    case enemy = 2
}

class GameScene: SKScene {
    var runHorse = SKSpriteNode()
    var enemy = SKSpriteNode()
    var jumpTextureArray = [SKTexture]()

    
    override func didMove(to view: SKView) {
        createBackground()
        createHorse()
        createEnemy()
        physicsWorld.gravity = CGVector(dx:0, dy:-2)
        
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
    
    func createHorse() {
        var runAtlas = SKTextureAtlas()
        var runTextureArray = [SKTexture]()
        
        var jumpAtlas = SKTextureAtlas()
        
        runAtlas = SKTextureAtlas(named: "Run")
        jumpAtlas = SKTextureAtlas(named: "Jump")
        
        for i in 1...jumpAtlas.textureNames.count {
            let name = "jump_\(i).png"
            jumpTextureArray.append(SKTexture(imageNamed: name))
        }
        
        for i in 1...runAtlas.textureNames.count {
            let name = "run_\(i).png"
            runTextureArray.append(SKTexture(imageNamed: name))
        }
        
        runHorse = SKSpriteNode(imageNamed: runAtlas.textureNames[0])
        runHorse.size = CGSize(width: 135, height: 135)
        runHorse.position.x = frame.minX + 120
        runHorse.position.y = frame.minY + 80
        runHorse.physicsBody = SKPhysicsBody(texture: runHorse.texture!, size: runHorse.texture!.size())
        runHorse.physicsBody?.categoryBitMask = CollisionType.horse.rawValue
        runHorse.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue
        runHorse.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
//        runHorse.physicsBody?.isDynamic = false
        
        addChild(runHorse)
        
        runHorse.run(SKAction.repeatForever(SKAction.animate(with: runTextureArray, timePerFrame: 0.1)))
    }
    
    func moveGround() {
        enumerateChildNodes(withName: "Background") { (node, error) in
            node.position.x -= 1.75
            
            if node.position.x <= -(self.scene?.size.width)! {
                node.position.x += (self.scene?.size.width)! * 3
            }
        }
    }
    
    func createEnemy() {
        let texture = SKTexture(imageNamed: "box")
        enemy = SKSpriteNode(imageNamed: "box")
        enemy.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        enemy.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        enemy.physicsBody?.collisionBitMask = CollisionType.horse.rawValue
        enemy.physicsBody?.contactTestBitMask = CollisionType.horse.rawValue
        enemy.physicsBody?.isDynamic = false
        enemy.name = "enemy"
        enemy.size = CGSize(width: 40, height: 40)
        enemy.position = CGPoint(x: frame.maxX + 200, y: frame.minY + 50)
        print("entrei")
        
        addChild(enemy)
        
        configureMovement()
    }
    
    func configureMovement() {
        let path = UIBezierPath()
        path.move(to: .zero)
            path.addLine(to: CGPoint(x: -10000, y: 0))
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 300)
        
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        enemy.run(sequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        runHorse.run(SKAction.repeat(SKAction.animate(with: jumpTextureArray, timePerFrame: 0.1), count: 1))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveGround()
    }
}
