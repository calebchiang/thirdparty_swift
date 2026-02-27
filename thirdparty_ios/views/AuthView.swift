import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var isLoginMode: Bool = false
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    @State private var animateEntrance = false
    @State private var buttonPressed = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    private let baseURL = "https://thirdpartyserver-production.up.railway.app"
    
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
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        
                        ZStack {
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.secondary,
                                    DesignSystem.Colors.primary
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.xl))
                            
                            Image(systemName: "person.2")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(DesignSystem.Colors.textInverse)
                        }
                        
                        Text("ThirdParty")
                            .font(DesignSystem.Typography.hero)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Claim your free AI credits.")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    .scaleEffect(animateEntrance ? 1 : 0.85)
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateEntrance)
                    
                    VStack(spacing: DesignSystem.Spacing.md) {
                        
                        Text(isLoginMode ? "Welcome Back" : "Create an Account")
                            .font(DesignSystem.Typography.h2)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        inputField(icon: "envelope", placeholder: "Email", text: $email, field: .email)
                        
                        inputField(icon: "lock", placeholder: "Password", text: $password, field: .password, secure: true)
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundColor(DesignSystem.Colors.error)
                                .font(DesignSystem.Typography.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button {
                            lightHaptic()
                            withAnimation {
                                isLoginMode.toggle()
                                errorMessage = nil
                            }
                        } label: {
                            Text(
                                isLoginMode
                                ? "Don't have an account? Sign Up"
                                : "Already have an account? Login"
                            )
                            .font(.system(size: 14, weight: .medium))                          .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Button {
                            lightHaptic()
                            if isLoginMode {
                                handleLogin()
                            } else {
                                handleSignup()
                            }
                        } label: {
                            ZStack {
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primary,
                                        DesignSystem.Colors.primaryDark
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                if isLoading {
                                    ProgressView()
                                        .tint(DesignSystem.Colors.textInverse)
                                } else {
                                    HStack(spacing: DesignSystem.Spacing.sm) {
                                        Text(isLoginMode ? "Sign In" : "Claim Free Credits")
                                            .font(DesignSystem.Typography.button)
                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundColor(DesignSystem.Colors.textInverse)
                                }
                            }
                            .frame(height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.button))
                            .scaleEffect(buttonPressed ? DesignSystem.Animation.pressedScale : 1)
                            .animation(DesignSystem.Animation.fast, value: buttonPressed)
                        }
                        .disabled(isLoading)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in buttonPressed = true }
                                .onEnded { _ in buttonPressed = false }
                        )
                        
                        HStack {
                            Rectangle()
                                .fill(DesignSystem.Colors.border)
                                .frame(height: 1)
                            
                            Text("OR")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textMuted)
                                .padding(.horizontal, 8)
                            
                            Rectangle()
                                .fill(DesignSystem.Colors.border)
                                .frame(height: 1)
                        }
                        .padding(.vertical, 4)
                        
                        AppleSignInButtonView()
                            .environmentObject(auth)
                        
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.xxl)
                            .fill(DesignSystem.Colors.bgCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.xxl)
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    
                    VStack(spacing: DesignSystem.Spacing.md) {
                        
                        HStack(spacing: DesignSystem.Spacing.md) {
                            Rectangle()
                                .fill(DesignSystem.Colors.border)
                                .frame(height: 1)
                                .frame(maxWidth: 40)
                            
                            Text("Fair judgments, every time")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textMuted)
                                .italic()
                            
                            Rectangle()
                                .fill(DesignSystem.Colors.border)
                                .frame(height: 1)
                                .frame(maxWidth: 40)
                        }
                        
                        HStack(spacing: DesignSystem.Spacing.xl) {
                            
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "shield.checkmark")
                                    .font(.system(size: 14))
                                    .foregroundColor(DesignSystem.Colors.primary)
                                Text("Private")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textMuted)
                            }
                            
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(DesignSystem.Colors.secondary)
                                Text("Instant")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textMuted)
                            }
                            
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "rosette")
                                    .font(.system(size: 14))
                                    .foregroundColor(DesignSystem.Colors.primary)
                                Text("Unbiased")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textMuted)
                            }
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.xxl)
            }
        }
        .onAppear {
            animateEntrance = true
            AppleSignInCoordinator.shared.authViewModel = auth
        }
    }
    
    func lightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @ViewBuilder
    func inputField(icon: String,
                    placeholder: String,
                    text: Binding<String>,
                    field: Field,
                    secure: Bool = false) -> some View {
        
        HStack {
            Image(systemName: icon)
                .foregroundColor(
                    focusedField == field
                    ? DesignSystem.Colors.primary
                    : DesignSystem.Colors.textMuted
                )
            
            if secure {
                SecureField(
                    "",
                    text: text,
                    prompt: Text(placeholder)
                        .foregroundColor(DesignSystem.Colors.textMuted)
                )
                .focused($focusedField, equals: field)
                .autocapitalization(.none)
            } else {
                TextField(
                    "",
                    text: text,
                    prompt: Text(placeholder)
                        .foregroundColor(DesignSystem.Colors.textMuted)
                )
                .focused($focusedField, equals: field)
                .autocapitalization(.none)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.input)
                .fill(DesignSystem.Colors.bgTertiary)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.input)
                        .stroke(
                            focusedField == field
                            ? DesignSystem.Colors.primary
                            : DesignSystem.Colors.border,
                            lineWidth: 1
                        )
                )
        )
        .foregroundColor(DesignSystem.Colors.textPrimary)
    }
    
    func handleSignup() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/users") else { return }
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    return
                }
                
                if httpResponse.statusCode == 201 {
                    handleLogin()
                } else {
                    errorMessage = "Signup failed"
                }
            }
        }.resume()
    }
    
    func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password required"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/login") else { return }
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let data,
                      let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    return
                }
                
                if httpResponse.statusCode == 200,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    auth.saveToken(token)
                } else {
                    errorMessage = "Invalid email or password"
                }
            }
        }.resume()
    }
}
