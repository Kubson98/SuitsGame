//
//  MainMenu.swift
//  SuitsGame
//
//  Created by Kuba on 05/09/2020.
//  Copyright © 2020 Kuba. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    var buttonLabel = ["New Game", "Load Game", "Settings"]
    var buttonImage = SKSpriteNode()
    override func didMove(to view: SKView) {
        
        let dictToSend: [String: String] = ["fileToPlay": "bgMusic" ]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PlayBackgroundSound"), object: self, userInfo:dictToSend) //posts the notificatio
        
        createBG()
        createButton()
    }
    
    func createBG() {
        let background = SKSpriteNode(imageNamed: "suitsw")
        background.name = "Background"
        background.anchorPoint = .zero
        background.zPosition = -1.0
        background.position = CGPoint(x: 0, y: 0)
        self.addChild(background)
    }
    
    func createButton() {
        for i in 0...2 {
            if i == 1 {
                buttonImage = SKSpriteNode(imageNamed: "buttonMenuHidden")
            } else {
                buttonImage = SKSpriteNode(imageNamed: "buttonMenu")
            }
            buttonImage.setScale(0.9)
            buttonImage.name = buttonLabel[i]
            buttonImage.zPosition = 5
            buttonImage.position = CGPoint(x: frame.height / 2 - 100 , y: buttonImage.size.width - CGFloat(i) * (buttonImage.size.height / 2))
            let label = SKLabelNode(text: buttonLabel[i])
            label.fontName = "AvenirNext-Bold"
            label.position = buttonImage.position
            label.position.y -= 10
            label.zPosition = 10
            label.name = buttonLabel[i]
            self.addChild(label)
            self.addChild(buttonImage)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            switch nodesArray.first?.name {
            case "New Game":
                print("0")
                let scene = GameScene(size: CGSize(width: 900, height: 324))
                scene.scaleMode = scaleMode
                view!.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.3))
            case "Load Game":
                print("1")
            case "Settings":
                print("2")
            default:
                break
            }
        }
    }
}
