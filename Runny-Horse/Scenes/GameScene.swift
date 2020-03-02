//
//  GameScene.swift
//  Runny-Horse
//
//  Created by Miguel Teixeira on 19/02/2020.
//  Copyright © 2020 Miguel Teixeira. All rights reserved.
//

import SpriteKit

protocol GameSceneDelegate: class {
    func showAlert(scene: SKScene)
}

class GameScene: SKScene {
    var runHorse = RHHorse()
    var enemy = SKSpriteNode()
    let scoreLabel = RHTitleLabel(textAlignment: .right, fontSize: 30)
    var score = 0
    var gameOver = false
    
    weak var gameDelegate: GameSceneDelegate!
    
    override func didMove(to view: SKView) {
        removeAllChildren()
        physicsWorld.contactDelegate = self
        configureScene()
        
        UIHelper.createBackground(in: self)
        configureElements()
        configureUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        runHorse.jump()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !gameOver else {
            return
        }
        enumerateChildNodes(withName: "enemy") { [weak self] enemy, _ in
            guard let self = self else { return }
            
            self.jumpOver(enemy: enemy)
        }
        
        moveGround(withImage: "Foreground")
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
    
    func configureElements() {
        runHorse.position.x = frame.minX + 120
        addChild(runHorse)
        
        let interval = UIHelper.random(min: 1, max: 3)
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(createEnemy), SKAction.wait(forDuration: TimeInterval(interval))])))
    }
    
    func createEnemy() {
        guard !gameOver else {
            return
        }
        
        enemy = SKSpriteNode(imageNamed: "box")
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 27, height: 10))
        enemy.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        enemy.physicsBody?.collisionBitMask =  CollisionType.ground.rawValue
        enemy.physicsBody?.contactTestBitMask = CollisionType.horse.rawValue
        enemy.physicsBody?.allowsRotation = false
        enemy.name = "enemy"
        enemy.size = CGSize(width: 27, height: 10)
        enemy.position.x = frame.maxX + 200
        enemy.zPosition = 1
        
        addChild(enemy)
        
        enemy.run(UIHelper.configureMovement(starting: -(size.width + 200)))
    }
    
    func jumpOver(enemy: SKNode) {
        if enemy.position.x <= runHorse.frame.minX  {
            enemy.removeFromParent()
            score += 1
            scoreLabel.text = "\(score)"
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch(contactMask) {
        case CollisionType.horse.rawValue | CollisionType.enemy.rawValue:
            let firstNode = contact.bodyA.node
            firstNode?.removeFromParent()
            scoreLabel.removeFromSuperview()
            gameOver = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlertVC"), object: nil, userInfo: ["score": score])
            enumerateChildNodes(withName: "enemy") { enemy, _ in
                enemy.removeFromParent()
            }
            
        default:
            return
        }
    }
}
