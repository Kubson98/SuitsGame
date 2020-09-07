//
//  GameScene.swift
//  SuitsGame
//
//  Created by Kuba on 22/08/2020.
//  Copyright © 2020 Kuba. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var x = 1.0
    var cameraNode = SKCameraNode()
    var backGround = SKSpriteNode()
    var enemy: SKSpriteNode!
    var player: SKSpriteNode!
    var enemys = ["Police", "HotelBoy"]
    var object: SKSpriteNode!
    let playerCategory:UInt32 = 0x1 << 0
    let blockCategory:UInt32 = 0x1 << 3
    let enemyCategory:UInt32 = 0x1 << 2
    let photonTorpedoCategory:UInt32 = 0x1 << 1
    var upContolButton = SKSpriteNode(imageNamed: "top")
    var shotContolButton = SKSpriteNode(imageNamed: "shotButton")
    var cameraMovePointPerSecond: CGFloat = 200.0
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    var gameTimer: Timer!
    var obstacles: [SKSpriteNode] = []
    var onGround = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 1
    var playerPosY: CGFloat = 0.0
    var soundImage = SKSpriteNode()
    var sound: Bool = true
    var backgroundSound = SKAudioNode()
    
    var keepRun: Bool = true
    var healthLevels: [SKSpriteNode] = []
    var healthCount = 3
    
    var pauseNode: SKSpriteNode!
    
    var playableRect: CGRect {
        let ratio: CGFloat
        switch UIScreen.main.nativeBounds.height {
        case 2688, 1792, 2436:
            ratio = 2.16
        default:
            ratio = 16/9
        }
        
        let playableHeight = size.width / ratio
        let playableMargin = (size.height - playableHeight) / 2.0
        
        return CGRect(x: 0.0, y: playableMargin, width: size.width, height: size.height)
    }
    
    var cameraRect: CGRect {
        let width = playableRect.width
        let height = playableRect.height
        let x = cameraNode.position.x - size.width / 2.0 + (size.width - width) / 2.0
        let y = cameraNode.position.y - size.height / 2.0 + (size.height - height) / 2.0
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    override func didMove(to view: SKView) {
        self.addChild(backgroundSound)
        
        createBackground()
        showHealth()
        createControls()
        createSound()
        addPlayer()
        spawnBlock()
        setupCamera()
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        if keepRun == true {
            moveBackground()
            if lastUpdateTime > 0 {
                dt = currentTime - lastUpdateTime
            } else {
                dt = 0
            }
            lastUpdateTime = currentTime
            moveCamera()
            player.position.x += cameraMovePointPerSecond * CGFloat(dt)
            if x > 4.0 {
                x = 1.0
            }
            player.texture = SKTexture(imageNamed: "Mike-walk\(x)")
            player.physicsBody = player.physicsBody
            x += 0.1
            upContolButton.position.x += cameraMovePointPerSecond * CGFloat(dt)
            shotContolButton.position.x += cameraMovePointPerSecond * CGFloat(dt)
            soundImage.position.x += cameraMovePointPerSecond * CGFloat(dt)
            
            velocityY += gravity
            player.position.y -= velocityY
            
            if player.position.y < playerPosY {
                player.position.y = playerPosY
                velocityY = 0.0
                onGround = true
            }
            
            if player.position.x < cameraRect.minX {
                let scene = GameOver(size: CGSize(width: 900, height: 324))
                scene.scaleMode = scaleMode
                view!.presentScene(scene, transition: .crossFade(withDuration: 1))
            }
        }
        
    }
    
    //MARK: - Touches Buttons
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            switch nodesArray.first?.name {
            case "up":
                if !isPaused {
                    self.run(SKAction.playSoundFileNamed("jump.mp3", waitForCompletion: false))
                    if onGround {
                        onGround = false
                        velocityY = -25.0
                    }
                }
            case "shot":
                fireTorpedo()
            case "music":
                if sound == true {
                    sound = false
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "OffBackgroundSound"), object: self)
                    soundImage.texture = SKTexture(imageNamed: "noMusic")
                } else {
                    sound = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ResumeBackgroundSound"), object: self)
                    soundImage.texture = SKTexture(imageNamed: "Music")
                }
                
            default:
                break
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if velocityY < -12.5 {
            velocityY = -12.5
        }
    }
    
    //MARK: - Player's Health
    
    func showHealth(){
        let first = SKSpriteNode(imageNamed: "health")
        let second = SKSpriteNode(imageNamed: "health")
        let third = SKSpriteNode(imageNamed: "health")
        
        healthPosition(first, i: 1.0)
        healthPosition(second, i: 2.0)
        healthPosition(third, i: 3.0)
        healthLevels.append(first)
        healthLevels.append(second)
        healthLevels.append(third)
        
    }
    
    func healthPosition(_ node: SKSpriteNode, i: CGFloat){
        let height = playableRect.height
        node.setScale(0.4)
        node.zPosition = 50
        node.position = CGPoint(x: node.frame.width + (node.size.width * i), y: height/2.0 - node.frame.height/2)
        cameraNode.addChild(node)
    }
    
    //MARK: - Damage Player

    func damagePlayer() {
        if healthCount == 0 {
            let scene = GameOver(size: CGSize(width: 900, height: 324))
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .crossFade(withDuration: 1))
        } else {
            healthCount -= 1
            healthLevels[healthCount].texture = SKTexture(imageNamed: "damage")
            
        }
    }
    
    //MARK: - Background Sound

    func createSound() {
        soundImage = SKSpriteNode(imageNamed: "Music")
        soundImage.name = "music"
        soundImage.setScale(0.50)
        soundImage.position = CGPoint(x: 200, y: frame.size.height - soundImage.size.height )
        soundImage.zPosition = 6
        addChild(soundImage)
    }
    
    //MARK: - Physics
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & enemyCategory) != 0 {
            torpedoDidCollidedWithEnemy(torpedoNode: firstBody.node as! SKSpriteNode, enemyNode: secondBody.node as! SKSpriteNode)
        }
        
        if (firstBody.categoryBitMask & playerCategory) != 0 && (secondBody.categoryBitMask & enemyCategory) != 0 {
            damagePlayer()
        }
    }
    
    //MARK: - Shot Torpedo
    
    func fireTorpedo() {
        self.run(SKAction.playSoundFileNamed("shot.mp3", waitForCompletion: false))
        let torpedoNode = SKSpriteNode(imageNamed: "shot")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = enemyCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        let animationDuration = 0.7
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: cameraRect.maxX + 100, y: player.position.y), duration: TimeInterval(animationDuration)))
        actionArray.append(SKAction.removeFromParent())
        
        torpedoNode.run(SKAction.sequence(actionArray))
        
    }
    //MARK: - Create Enemy

    @objc func addEnemy () {
        enemys = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: enemys) as! [String]
        
        enemy = SKSpriteNode(imageNamed: enemys[0])
        enemy.zPosition = 5
        enemy.position = CGPoint(x: cameraRect.maxX + enemy.frame.width / 2, y: backGround.frame.height + enemy.frame.height / 2)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.categoryBitMask = enemyCategory
        enemy.physicsBody!.contactTestBitMask = photonTorpedoCategory
        enemy.physicsBody!.contactTestBitMask = playerCategory
        
        self.addChild(enemy)
        enemy.run(.sequence([
            .wait(forDuration: 5),
            .removeFromParent()
        ]))
    }

    //MARK: - Collide Torpedo and Enemy

    func torpedoDidCollidedWithEnemy (torpedoNode: SKSpriteNode, enemyNode: SKSpriteNode) {
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        let boom = SKEmitterNode(fileNamed: "Fire")!
        boom.position = enemyNode.position
        self.addChild(boom)
        enemyNode.removeFromParent()
        torpedoNode.removeFromParent()
        self.run(SKAction.wait(forDuration: 2)) {
            boom.removeFromParent()
        }
    }
    
    //MARK: - Background
    
    func createBackground() {
        for i in 0...2 {
            let ground = SKSpriteNode(imageNamed: "palace")
            ground.name = "Background"
            ground.anchorPoint = .zero
            ground.zPosition = -1.0
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: 0.0)
            self.addChild(ground)
        }
    }
    
    func moveBackground() {
        self.enumerateChildNodes(withName: "Background") { (node, error) in
            node.position.x -= 2
            
            if node.position.x < -((self.scene?.size.width)!) {
                node.position.x += (self.scene?.size.width)! * 3
            }
        }
    }
    
    //MARK: - Create Control Buttons

    func createControls() {
        upContolButton.name = "up"
        upContolButton.zPosition = 6
        upContolButton.position = CGPoint(x: 200, y: upContolButton.size.height)
        self.addChild(upContolButton)
        shotContolButton.name = "shot"
        shotContolButton.zPosition = 6
        shotContolButton.position = CGPoint(x: self.frame.width - 200, y: shotContolButton.size.height)
        self.addChild(shotContolButton)
        
    }
    
    //MARK: - Create Player

    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "MikeFirst")
        player.position = CGPoint(x: frame.width/2.0, y: backGround.frame.height + player.size.height / 2)
        playerPosY = player.position.y
        player.zPosition = 5
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.categoryBitMask = playerCategory
        player.physicsBody!.contactTestBitMask = enemyCategory | blockCategory
        self.addChild(player)
    }
    
    //MARK: - Camera
    
    func setupCamera() {
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func moveCamera() {
        let amountToMove = CGPoint(x: cameraMovePointPerSecond * CGFloat(dt), y: 0.0)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "Background") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width * 2, y: node.position.y)
            }
        }
    }

    //MARK: - Create Obstacles
    
    func setupObstacles() {
        for i in 1...4 {
            let sprite = SKSpriteNode(imageNamed: "Luggage-\(i)")
            sprite.name = "Luggage"
            obstacles.append(sprite)
        }
        
        let index = Int(arc4random_uniform(UInt32(obstacles.count - 1)))
        let sprite = obstacles[index].copy() as! SKSpriteNode
        sprite.setScale(0.55)
        sprite.zPosition = 5
        sprite.position = CGPoint(x: cameraRect.maxX + sprite.frame.width / 2, y: backGround.frame.height + sprite.frame.height / 2)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody!.isDynamic = false
        sprite.physicsBody!.affectedByGravity = false
        sprite.physicsBody!.categoryBitMask = blockCategory
        sprite.physicsBody!.contactTestBitMask = playerCategory
        addChild(sprite)
        sprite.run(.sequence([
            .wait(forDuration: 15),
            .removeFromParent()
        ]))
    }

    //MARK: - Spawn Obstacles and Enemys
    
    func spawnBlock() {
        let random = Double(CGFloat.random(min: 1.5, max: 3.0))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                let randomToSpawn = Int(CGFloat.random(min: 1, max: 3))
                switch randomToSpawn {
                case 1: self?.setupObstacles()
                case 2: self?.addEnemy()
                default:
                    self?.setupObstacles()
                }
            }
        ])))
    }
}
