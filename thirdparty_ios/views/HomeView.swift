import SwiftUI

struct HomeView: View {
    
    @State private var showLive = false
    @State private var showUpload = false
    @State private var showScreenshot = false
    @State private var showBadges = false
    
    @State private var user: User?
    
    @State private var selectedMode: SetupMode?
    @State private var showCreditsAlert = false
    
    private func lightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    
                    Spacer(minLength: 40)
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("ThirdParty")
                            .font(DesignSystem.Typography.hero)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Your unbiased AI mediator")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    VStack(spacing: 14) {
                        
                        ModeCard(
                            title: "Live Debate",
                            description: "Record your argument in real-time. AI listens and decides.",
                            gradient: [DesignSystem.Colors.secondary, DesignSystem.Colors.secondaryDark],
                            icon: "mic.fill"
                        ) {
                            lightHaptic()
                            selectedMode = .live
                        }
                        .opacity(showLive ? 1 : 0)
                        .offset(y: showLive ? 0 : 30)
                        .animation(.easeOut(duration: 0.5), value: showLive)
                        
                        ModeCard(
                            title: "Upload Audio",
                            description: "Upload an audio recording. AI analyzes and delivers a verdict.",
                            gradient: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryDark],
                            icon: "waveform"
                        ) {
                            lightHaptic()
                            selectedMode = .upload
                        }
                        .opacity(showUpload ? 1 : 0)
                        .offset(y: showUpload ? 0 : 30)
                        .animation(.easeOut(duration: 0.5).delay(0.15), value: showUpload)
                        
                        ModeCard(
                            title: "Screenshot",
                            description: "Upload a text conversation. AI judges who’s right.",
                            gradient: [Color(hex: "#6C5CE7"), Color(hex: "#5541D7")],
                            icon: "photo.fill"
                        ) {
                            lightHaptic()
                            selectedMode = .screenshot
                        }
                        .opacity(showScreenshot ? 1 : 0)
                        .offset(y: showScreenshot ? 0 : 30)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showScreenshot)
                    }
                    
                    if let user = user, !user.isPremium {
                        HStack {
                            
                            Button {
                                lightHaptic()
                                showCreditsAlert = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.yellow)
                                    
                                    Text("\(user.credits)")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textPrimary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(DesignSystem.Colors.bgCard)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(DesignSystem.Colors.borderLight)
                                )
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            Button {
                                lightHaptic()
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Go Pro")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textInverse)
                                    
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(DesignSystem.Colors.textInverse)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.secondary, DesignSystem.Colors.primary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 8)
                        .opacity(showBadges ? 1 : 0)
                        .offset(y: showBadges ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.45), value: showBadges)
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
        }
        .fullScreenCover(item: $selectedMode) { mode in
            SetupView(mode: mode)
        }
        .alert(
            "Credits",
            isPresented: $showCreditsAlert
        ) {
            Button("Get more credits") {
                showCreditsAlert = false
            }
            Button("Cancel", role: .cancel) {
                showCreditsAlert = false
            }
        } message: {
            Text("You have \(user?.credits ?? 0) remaining.")
        }
        .onAppear {
            fetchUserProfile()
            
            showLive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                showUpload = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showScreenshot = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                showBadges = true
            }
        }
    }
    
    private func fetchUserProfile() {
        RequestManager.shared.sendRequest(
            endpoint: "/users/me",
            method: "GET",
            responseType: User.self
        ) { result in
            switch result {
            case .success(let fetchedUser):
                self.user = fetchedUser
            case .failure(let error):
                print("Failed to fetch user:", error)
            }
        }
    }
}

struct ModeCard: View {
    
    let title: String
    let description: String
    let gradient: [Color]
    let icon: String
    let action: () -> Void
    
    @State private var pressed = false
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.28))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.h3)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.30))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .padding(DesignSystem.Spacing.cardPadding)
            .frame(minHeight: 130)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(DesignSystem.Radius.xl)
            .scaleEffect(pressed ? DesignSystem.Animation.pressedScale : 1)
            .animation(DesignSystem.Animation.fast, value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    pressed = true
                }
                .onEnded { _ in
                    pressed = false
                }
        )
    }
}

#Preview {
    HomeView()
}
