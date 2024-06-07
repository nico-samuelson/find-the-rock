//
//  AppDelegate.swift
//  FindTheRocks
//
//  Created by Sidi Praptama Aurelius Nurhalim on 07/06/24.
//

import SwiftUI


// MARK: Lock Orientation To Potrait
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}
