//
//  GameScene.swift
//  App09-Game
//
//  Created by Alumno on 01/11/21.
//


import SwiftUI
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let plane = SKSpriteNode(imageNamed: "plane")
    var planeTouched = false
    var started = false
    var timer: Timer?
    @Binding var currentScore: Int
    
    init(_ score: Binding<Int>) {

            _currentScore = score
            super.init(size: CGSize(width: 844, height: 390))
            self.scaleMode = .fill

        }

        required init?(coder aDecoder: NSCoder) {

            _currentScore = .constant(0)
            super.init(coder: aDecoder)

        }

    override func didMove(to view: SKView) {
        
//        let background = SKSpriteNode(imageNamed: "sky")
//        background.size = CGSize(width: 926, height: 460)
//        background.zPosition = 0
//        addChild(background)
        
        plane.zPosition = 5
        plane.position = CGPoint(x: -400, y: 0)
        plane.scale(to: CGSize(width: 50, height: 50))
        plane.name = "plane"
        addChild(plane)
        
        plane.physicsBody = SKPhysicsBody(texture: plane.texture!, size: CGSize(width: 50, height: 50))
        plane.physicsBody?.categoryBitMask = 1
        plane.physicsBody?.collisionBitMask = 0
        plane.physicsBody?.affectedByGravity = false
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        
        parallaxScroll(image: "sky", y: 0, z: 0, duration: 6, needsPhysics: false)
        parallaxScroll(image: "ground", y: -180, z: 5, duration: 6, needsPhysics: true)
        
        physicsWorld.contactDelegate = self
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self,
                                     selector: #selector(createObstacle),
                                     userInfo: nil, repeats: false)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if tappedNodes.contains(plane) {
            planeTouched = true
        }
        
        if !started {
            started = true
            plane.physicsBody?.affectedByGravity = true
        }
        else {
            plane.physicsBody?.velocity = CGVector(dx: 0, dy: 200)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        guard planeTouched else { return }
//        guard let touch = touches.first else { return }
//
//        let location = touch.location(in: self)
//        plane.position = location
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        planeTouched = false
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if started {
            if plane.position.y > 180 {
                plane.position.y = 180
            }
            let value = plane.physicsBody!.velocity.dy * 0.001
            let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
            plane.run(rotate)
        }
        
    }
    
    func parallaxScroll(image: String, y: CGFloat, z: CGFloat, duration: Double, needsPhysics: Bool) {
        
            for i in 0 ... 1 {
                let node = SKSpriteNode(imageNamed: image)
                node.position = CGPoint(x: 926 * CGFloat(i), y: y)
                node.zPosition = z
                addChild(node)

                if needsPhysics {
                    node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.texture!.size())
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.contactTestBitMask = 1
                    node.name = "obstacle"
                }

                let move = SKAction.moveBy(x: -926, y: 0, duration: duration)
                let wrap = SKAction.moveBy(x: 926, y: 0, duration: 0)
                let sequence = SKAction.sequence([move, wrap])
                let forever = SKAction.repeatForever(sequence)
                node.run(forever)
            }
        }
    
    func planeHit(_ node: SKNode) {
        
        if node.name == "obstacle" {
            if let explosion = SKEmitterNode(fileNamed: "PlaneExplosion") {
                explosion.position = plane.position
                explosion.zPosition = 5
                addChild(explosion)
            }
        }
        
        if node.name == "score" {
            currentScore += 1
        }
        
//        run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
//        music.removeFromParent()
        plane.removeFromParent()
        started = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let scene = GameScene(.constant(0))
//            scene.scaleMode = .aspectFit
            scene.size = CGSize(width: 926, height: 460)
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.view?.presentScene(scene)
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == plane {
            planeHit(nodeB)
        }
        else {
            planeHit(nodeA)
        }
    }
    
    @objc func createObstacle() {

            let obstacle = SKSpriteNode(imageNamed: "enemy-plane")
            obstacle.zPosition = 5
            obstacle.position.x = 700
            obstacle.scale(to: CGSize(width: 50, height: 50))
            addChild(obstacle)

            obstacle.physicsBody = SKPhysicsBody(texture: obstacle.texture!, size: CGSize(width: 40, height: 40))
            obstacle.physicsBody?.isDynamic = false
            obstacle.physicsBody?.contactTestBitMask = 1
            obstacle.physicsBody?.linearDamping = 0
            obstacle.name = "obstacle"

            let rand = GKRandomDistribution(lowestValue: -130, highestValue: 180)
            obstacle.position.y = CGFloat(rand.nextInt())
            let move = SKAction.moveTo(x: -463, duration: 6)
            let remove = SKAction.removeFromParent()
            let action = SKAction.sequence([move, remove])
            obstacle.run(action)

            let collision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 20, height: 780))
            collision.physicsBody = SKPhysicsBody(rectangleOf: collision.size)
            collision.physicsBody?.contactTestBitMask = 1
            collision.physicsBody?.isDynamic = false
            collision.position.x = obstacle.frame.maxX
            collision.name = "score"
            addChild(collision)
            collision.run(action)
        
        }

}
