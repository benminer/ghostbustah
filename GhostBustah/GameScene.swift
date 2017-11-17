//
//  GameScene.swift
//  GhostBustah
//
//  Created by Ben Miner on 10/26/17.
//  Copyright © 2017 Ben Miner. All rights reserved.
//

import Foundation
import ARKit
class GameScene: SKScene {
    
    var sceneView: ARSKView {
        return view as! ARSKView
    }
    
    var timer: Timer!
    var ghostMove = false
    var sight: SKSpriteNode!
    var isWorldSetUp = false
    var firstRender = true
    var screenHeight: CGFloat = 0.0
    var screenWidth: CGFloat = 0.0
//    var anchor: Anchor!
    private var translation = matrix_identity_float4x4
    let gameSize = CGSize(width: 2,height: 2)
    
    private func setUpWorld() {
        startGhostTimer()
        guard let currentFrame = sceneView.session.currentFrame,
            let scene = SKScene(fileNamed: "Main")
            else { return }
        for node in scene.children {
            if let node = node as? SKSpriteNode {
                node.size = CGSize(width: 10, height: 10)
                screenWidth = scene.size.width
                screenHeight = scene.size.height
                let positionX = randomFloat(min: 0.0, max: 150.0) / scene.size.width
                let positionY = randomFloat(min: 0.0, max: 150.0)  / scene.size.height
                translation.columns.3.x = Float(positionX * gameSize.width)
                translation.columns.3.z = -Float(positionY * gameSize.height)
                translation.columns.3.y = Float(drand48() - 0.5)
                let transform = currentFrame.camera.transform * translation
                let anchor = Anchor(transform: transform)
                if let name = node.name,
                    let type = NodeType(rawValue: name) {
                    anchor.type = type
                    sceneView.session.add(anchor: anchor)
                }
            }
        }
        isWorldSetUp = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if !isWorldSetUp {
            setUpWorld()
        }
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        guard let currentFrame = sceneView.session.currentFrame,
            let lightEstimate = currentFrame.lightEstimate
            else { return }
        let neutralIntensity: CGFloat = 1000
        let ambientIntensity = min(lightEstimate.ambientIntensity,
                                   neutralIntensity)
        let blendFactor = 1 - ambientIntensity / neutralIntensity
        
        for node in children {
            if let ghost = node as? SKSpriteNode {
                ghost.color = .black
                ghost.colorBlendFactor = blendFactor
            }
//            if ghostMove {
//                ghostMove = false
//                print("Moving")
////                node.run(fadeOut)
//                let positionX = randomFloat(min: 0.0, max: 150.0) / screenWidth
//                let positionY = randomFloat(min: 0.0, max: 150.0)  / screenHeight
//                translation.columns.3.x = Float(positionX * gameSize.width)
//                translation.columns.3.z = -Float(positionY * gameSize.height)
//                translation.columns.3.y = Float(drand48() - 0.5)
//                let transform = currentFrame.camera.transform * translation
//                anchor = Anchor(transform: transform)
////                node.run(fadeIn)
//            }
        }
    }
    
    func randomFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        return (CGFloat(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    override func didMove(to view: SKView) {
        srand48(Int(Date.timeIntervalSinceReferenceDate))
        sight = SKSpriteNode(imageNamed: "sight")
        addChild(sight)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = sight.position
        let hitNodes = nodes(at: location)
        
        var hitGhost: SKNode?
        for node in hitNodes {
            if node.name == NodeType.ghost.rawValue || node.name == NodeType.rareGhost.rawValue {
                hitGhost = node
                break
            }
            run(Sounds.fire)
            if let hitGhost = hitGhost,
                let anchor = sceneView.anchor(for:hitGhost) {
                let action = SKAction.run {
                    self.sceneView.session.remove(anchor: anchor)
                }
                // Replace Sounds.fire with a ghostly hit sound
                let group = SKAction.group([Sounds.fire, action])
                let sequence = [SKAction.wait(forDuration: 0.3), group]
                hitGhost.run(SKAction.sequence(sequence))
            }
        }
    }
    
    func startGhostTimer () {
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.moveGhost), userInfo: nil, repeats: true)
    }
    
    @objc func moveGhost() {
        print("Ghost Move Called")
        ghostMove = true
    }
    


    private func remove(anchor: ARAnchor) {
        sceneView.session.remove(anchor: anchor)
    }
    
}


//    func view(_ view: ARSKView,
//              nodeFor anchor: ARAnchor) -> SKNode? {
//        let ghost = SKSpriteNode(imageNamed: "ghost")
//        ghost.name = "ghost"
//        return ghost
//    }


//        for anchor in currentFrame.anchors {
//            guard let node = sceneView.node(for: anchor),
//                else { continue }
//            let distance = simd_distance(anchor.transform.columns.3,
//                                         currentFrame.camera.transform.columns.3)
//            if distance < 0.1 {
//
//                break
//            }
//        }

//    private func addBugSpray(to currentFrame: ARFrame) {
//        var translation = matrix_identity_float4x4
//        translation.columns.3.x = Float(drand48()*2 - 1)
//        translation.columns.3.z = -Float(drand48()*2 - 1)
//        translation.columns.3.y = Float(drand48() - 0.5)
//        let transform = currentFrame.camera.transform * translation
//        let anchor = Anchor(transform: transform)
//        anchor.type = .bugspray
//        sceneView.session.add(anchor: anchor)
//    }

//    var hasBugspray = false {
//        didSet {
//            let sightImageName = hasBugspray ? "bugspraySight" : "sight"
//            sight.texture = SKTexture(imageNamed: sightImageName)
//        }
//    }
