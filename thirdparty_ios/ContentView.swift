//
//  ContentView.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var auth = AuthViewModel()
    
    var body: some View {
        Group {
            if auth.isLoggedIn {
                MainTabView()
                    .environmentObject(auth)
            } else {
                AuthView()
                    .environmentObject(auth)
            }
        }
    }
}

#Preview {
    ContentView()
}
