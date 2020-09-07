//
//  GameOver.swift
//  SuitsGame
//
//  Created by Kuba on 06/09/2020.
//  Copyright © 2020 Kuba. All rights reserved.
//

import SpriteKit

class GameOver: SKScene {
    
    var imageGameOver = SKSpriteNode()
    var imageHuman = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        createBG()
        createImage()
        createHuman()
        tryAgain()
    }
    
    func createBG() {
        let background = SKSpriteNode(imageNamed: "palace")
        background.anchorPoint = .zero
        background.zPosition = -1.0
        background.position = CGPoint(x: 0, y: 0)
        self.addChild(background)
    }
    
    func createImage() {
        imageGameOver = SKSpriteNode(imageNamed: "game-over")
        imageGameOver.zPosition = 1
        imageGameOver.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        var rotation = SKAction.rotate(byAngle: 0.5, duration: 0)
        imageGameOver.run(rotation)
        self.addChild(imageGameOver)
    }
    
    func createHuman() {
        imageHuman = SKSpriteNode(imageNamed: "louisGameOver")
        imageHuman.zPosition = 0
        imageHuman.position = CGPoint(x: imageHuman.size.width, y: frame.height / 2)
        self.addChild(imageHuman)
    }
    
    func tryAgain() {
        let label = SKLabelNode(text: "TRY AGAIN")
        label.name = "try again"
        label.zPosition = 5
        label.fontSize = 40
        label.fontColor = UIColor.black
        label.fontName = "Thonburi-Bold"
        label.position = CGPoint(x: frame.maxX - 300, y: 30)
        self.addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            switch nodesArray.first?.name {
            case "try again":
                let scene = GameScene(size: CGSize(width: 900, height: 324))
                scene.scaleMode = scaleMode
                view!.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.3))
                
            default:
                break
            }
        }
    }
}
