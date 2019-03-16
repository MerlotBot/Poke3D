//
//  ViewController.swift
//  Poke3D
//
//  Created by Antonakakis Nikolaos on 16.03.19.
//  Copyright © 2019 Antonakakis Nikolaos. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Pokemon Cards", bundle: Bundle.main) {
            
            configuration.trackingImages = imageToTrack
            
            configuration.maximumNumberOfTrackedImages = 2
            
            print("Images Successfully Added!")
            
        }
        
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Delegate that is being called to position a plane and node on an anchor point
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        // Determine the anchor
        if let imageAnchor = anchor as? ARImageAnchor {
            
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            // Make the projected plane white and 50% transparent
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
            
            // A vertical plane will be projected on top of the card
            // However, this plane needs to be transformed into a horizontal projection
            // 90 degrees (half PI), anti-clockwise (negative), in the X-axis
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -Float.pi / 2
            
            // Add the plane to the SCNNode
            node.addChildNode(planeNode)
            
            // From here onwards, the 3D image can be added to the plane ...
            
            // if a card has been recognised ..
            if let pokeCard = imageAnchor.referenceImage.name {
                
                // Get the model ..
                if let pokeScene = SCNScene( named: String("art.scnassets/" + pokeCard + "/" + pokeCard + ".scn") ) {
                    
                    // And add it to the corresponding plane ..
                    if let pokeNode = pokeScene.rootNode.childNodes.first {
                        
                        // Dynamically scale down to an acceptable size for the card - using a Pokemon database about the physical appearance, this could easily be made dynamic per Pokemon. There are really small ones out there!
                        pokeNode.scale.x = 0.05
                        pokeNode.scale.y = 0.05
                        pokeNode.scale.z = 0.05
                        
                        // The Pokemon needs to be turned on its X axis, so that it's standing on top of the card
                        pokeNode.eulerAngles.x = Float.pi / 2
                        
                        // Put the Pokemon on the plane
                        planeNode.addChildNode(pokeNode)
                        
                    }  // if let pokeNode
                    
                }  // if let pokeScene
                
            }  // if let pokeCard
            
        }  // if let imageAnchor
        
        // Back to the main engine
        return node
        
    }  // func

}
