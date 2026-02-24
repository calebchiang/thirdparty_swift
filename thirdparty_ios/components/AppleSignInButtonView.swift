import SwiftUI
import AuthenticationServices

struct AppleSignInButtonView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            startSignInWithAppleFlow()
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                
                Image(systemName: "apple.logo")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Sign in with Apple")
                    .font(DesignSystem.Typography.button)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.black)
            .clipShape(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.button)
            )
            .scaleEffect(isPressed ? DesignSystem.Animation.pressedScale : 1)
            .animation(DesignSystem.Animation.fast, value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private func startSignInWithAppleFlow() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = AppleSignInCoordinator.shared
        controller.presentationContextProvider = AppleSignInCoordinator.shared
        controller.performRequests()
    }
}
