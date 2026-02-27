//
//  AnalyticsView.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-23.
//

import SwiftUI

struct AnalyticsView: View {
    
    var body: some View {
        ZStack {
            
            // MARK: - Background
            
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
            
            // Glow Orbs
            
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
            
            // MARK: - Content
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    
                    // MARK: - HEADER
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        
                        Text("INSIGHTS")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.primary)
                            .tracking(2)
                        
                        Text("Analytics")
                            .font(DesignSystem.Typography.h1)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                    
                    Divider()
                        .background(DesignSystem.Colors.border)
                    
                    // MARK: - Coming Soon
                    
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 60, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.primary.opacity(0.8))
                        
                        Text("Advanced Analytics Coming Soon")
                            .font(DesignSystem.Typography.h2)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("We’re building powerful insights to help you understand communication patterns, emotional balance, and relationship trends.")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, DesignSystem.Spacing.xxl)
                    
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .padding(.bottom, DesignSystem.Spacing.xxl)
            }
        }
    }
}

#Preview {
    AnalyticsView()
}
