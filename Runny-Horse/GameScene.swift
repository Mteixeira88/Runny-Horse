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
    case ground = 4
}

class GameScene: SKScene {
    var runHorse = SKSpriteNode(imageNamed: "textureHorse")
    var enemy = SKSpriteNode()
    var jumpTextureArray = [SKTexture]()

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx:0, dy: -3)
        let collisionFrame = CGRect(x: -1000, y: frame.minY + 20, width: size.width + 200, height: size.height - 20)
        physicsBody = SKPhysicsBody(edgeLoopFrom: collisionFrame)
        physicsBody?.categoryBitMask = CollisionType.ground.rawValue
        createBackground()
        createHorse()
        createEnemy()
    }
    
    func createBackground() {
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
        
        runHorse.size = CGSize(width: 100, height: 100)
        runHorse.position.x = frame.minX + 120
        runHorse.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        runHorse.physicsBody?.categoryBitMask = CollisionType.horse.rawValue
        runHorse.physicsBody?.collisionBitMask = CollisionType.ground.rawValue | CollisionType.enemy.rawValue
        runHorse.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        runHorse.physicsBody?.allowsRotation = false
        runHorse.zPosition = 1
        
        addChild(runHorse)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(createEnemy), SKAction.wait(forDuration: 3.0)])))
        runHorse.run(SKAction.repeatForever(SKAction.animate(with: runTextureArray, timePerFrame: 0.1)))
    }
    
    func moveGround() {
        enumerateChildNodes(withName: "Background") { (node, error) in
            node.position.x -= 2
            
            if node.position.x <= -(self.scene?.size.width)! {
                node.position.x += (self.scene?.size.width)! * 3
            }
        }
    }
    
    func createEnemy() {
        enemy = SKSpriteNode(imageNamed: "box")
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        enemy.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        enemy.physicsBody?.collisionBitMask =  CollisionType.ground.rawValue | CollisionType.horse.rawValue
        enemy.physicsBody?.allowsRotation = false
        enemy.size = CGSize(width: 25, height: 25)
        enemy.position.x = frame.maxX + 200
        enemy.zPosition = 1
        
        addChild(enemy)
        
        configureMovement()
    }
    
    func configureMovement() {
        let path = UIBezierPath()
        path.move(to: .zero)
            path.addLine(to: CGPoint(x: -10000, y: 0))
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        enemy.run(sequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let impulse = CGVector(dx: 0, dy: 10)
        runHorse.physicsBody?.applyImpulse(impulse)
        runHorse.run(SKAction.repeat(SKAction.animate(with: jumpTextureArray, timePerFrame: 0.1), count: 1))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveGround()
    }
}
