//
//  GameScene.swift
//  SuperTux
//
//  Created by Thaís Fernandes on 01/09/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var background: SKSpriteNode = SKSpriteNode()
    private var tux: SKSpriteNode = SKSpriteNode()
    private var floor: SKSpriteNode = SKSpriteNode()
    
    private var hasBegun = false
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        createBackground()
        createTux()
        setPhysics()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.view?.addGestureRecognizer(tapGesture)
        
    }
        
    @objc func onTap() {
        if hasBegun {
            jump()
        } else if !hasBegun {
            self.hasBegun = true
        }
    }
    
    func jump() {
        tux.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 40.0))
    }
    
    func createBackground() {
        for index in 0...3 {
            background = SKSpriteNode(imageNamed: "background")
            background.name = "Background"
            
            let backgroundSize = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!)
            background.size = backgroundSize
            
            let backgroundPosition = CGPoint(x: (CGFloat(index) * (self.scene?.size.width)!), y: 0)
            background.position = backgroundPosition
            
            addChild(background)
        }
    }
    
    func createTux() {
        tux = SKSpriteNode(imageNamed: "standing_tux")
        
        let tuxPosition = CGPoint(x: -(self.scene?.size.width)!/2.5, y: 0)
        
        tux.position = tuxPosition
        tux.zPosition = 1
        
        addChild(tux)
    }
    
    func moveBackground() {
        self.enumerateChildNodes(withName: "Background") { node, error in
            node.position.x -= 2
            
            if node.position.x < (-(self.scene?.size.width)!) {
                node.position.x += ((self.scene?.size.width)! * 3)
            }
        }
    }
    
    func setPhysics() {
        let tuxPhysicsBody = SKPhysicsBody(rectangleOf: tux.frame.size)
        tuxPhysicsBody.isDynamic = true
        tuxPhysicsBody.affectedByGravity = true
        tux.physicsBody = tuxPhysicsBody
        
        floor = SKSpriteNode(color: .clear, size: CGSize(width: (self.scene?.size.width)!, height: ((self.scene?.size.height)!) * 0.84))
        floor.position = CGPoint(x: 0, y: -((self.scene?.size.height)! / 2))
        floor.zPosition = 1
        
        let floorPhysicsBody = SKPhysicsBody(rectangleOf: floor.frame.size)
        floorPhysicsBody.isDynamic = false
        floor.physicsBody = floorPhysicsBody
        
        addChild(floor)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if hasBegun {
            moveBackground()
        }
    }
}
