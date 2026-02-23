//
//  SettingsView.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-23.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                colors: [
                    DesignSystem.Colors.bgPrimary,
                    DesignSystem.Colors.bgSecondary,
                    DesignSystem.Colors.bgPrimary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .blur(radius: 120)
                    .offset(x: 120, y: -200)
                
                Circle()
                    .fill(DesignSystem.Colors.secondary.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .blur(radius: 120)
                    .offset(x: -150, y: 250)
            }
            .ignoresSafeArea()
            
            VStack {
                Text("Settings View")
                    .font(DesignSystem.Typography.h2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
        }
    }
}
