//
//  VirtualObjectLoader.swift
//  FindTheRocks
//
//  Created by Sidi Praptama Aurelius Nurhalim on 01/06/24.
//

import Foundation
import ARKit

class VirtualObjectLoader {
    private(set) var loadedObjects = [VirtualObject]()
    
    private(set) var isLoading = false
    
    // MARK: - Loading object

    /**
     Loads a `VirtualObject` on a background queue. `loadedHandler` is invoked
     on a background queue once `object` has been loaded.
    */
    func loadVirtualObject(_ object: VirtualObject, loadedHandler: @escaping (VirtualObject) -> Void) {
        isLoading = true
        loadedObjects.append(object)
        
        // Load the content into the reference node.
        DispatchQueue.global(qos: .userInitiated).async {
            object.load()
            self.isLoading = false
            loadedHandler(object)
        }
    }
    
    // MARK: - Removing Objects
    
    func removeAllVirtualObjects() {
        // Reverse the indices so we don't trample over indices as objects are removed.
        for index in loadedObjects.indices.reversed() {
            removeVirtualObject(at: index)
        }
    }

    /// - Tag: RemoveVirtualObject
    func removeVirtualObject(at index: Int) {
        guard loadedObjects.indices.contains(index) else { return }
        
        // Stop the object's tracked ray cast.
        loadedObjects[index].stopTrackedRaycast()
        
        // Remove the visual node from the scene graph.
        loadedObjects[index].removeFromParentNode()
        // Recoup resources allocated by the object.
        loadedObjects[index].unload()
        loadedObjects.remove(at: index)
    }
}

