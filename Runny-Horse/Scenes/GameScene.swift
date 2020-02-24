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
    var enemyArray = [SKSpriteNode]()
    var jumpTextureArray = [SKTexture]()
    let scoreLabel = RHScoreLabel(textAlignment: .right, fontSize: 30)
    var score = 0
    var gameOver = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx:0, dy: -3)
        let collisionFrame = CGRect(x: -1000, y: frame.minY + 30, width: size.width + 1000, height: size.height - 20)
        physicsBody = SKPhysicsBody(edgeLoopFrom: collisionFrame)
        physicsBody?.categoryBitMask = CollisionType.ground.rawValue
        createBackground()
        createHorse()
        createEnemy()
        configureUI()
    }
    
    func configureUI() {
        guard let view = view else {
            return
        }
        scoreLabel.text = "\(score)"
        view.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scoreLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
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
        runHorse.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 60))
        runHorse.physicsBody?.categoryBitMask = CollisionType.horse.rawValue
        runHorse.physicsBody?.collisionBitMask = CollisionType.ground.rawValue | CollisionType.enemy.rawValue
        runHorse.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        runHorse.physicsBody?.allowsRotation = false
        runHorse.zPosition = 1
        
        addChild(runHorse)
        
        let interval = random(min: 1.5, max: 3)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(createEnemy), SKAction.wait(forDuration: TimeInterval(interval))])))
        runHorse.run(SKAction.repeatForever(SKAction.animate(with: runTextureArray, timePerFrame: 0.1)))
    }
    
    func random() -> CGFloat {
        return CGFloat(arc4random() / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
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
        guard !gameOver else {
            return
        }
        
        enemy = SKSpriteNode(imageNamed: "box")
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        enemy.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        enemy.physicsBody?.collisionBitMask =  CollisionType.ground.rawValue
        enemy.physicsBody?.contactTestBitMask = CollisionType.horse.rawValue
        enemy.physicsBody?.allowsRotation = false
        enemy.name = "enemy"
        enemy.size = CGSize(width: 25, height: 25)
        enemy.position.x = frame.maxX + 200
        enemy.zPosition = 1
        
        addChild(enemy)
        enemyArray.append(enemy)
        
        configureMovement()
    }
    
    func configureMovement() {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: -(size.width + 200), y: 0))
        
        let speed = random(min: 200, max: 350)
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: speed)
        enemy.run(movement)
    }
    
    func addPoint() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let impulse = CGVector(dx: 0, dy: 33)
        runHorse.physicsBody?.applyImpulse(impulse)
        runHorse.run(SKAction.repeat(SKAction.animate(with: jumpTextureArray, timePerFrame: 0.1), count: 1))
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !gameOver else {
            return
        }
        enumerateChildNodes(withName: "enemy") {
            enemy, _ in
            if enemy.position.x <=  -280  {
                enemy.removeFromParent()
                self.score += 1
                self.scoreLabel.text = "\(self.score)"
            }
        }
        moveGround()
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch(contactMask) {
        case CollisionType.horse.rawValue | CollisionType.enemy.rawValue:
            let secondNode = contact.bodyB.node
            secondNode?.removeFromParent()
            let firstNode = contact.bodyA.node
            firstNode?.removeFromParent()
            gameOver = true
        default:
            return
        }
    }
}
