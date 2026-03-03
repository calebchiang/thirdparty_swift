//
//  thirdparty_iosApp.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-23.
//

import SwiftUI
import RevenueCat

@main
struct thirdparty_iosApp: App {
    
    init() {
        Purchases.configure(withAPIKey: "appl_zBUdZzsToZzoGpgyaClaBvZAccX")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
