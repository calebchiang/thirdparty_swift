import SwiftUI

struct HomeView: View {
    
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
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                
                Spacer()
                
                Text("ThirdParty")
                    .font(DesignSystem.Typography.hero)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Your unbiased AI mediator")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        }
    }
}

#Preview {
    HomeView()
}
