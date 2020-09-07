//
//  GameViewController.swift
//  SuitsGame
//
//  Created by Kuba on 22/08/2020.
//  Copyright © 2020 Kuba. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.playBackgroundSound(_:)), name: NSNotification.Name(rawValue: "PlayBackgroundSound"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.stopBackgroundSound), name: NSNotification.Name(rawValue: "StopBackgroundSound"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.resumeBackgroundSound), name: NSNotification.Name(rawValue: "ResumeBackgroundSound"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.offBackgroundSound), name: NSNotification.Name(rawValue: "OffBackgroundSound"), object: nil)
        
        let scene = MainMenu(size: CGSize(width: 1280, height: 720))
        scene.scaleMode = .aspectFill
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsFields = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }
    
    @objc func playBackgroundSound(_ notification: Notification) {
        let name = (notification as NSNotification).userInfo!["fileToPlay"] as! String
        
        if (player != nil){
            player!.stop()
            player = nil
        }
        
        if (name != ""){
            let fileURL:URL = Bundle.main.url(forResource:name, withExtension: "mp3")!
            
            do {
                player = try AVAudioPlayer(contentsOf: fileURL)
            } catch _{
                player = nil
            }
            player!.volume = 0.75
            player!.numberOfLoops = -1
            player!.prepareToPlay()
            player!.play()
        }
    }
    
    
    
    @objc func stopBackgroundSound() {
        if (player != nil){
            player!.stop()
            player = nil
        }
    }
    
    @objc func offBackgroundSound() {
        player?.volume = 0.0
    }
    
    @objc func resumeBackgroundSound() {
        player?.volume = 0.75
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
