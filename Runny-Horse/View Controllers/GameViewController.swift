//
//  GameViewController.swift
//  Runny-Horse
//
//  Created by Miguel Teixeira on 19/02/2020.
//  Copyright © 2020 Miguel Teixeira. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(presentView), name: NSNotification.Name(rawValue: "showAlertVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restartGame), name: NSNotification.Name(rawValue: "restartGame"), object: nil)
        if UserDefaults.standard.string(forKey: "highScore") == nil {
            UserDefaults.standard.set(0, forKey: "highScore")
        }
        presentGameScene()
    }
    
    
    func presentGameScene() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
        }
    }
    
    @objc func presentView(notification:Notification) {
        guard let score = notification.userInfo!["score"] as! Int? else { return }
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        
        if score == 0 {
            presentRHAlertOnMainThread(title: "Your Score was \(score)", message: "Try harder! At least jump one time!", buttonTitle: "Restart game")
        } else if highScore > score {
            presentRHAlertOnMainThread(title: "Your Score was \(score)", message: "Sorry, It wasn't your biggest score. Keep trying to beat \(highScore) jumps", buttonTitle: "Restart game")
        } else {
            UserDefaults.standard.set(score, forKey: "highScore")
            presentRHAlertOnMainThread(title: "Your Score was \(score)", message: "CONGRATS! THIS IS YOUR HIHEST SCORE!", buttonTitle: "Restart game")
        }
    }
    
    @objc func restartGame() {
        presentGameScene()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
