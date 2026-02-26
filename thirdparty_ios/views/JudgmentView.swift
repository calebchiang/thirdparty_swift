import SwiftUI
import UIKit

struct JudgmentView: View {
    
    let judgment: JudgmentResponse
    let personAName: String
    let personBName: String
    
    @State private var animateIn = false
    @State private var animateDonut = false
    
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
                        
            VStack(spacing: 0) {
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: DesignSystem.Spacing.xl) {
                            
                            headerSection
                            winnerCard
                            conversationHealthSection(proxy: proxy)
                            healthBreakdown
                                .id("healthBreakdown")
                            reasoningSection
                            
                        }
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        .padding(.top, DesignSystem.Spacing.xl)
                        .padding(.bottom, DesignSystem.Spacing.xxl)
                    }
                }
                
                brandingSection
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .padding(.top, 4)
                    .padding(.bottom, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.bgPrimary)
                
                bottomActions
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .padding(.bottom, DesignSystem.Spacing.lg)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(DesignSystem.Animation.dramatic) {
                animateIn = true
            }
            withAnimation(.easeOut(duration: 1.0)) {
                animateDonut = true
            }
        }
    }
}

private extension JudgmentView {
    
    func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    var healthScore: Int {
        judgment.ConversationHealthScore
    }
    
    var healthColor: Color {
        switch healthScore {
        case 0..<50: return .red
        case 50..<80: return .yellow
        default: return .green
        }
    }
    
    var healthSummaryText: String {
        switch healthScore {
        case 0..<20: return "Very toxic argument"
        case 20..<40: return "Toxic argument"
        case 40..<60: return "Unhealthy communication"
        case 60..<80: return "Moderately healthy discussion"
        default: return "Healthy and constructive discussion"
        }
    }
    
    var spotlightGlow: some View {
        Circle()
            .fill(winnerColor.opacity(0.15))
            .frame(width: 400, height: 400)
            .blur(radius: 120)
            .offset(y: -150)
            .opacity(animateIn ? 1 : 0)
    }
    
    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("THE VERDICT")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(DesignSystem.Colors.primary)
                .tracking(2)
            
            Text("\(personAName) vs \(personBName)")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .opacity(animateIn ? 1 : 0)
    }
    
    var winnerCard: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            
            ZStack {
                Circle()
                    .fill(winnerColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 36))
                    .foregroundColor(winnerColor)
            }
            
            Text(judgment.Winner == "tie" ? "IT'S A TIE" : "WINNER")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(DesignSystem.Colors.textMuted)
                .tracking(1.5)
            
            Text(displayWinner)
                .font(DesignSystem.Typography.hero)
                .foregroundColor(winnerColor)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.bgCard)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xxl)
                .stroke(winnerColor.opacity(0.6), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.xxl))
    }
    
    // MARK: Conversation Health (Scroll Trigger)
    
    func conversationHealthSection(proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            
            Text("CONVERSATION HEALTH SCORE")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(DesignSystem.Colors.textMuted)
                .tracking(1.5)
            
            VStack(spacing: DesignSystem.Spacing.md) {
                
                ZStack {
                    Circle()
                        .stroke(DesignSystem.Colors.borderLight, lineWidth: 14)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0,
                              to: animateDonut
                              ? CGFloat(healthScore) / 100
                              : 0)
                        .stroke(
                            healthColor,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 150, height: 150)
                        .animation(.easeOut(duration: 1.0), value: animateDonut)
                    
                    Text("\(healthScore)%")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(healthColor)
                }
                
                Text(healthSummaryText)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(healthColor)
                
                Text("Tap to view breakdown")
                    .font(.system(size: 11))
                    .foregroundColor(DesignSystem.Colors.textMuted)
                    .opacity(0.7)
            }
            .padding(DesignSystem.Spacing.cardPadding)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.bgCard)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(DesignSystem.Colors.border)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
            .onTapGesture {
                lightHaptic()
                withAnimation(.easeInOut(duration: 0.6)) {
                    proxy.scrollTo("healthBreakdown", anchor: .top)
                }
            }
        }
        .opacity(animateIn ? 1 : 0)
    }
    
    var healthBreakdown: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            categoryRow(title: "Respect", value: judgment.Respect)
            categoryRow(title: "Empathy", value: judgment.Empathy)
            categoryRow(title: "Accountability", value: judgment.Accountability)
            categoryRow(title: "Emotional Regulation", value: judgment.EmotionalRegulation)
            categoryRow(title: "Manipulation / Toxicity", value: judgment.ManipulationToxicity)
        }
    }
    
    func categoryRow(title: String, value: Int) -> some View {
        
        // Individual color per category
        let categoryColor: Color = {
            switch value {
            case 0...3:
                return .red
            case 4...6:
                return .yellow
            default:
                return .green
            }
        }()
        
        return VStack(alignment: .leading, spacing: 6) {
            
            HStack {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Text("\(value)/10")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(categoryColor)
            }
            
            HStack(spacing: 4) {
                ForEach(0..<10) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            index < value
                            ? categoryColor
                            : DesignSystem.Colors.bgTertiary
                        )
                        .frame(height: 6)
                }
            }
        }
    }
    
    var reasoningSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            
            Text("THE REASONING")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(DesignSystem.Colors.textMuted)
                .tracking(1.5)
            
            Text(judgment.Reasoning)
                .font(DesignSystem.Typography.body)
                .padding(DesignSystem.Spacing.cardPadding)
                .background(DesignSystem.Colors.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                        .stroke(DesignSystem.Colors.border)
                )
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        }
    }
    
    var brandingSection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Rectangle().fill(DesignSystem.Colors.divider).frame(height: 1)
            Text("Settled with ThirdParty")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textMuted)
            Rectangle().fill(DesignSystem.Colors.divider).frame(height: 1)
        }
    }
    
    var bottomActions: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            
            Button(action: { lightHaptic() }) {
                Image(systemName: "camera")
                    .frame(width: 52, height: 52)
                    .background(DesignSystem.Colors.bgTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Button(action: { lightHaptic() }) {
                Image(systemName: "square.and.arrow.up")
                    .frame(width: 52, height: 52)
                    .background(DesignSystem.Colors.bgTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Button(action: { lightHaptic() }) {
                Text("Done")
                    .font(DesignSystem.Typography.button)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary,
                                     DesignSystem.Colors.primaryDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.button))
            }
        }
    }
    
    var winnerColor: Color {
        switch judgment.Winner {
        case "person_a": return DesignSystem.Colors.secondary
        case "person_b": return DesignSystem.Colors.primary
        default: return DesignSystem.Colors.primary
        }
    }
    
    var displayWinner: String {
        switch judgment.Winner {
        case "person_a": return personAName
        case "person_b": return personBName
        case "tie": return "Tie"
        default: return judgment.Winner
        }
    }
}
