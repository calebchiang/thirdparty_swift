//
//  PaywallView.swift
//  thirdparty_ios
//

import SwiftUI
import UIKit

struct PaywallView: View {
    
    let onDismiss: () -> Void
    
    @State private var selectedPlan: Plan = .yearly
    @State private var animateHeader = false
    @State private var showFeature1 = false
    @State private var showFeature2 = false
    @State private var showFeature3 = false
    
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    
    enum Plan {
        case monthly
        case yearly
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
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
            
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.25))
                    .frame(width: 300, height: 300)
                    .blur(radius: 120)
                    .offset(x: 140, y: -220)
                
                Circle()
                    .fill(DesignSystem.Colors.secondary.opacity(0.25))
                    .frame(width: 320, height: 320)
                    .blur(radius: 140)
                    .offset(x: -160, y: 300)
            }
            .ignoresSafeArea()
            
            // MARK: - Content
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    
                    Spacer(minLength: 10)
                    
                    // MARK: - Close
                    
                    HStack {
                        Spacer()
                        Button {
                            lightHaptic.impactOccurred()
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(DesignSystem.Colors.bgCard)
                                .clipShape(Circle())
                        }
                    }
                    
                    // MARK: - Header
                    
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            DesignSystem.Colors.secondary,
                                            DesignSystem.Colors.primary
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: DesignSystem.Colors.secondary.opacity(0.6), radius: 20)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 30))
                                .foregroundColor(DesignSystem.Colors.textInverse)
                        }
                        
                        Text("Unlock Unlimited Credits")
                            .font(DesignSystem.Typography.h1)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateHeader ? 1 : 0)
                    .offset(y: animateHeader ? 0 : 12)
                    .animation(.easeOut(duration: 0.6), value: animateHeader)
                    
                    // MARK: - Feature Rows
                    
                    VStack(alignment: .leading, spacing: 14) {
                        
                        FeatureRow(icon: "brain.head.profile", text: "Unlimited AI Judgments")
                            .opacity(showFeature1 ? 1 : 0)
                            .offset(y: showFeature1 ? 0 : 8)
                            .animation(.easeOut(duration: 0.5), value: showFeature1)
                        
                        FeatureRow(icon: "person.2", text: "Turn conflict into healthier communication")
                            .opacity(showFeature2 ? 1 : 0)
                            .offset(y: showFeature2 ? 0 : 8)
                            .animation(.easeOut(duration: 0.5), value: showFeature2)
                        
                        FeatureRow(icon: "waveform", text: "Longer audio uploads")
                            .opacity(showFeature3 ? 1 : 0)
                            .offset(y: showFeature3 ? 0 : 8)
                            .animation(.easeOut(duration: 0.5), value: showFeature3)
                    }
                    .frame(maxWidth: 320)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                    
                    // MARK: - Pricing Options
                    
                    VStack(spacing: 12) {
                        
                        SlimPlanRow(
                            title: "Monthly Plan",
                            price: "$9.99",
                            period: "month",
                            isSelected: selectedPlan == .monthly,
                            originalPrice: nil,
                            badgeText: nil
                        )
                        .onTapGesture {
                            lightHaptic.impactOccurred()
                            selectedPlan = .monthly
                        }
                        
                        SlimPlanRow(
                            title: "Annual Plan",
                            price: "$79.99",
                            period: "year",
                            isSelected: selectedPlan == .yearly,
                            originalPrice: "$119.88",
                            badgeText: "30% OFF"
                        )
                        .onTapGesture {
                            lightHaptic.impactOccurred()
                            selectedPlan = .yearly
                        }
                    }
                    .padding(.top, 12)
                    
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
            
            // MARK: - Sticky CTA
            
            VStack(spacing: 10) {
                
                Button {
                    lightHaptic.impactOccurred()
                    // Purchase logic here
                } label: {
                    Text(selectedPlan == .monthly
                         ? "Start Monthly Plan"
                         : "Start Annual Plan")
                        .font(DesignSystem.Typography.button)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.secondary,
                                    DesignSystem.Colors.primary
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(DesignSystem.Colors.textInverse)
                        .cornerRadius(16)
                }
                
                Text("Auto-renews unless cancelled.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 30)
            .background(
                DesignSystem.Colors.bgTertiary
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .onAppear {
            animateHeader = true
            
            lightHaptic.prepare()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showFeature1 = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                showFeature2 = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showFeature3 = true
            }
        }
    }
}

//
// MARK: - Slim Plan Row
//

struct SlimPlanRow: View {
    
    let title: String
    let price: String
    let period: String
    let isSelected: Bool
    let originalPrice: String?
    let badgeText: String?
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading, spacing: 6) {
                
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let badge = badgeText {
                        Text(badge)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                
                HStack(spacing: 8) {
                    
                    if let original = originalPrice {
                        Text(original)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                            .strikethrough()
                    }
                    
                    Text(price)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("/\(period)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(DesignSystem.Colors.primary)
                    .font(.system(size: 22))
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal)
        .background(
            isSelected
            ? DesignSystem.Colors.bgElevated
            : DesignSystem.Colors.bgCard
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isSelected
                    ? DesignSystem.Colors.primary.opacity(0.6)
                    : DesignSystem.Colors.borderLight
                )
        )
    }
}

//
// MARK: - Feature Row
//

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 14) {
            
            Image(systemName: icon)
                .foregroundColor(DesignSystem.Colors.primary)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 26, alignment: .leading)
            
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    PaywallView {
        print("dismiss")
    }
}
