//
//  GameScene.swift
//  SuperTux
//
//  Created by Thaís Fernandes on 01/09/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var background: SKSpriteNode = SKSpriteNode()
    private var tux: SKSpriteNode = SKSpriteNode()
    private var floor: SKSpriteNode = SKSpriteNode()
    
    private var tuxWalkingFrames: [SKTexture] = []
    
    private var movingDirection: Directions = Directions.right
    
    private var xMoveValue: CGFloat {
        if movingDirection == .left {
            return -800
        }
        
        return 800
    }
    
    private var actualState: TuxStates = .standing {
        didSet {
            createTux(state: actualState)
        }
    }
    
    private var stepsX: CGFloat = 0.0
    
    private var isWalking = false {
        didSet {
            if isWalking {
                actualState = .walking
            } else {
                actualState = .standing
            }
        }
    }
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        createBackground()
        setUpTux()
        setGroundPhysics()
        setGestures()
        self.physicsWorld.contactDelegate = self
    }
    
    func setGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.view?.addGestureRecognizer(tapGesture)
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongTap))
        self.view?.addGestureRecognizer(longTapGesture)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)

            if position.x > 450 {
                self.movingDirection = .right
            } else if position.x < 450 {
                self.movingDirection = .left
            }
        }
    }
    
    @objc func onLongTap(sender: UILongPressGestureRecognizer) {
        if !isWalking {
            actualState = .walking
        }
        
        if sender.state == .began {
            let moveAction = SKAction.moveTo(x: xMoveValue, duration: 8)
            self.tux.run(moveAction)
            
            moveBackground(to: xMoveValue)
            
        } else if sender.state == .ended {
            self.isWalking = false
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if isWalking && actualState != .walking {
            self.actualState = .walking
        } else if !isWalking && actualState == .jumping {
            self.actualState = .standing
        }
    }
    
    @objc func onTap() {
        if actualState != .jumping {
            jump()
        }
    }
    
    func jump() {
        self.actualState = .jumping
        tux.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 60.0))
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
    
    func setUpTux() {
        self.tux = SKSpriteNode(imageNamed: "\(TuxStates.standing.assetName)\(movingDirection.description)")
        self.tux.position = CGPoint(x: -(self.scene?.size.width)!/2.5, y: 0)
        self.tux.zPosition = 1
        self.tux.name = "tux"
        
        addChild(tux)
        setTuxPhysics()
    }
    
    func createTux(state: TuxStates) {
        var newTux = SKSpriteNode()
        
        switch state {
            case .standing, .jumping:
                newTux = SKSpriteNode(imageNamed: "\(state.assetName)\(movingDirection.description)")
            case .walking:
                newTux = SKSpriteNode(texture: getAnimation(from: "\(state.assetName)\(movingDirection.description)"))
        }
        
        var lastPosition: CGPoint = CGPoint(x: -(self.scene?.size.width)!/2.5, y: 0)
        
        if let lastChildren = children.first(where: { $0.name == "tux" }) {
            removeChildren(in: [lastChildren])
            
            lastPosition = lastChildren.position
        }
        
        self.tux = newTux
        self.tux.zPosition = 1
        self.tux.name = "tux"
        self.tux.position = lastPosition
        
        addChild(tux)
        
        if state == TuxStates.walking {
            animateTux()
        }
        
        setTuxPhysics()
    }
    
    func getAnimation(from atlas: String) -> SKTexture {
        let tuxAnimatedAtlas = SKTextureAtlas(named: atlas)
        
        var walkFrames: [SKTexture] = []
        
        let numImages = tuxAnimatedAtlas.textureNames.count
        
        for i in 1...numImages {
            let tuxTextureName = "tux\(i)"
            walkFrames.append(tuxAnimatedAtlas.textureNamed(tuxTextureName))
        }
        
        tuxWalkingFrames = walkFrames
        
        return tuxWalkingFrames[0]
    }
    
    func animateTux() {
        tux.run(SKAction.repeatForever(
                    SKAction.animate(with: tuxWalkingFrames,
                                     timePerFrame: 0.1,
                                     resize: false,
                                     restore: true)),
                withKey:"walkingTux")
    }
    
    func moveBackground(to position: CGFloat) {
        self.enumerateChildNodes(withName: "Background") { node, error in
            
            node.position.x -= position
            
            if node.position.x < (-(self.scene?.size.width)!) {
                node.position.x += ((self.scene?.size.width)! * 3)
            }
        }
    }
    
    func setTuxPhysics() {
        let tuxPhysicsBody = SKPhysicsBody(rectangleOf: tux.frame.size)
        tuxPhysicsBody.isDynamic = true
        tuxPhysicsBody.affectedByGravity = true
        
        tuxPhysicsBody.categoryBitMask = 00000001
        tuxPhysicsBody.collisionBitMask = 00000011
        tuxPhysicsBody.contactTestBitMask = 00000011
        
        let activeTux = children.first(where: { $0.name == "tux" })
        
        if let activeTux = activeTux {
            activeTux.physicsBody = tuxPhysicsBody
        }
    }
    
    func setGroundPhysics() {
        
        floor = SKSpriteNode(color: .clear, size: CGSize(width: (self.scene?.size.width)!, height: ((self.scene?.size.height)!) * 0.84))
        floor.position = CGPoint(x: 0, y: -((self.scene?.size.height)! / 2))
        floor.zPosition = 1
        
        let floorPhysicsBody = SKPhysicsBody(rectangleOf: floor.frame.size)
        floorPhysicsBody.isDynamic = false
        
        floorPhysicsBody.categoryBitMask = 00000010
        floorPhysicsBody.collisionBitMask = 00000011
        floorPhysicsBody.contactTestBitMask = 00000011
        
        floor.physicsBody = floorPhysicsBody
        
        addChild(floor)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}
