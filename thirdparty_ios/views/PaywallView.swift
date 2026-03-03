//
//  PaywallView.swift
//  thirdparty_ios
//

import SwiftUI
import UIKit
import RevenueCat

struct PaywallView: View {
    
    let onDismiss: () -> Void
    
    @State private var selectedPlan: Plan = .yearly
    @State private var animateHeader = false
    
    @State private var offerings: Offerings?
    @State private var monthlyPackage: Package?
    @State private var yearlyPackage: Package?
    @State private var isLoading = true
    
    @State private var isPurchasing = false
    @State private var purchaseErrorMessage: String?
    @State private var showPurchaseError = false
    
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    
    enum Plan {
        case monthly
        case yearly
    }
    
    private var disclaimerText: String {
        if selectedPlan == .yearly {
            let price = yearlyPackage?.storeProduct.localizedPriceString ?? ""
            return "\(price) today, then billed annually. Auto-renews unless cancelled."
        } else {
            let price = monthlyPackage?.storeProduct.localizedPriceString ?? ""
            return "\(price) today, then billed monthly. Auto-renews unless cancelled."
        }
    }
    
    private var calculatedAnnualOriginalPrice: String? {
        guard
            let monthly = monthlyPackage?.storeProduct,
            let yearly = yearlyPackage?.storeProduct
        else { return nil }
        
        let monthlyDecimal = monthly.price as Decimal
        let yearlyFull = monthlyDecimal * 12
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = monthly.priceFormatter?.locale
        
        return formatter.string(from: yearlyFull as NSDecimalNumber)
    }
    
    private var selectedPackage: Package? {
        selectedPlan == .yearly ? yearlyPackage : monthlyPackage
    }
    
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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    
                    Spacer(minLength: 10)
                    
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
                    .animation(.easeOut(duration: 0.6), value: animateHeader)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        FeatureRow(icon: "brain.head.profile", text: "Unlimited AI Judgments")
                        FeatureRow(icon: "person.2", text: "Turn conflict into healthier communication")
                    }
                    .frame(maxWidth: 320)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.top, 20)
                    } else {
                        VStack(spacing: 12) {
                            
                            if let monthly = monthlyPackage {
                                SlimPlanRow(
                                    title: "Monthly Plan",
                                    price: monthly.storeProduct.localizedPriceString,
                                    period: "month",
                                    isSelected: selectedPlan == .monthly,
                                    originalPrice: nil,
                                    badgeText: nil
                                )
                                .onTapGesture {
                                    lightHaptic.impactOccurred()
                                    selectedPlan = .monthly
                                }
                            }
                            
                            if let yearly = yearlyPackage {
                                SlimPlanRow(
                                    title: "Annual Plan",
                                    price: yearly.storeProduct.localizedPriceString,
                                    period: "year",
                                    isSelected: selectedPlan == .yearly,
                                    originalPrice: calculatedAnnualOriginalPrice,
                                    badgeText: "30% OFF"
                                )
                                .onTapGesture {
                                    lightHaptic.impactOccurred()
                                    selectedPlan = .yearly
                                }
                            }
                        }
                        .padding(.top, 12)
                    }
                    
                    VStack(spacing: 14) {
                        
                        Text(disclaimerText)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Button {
                            lightHaptic.impactOccurred()
                            purchaseSelectedPlan()
                        } label: {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            } else {
                                Text(selectedPlan == .monthly
                                     ? "Start Monthly Plan"
                                     : "Start Annual Plan")
                                .font(DesignSystem.Typography.button)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                            }
                        }
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
                        .disabled(isPurchasing || isLoading)
                        
                        HStack(spacing: 20) {
                            
                            Button("Restore") {
                                lightHaptic.impactOccurred()
                                restorePurchases()
                            }
                            
                            Link("Privacy", destination: URL(string: "https://thirdparty-landing.vercel.app/privacy")!)
                            Link("Terms", destination: URL(string: "https://thirdparty-landing.vercel.app/tos")!)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    .padding(.top, 8)
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
        }
        .alert("Purchase Failed", isPresented: $showPurchaseError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchaseErrorMessage ?? "Something went wrong. Please try again.")
        }
        .onAppear {
            animateHeader = true
            lightHaptic.prepare()
            fetchOfferings()
        }
    }
    
    private func purchaseSelectedPlan() {
        guard let package = selectedPackage else {
            purchaseErrorMessage = "Plans are still loading. Please try again in a moment."
            showPurchaseError = true
            return
        }
        
        isPurchasing = true
        
        Task {
            do {
                let result = try await Purchases.shared.purchase(package: package)
                
                let isPro = result.customerInfo.entitlements["pro"]?.isActive == true
                
                await MainActor.run {
                    isPurchasing = false
                    if isPro {
                        onDismiss()
                    } else {
                        purchaseErrorMessage = "Purchase completed, but access was not activated. Try restoring purchases."
                        showPurchaseError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    
                    if let rcError = error as? RevenueCat.ErrorCode,
                       rcError == .purchaseCancelledError {
                        return
                    }
                    
                    purchaseErrorMessage = (error as NSError).localizedDescription
                    showPurchaseError = true
                }
            }
        }
    }
    
    private func restorePurchases() {
        isPurchasing = true
        
        Task {
            do {
                let info = try await Purchases.shared.restorePurchases()
                let isPro = info.entitlements["pro"]?.isActive == true
                
                await MainActor.run {
                    isPurchasing = false
                    if isPro {
                        onDismiss()
                    } else {
                        purchaseErrorMessage = "No active subscription found to restore."
                        showPurchaseError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    purchaseErrorMessage = (error as NSError).localizedDescription
                    showPurchaseError = true
                }
            }
        }
    }
    
    private func fetchOfferings() {
        Purchases.shared.getOfferings { offerings, _ in
            if let current = offerings?.current {
                self.offerings = offerings
                self.monthlyPackage = current.monthly
                self.yearlyPackage = current.annual
            }
            self.isLoading = false
        }
    }
}

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
