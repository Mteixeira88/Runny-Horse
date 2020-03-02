//
//  RHHorse.swift
//  Runny-Horse
//
//  Created by Miguel Teixeira on 26/02/2020.
//  Copyright © 2020 Miguel Teixeira. All rights reserved.
//

import SpriteKit

class RHHorse: SKSpriteNode {
    var jumpTextureArray = [SKTexture]()
    var runTextureArray = [SKTexture]()
    var isJumping = false
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        let jumpAtlas = SKTextureAtlas(named: "Jump")
        for i in 1...jumpAtlas.textureNames.count {
            let name = "jump_\(i).png"
            jumpTextureArray.append(SKTexture(imageNamed: name))
        }
        
        let runAtlas = SKTextureAtlas(named: "Run")
        for i in 1...runAtlas.textureNames.count {
            let name = "run_\(i).png"
            runTextureArray.append(SKTexture(imageNamed: name))
        }
        
        size = CGSize(width: 100, height: 100)
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 55))
        physicsBody?.categoryBitMask = CollisionType.horse.rawValue
        physicsBody?.collisionBitMask = CollisionType.ground.rawValue | CollisionType.enemy.rawValue
        physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        physicsBody?.allowsRotation = false
        zPosition = 1
        
        run()
    }
    
    func jump() {
        if !isJumping {
            removeAction(forKey: "runAction")
            isJumping = true
            let impulse = CGVector(dx: 0, dy: 20)
            physicsBody?.applyImpulse(impulse)
            run(SKAction.repeat(SKAction.animate(with: jumpTextureArray, timePerFrame: 0.07), count: 1), completion: { [ weak self ] in
                guard let self = self else { return }
                self.run()
                self.isJumping = false
            })
        }
    }
    
    func run() {
        run(SKAction.repeatForever(SKAction.animate(with: self.runTextureArray, timePerFrame: 0.05)), withKey: "runAction")
    }
}
