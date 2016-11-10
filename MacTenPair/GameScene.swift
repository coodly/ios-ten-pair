//
//  GameScene.swift
//  MacTenPair
//
//  Created by Jaanus Siim on 19/06/16.
//  Copyright (c) 2016 Coodly LLC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        self.addChild(myLabel)
    }
    
    override func mouseDown(with event: NSEvent) {
        /* Called when a mouse click occurs */
        
        let location = event.location(in: self)
        
        let sprite = SKSpriteNode(imageNamed:"Spaceship")
        sprite.position = location;
        sprite.setScale(0.5)
        
        let action = SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)
        sprite.run(SKAction.repeatForever(action))
        
        self.addChild(sprite)
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
