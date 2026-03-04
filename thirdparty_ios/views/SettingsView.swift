import SwiftUI

struct SettingsView: View {
    
    @State private var user: User?
    @EnvironmentObject var auth: AuthViewModel
    private let privacyURL = URL(string: "https://thirdparty-landing.vercel.app/privacy")!
    private let termsURL = URL(string: "https://thirdparty-landing.vercel.app/tos")!
    private let manageSubscriptionURL = URL(string: "https://apps.apple.com/account/subscriptions")!
    @State private var showPaywall = false
    
    @State private var showDeleteConfirmation = false
    @State private var isDeletingAccount = false
    @State private var showDeleteError = false
    @State private var deleteErrorMessage = ""
    
    var body: some View {
        ZStack {
            
            // Background
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
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    
                    // MARK: - HEADER
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        
                        Text("PREFERENCES")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.primary)
                            .tracking(2)
                        
                        Text("Settings")
                            .font(DesignSystem.Typography.h1)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                    
                    Divider()
                        .background(DesignSystem.Colors.border)
                    
                    // MARK: - ACCOUNT
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        
                        sectionTitle("ACCOUNT")
                        
                        if let user = user {
                            HStack(spacing: DesignSystem.Spacing.md) {
                                
                                Circle()
                                    .fill(DesignSystem.Colors.primary.opacity(0.15))
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(DesignSystem.Colors.primary)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    
                                    Text(user.email)
                                        .font(DesignSystem.Typography.bodyMedium)
                                        .foregroundColor(DesignSystem.Colors.textPrimary)
                                    
                                    if user.isPremium {
                                        VStack(alignment: .leading, spacing: 6) {
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(DesignSystem.Colors.primary)
                                                
                                                Text("Premium")
                                                    .font(DesignSystem.Typography.caption)
                                                    .foregroundColor(DesignSystem.Colors.primary)
                                            }
                                            
                                            Button {
                                                UIApplication.shared.open(manageSubscriptionURL)
                                            } label: {
                                                Text("Manage Subscription")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                                    .underline()
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    } else {
                                        Text("Free Plan")
                                            .font(DesignSystem.Typography.caption)
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if !user.isPremium {
                                    Button {
                                        showPaywall = true
                                    } label: {
                                        Text("Upgrade")
                                            .font(DesignSystem.Typography.caption)
                                            .foregroundColor(DesignSystem.Colors.textInverse)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(
                                                LinearGradient(
                                                    colors: [
                                                        DesignSystem.Colors.primary,
                                                        DesignSystem.Colors.primaryDark
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .cornerRadius(DesignSystem.Radius.button)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(DesignSystem.Spacing.cardPadding)
                            .background(DesignSystem.Colors.bgCard)
                            .cornerRadius(DesignSystem.Radius.xl)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                                    .stroke(DesignSystem.Colors.border)
                            )
                        }
                    }
             
                    // MARK: - SUPPORT
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        
                        sectionTitle("SUPPORT")
                        
                        settingsGroup {
                            settingsRow(
                                icon: "key.shield.fill",
                                label: "Privacy Policy"
                            ) {
                                UIApplication.shared.open(privacyURL)
                            }

                            Divider().background(DesignSystem.Colors.border)

                            settingsRow(
                                icon: "doc.text",
                                label: "Terms of Service"
                            ) {
                                UIApplication.shared.open(termsURL)
                            }
                        }
                    }
                    
                    // MARK: - ACCOUNT ACTIONS
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        
                        sectionTitle("ACCOUNT ACTIONS")
                        
                        settingsGroup {
                            settingsRow(
                                icon: "rectangle.portrait.and.arrow.right",
                                label: "Sign Out"
                            ) {
                                auth.logout()
                            }
                            
                            Divider().background(DesignSystem.Colors.border)
                            
                            settingsRow(
                                icon: "trash",
                                label: "Delete Account",
                                isDanger: true
                            ) {
                                showDeleteConfirmation = true
                            }
                        }
                    }
                    
                    // MARK: - FOOTER
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        
                        Rectangle()
                            .fill(DesignSystem.Colors.border)
                            .frame(width: 40, height: 1)
                        
                        Text("ThirdParty v1.0.0")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textMuted)
                        
                        Text("Fair judgments, every time")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textMuted)
                            .italic()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, DesignSystem.Spacing.xxl)
                    
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .padding(.bottom, DesignSystem.Spacing.xxl)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView {
                showPaywall = false
            }
        }
        .alert(
            "Delete Account?",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action is permanent and cannot be undone. All your debates, judgments, transcripts, and account data will be permanently deleted.")
        }
        .alert(
            "Deletion Failed",
            isPresented: $showDeleteError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(deleteErrorMessage)
        }
        .overlay {
            if isDeletingAccount {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ProgressView("Deleting account...")
                        .padding()
                        .background(DesignSystem.Colors.bgCard)
                        .cornerRadius(12)
                }
            }
        }
        .onAppear {
            fetchUserProfile()
        }
    }
    
    // MARK: - Components
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Typography.caption)
            .foregroundColor(DesignSystem.Colors.textMuted)
            .tracking(1.5)
    }
    
    private func settingsGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(DesignSystem.Colors.bgCard)
        .cornerRadius(DesignSystem.Radius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                .stroke(DesignSystem.Colors.border)
        )
    }
    
    private func settingsRow(
        icon: String,
        label: String,
        value: String? = nil,
        isDanger: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        
        Button {
            action?()
        } label: {
            HStack {
                HStack(spacing: DesignSystem.Spacing.md) {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                            .fill(isDanger ? DesignSystem.Colors.error.opacity(0.15)
                                           : DesignSystem.Colors.bgTertiary)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: icon)
                            .foregroundColor(isDanger ? DesignSystem.Colors.error
                                                      : DesignSystem.Colors.textSecondary)
                    }
                    
                    Text(label)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(isDanger ? DesignSystem.Colors.error
                                                  : DesignSystem.Colors.textPrimary)
                }
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textMuted)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
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
    
    private func deleteAccount() {
        isDeletingAccount = true
        
        RequestManager.shared.sendRequest(
            endpoint: "/users/me",
            method: "DELETE",
            responseType: DeleteResponse.self
        ) { result in
            switch result {
            case .success:
                isDeletingAccount = false
                
                // Log user out immediately
                auth.logout()
                
            case .failure(let error):
                isDeletingAccount = false
                deleteErrorMessage = "Something went wrong. Please try again."
                print("Delete error:", error)
                showDeleteError = true
            }
        }
    }
}

struct DeleteResponse: Decodable {
    let message: String
}
