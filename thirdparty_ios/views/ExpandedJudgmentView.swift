import SwiftUI
import UIKit

struct ExpandedHistoryView: View {
    
    let argument: HistoryArgumentResponse
    let judgment: HistoryJudgmentResponse
    let onDelete: () -> Void
    
    @State private var animateIn = false
    @State private var animateDonut = false
    @State private var isTranscriptExpanded = false
    @State private var isReasoningExpanded = false
    
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var deleteError: String?
    
    @Environment(\.dismiss) private var dismiss
    
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
                        
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        
                        headerSection
                        winnerCard
                        
                        conversationHealthSection(proxy: proxy)
                        
                        healthBreakdown
                            .id("healthBreakdown")
                        
                        reasoningSection
                        if !argument.transcription
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty {
                            transcriptionSection
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .padding(.top, DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            
            // Left Back Button
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    lightHaptic()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
            }
            
            // Center Title
            ToolbarItem(placement: .principal) {
                Text("CASE DETAILS")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .tracking(1.5)
            }
            
            // Right Trash Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    lightHaptic()
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .frame(width: 34, height: 34)
                }
            }
        }
        .alert("Delete Case?", isPresented: $showDeleteAlert) {
            
            Button("Cancel", role: .cancel) { }
            
            Button("Delete", role: .destructive) {
                deleteArgument()
            }
            
        } message: {
            Text("If you delete this case, all data including transcript and judgment will be permanently lost.")
        }
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

private extension ExpandedHistoryView {
    
    func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: Computed Values
    
    var healthScore: Int {
        judgment.conversationHealthScore
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
    
    var winnerColor: Color {
        switch judgment.winner {
        case "person_a": return DesignSystem.Colors.secondary
        case "person_b": return DesignSystem.Colors.primary
        default: return DesignSystem.Colors.primary
        }
    }
    
    var displayWinner: String {
        switch judgment.winner {
        case "person_a": return argument.personAName
        case "person_b": return argument.personBName
        case "tie": return "Tie"
        default: return judgment.winner
        }
    }
    
    var headerSection: some View {
        
        VStack(spacing: 10) {
            
            HStack(spacing: 16) {
                
                participantPill(
                    name: argument.personAName,
                    color: DesignSystem.Colors.secondary
                )
                
                Text("VS")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(DesignSystem.Colors.textMuted)
                    .tracking(1.5)
                
                participantPill(
                    name: argument.personBName,
                    color: DesignSystem.Colors.primary
                )
            }
            
            Text(formattedDate)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textMuted)
                .opacity(0.8)
            
        }
        .frame(maxWidth: .infinity)
        .opacity(animateIn ? 1 : 0)
    }
    
    var formattedDate: String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: argument.createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        }
        
        return ""
    }
    
    func participantPill(name: String, color: Color) -> some View {
        
        HStack(spacing: 8) {
            
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(name)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(DesignSystem.Colors.bgCard)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
    
    // MARK: Winner Card
    
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
            
            Text(judgment.winner == "tie" ? "IT'S A TIE" : "WINNER")
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
    
    // MARK: Conversation Health
    
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
    
    // MARK: Breakdown
    
    var healthBreakdown: some View {
        
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            
            Text("BREAKDOWN")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(DesignSystem.Colors.textMuted)
                .tracking(1.5)
            
            VStack(spacing: DesignSystem.Spacing.md) {
                categoryRow(title: "Respect", value: judgment.respect)
                categoryRow(title: "Empathy", value: judgment.empathy)
                categoryRow(title: "Accountability", value: judgment.accountability)
                categoryRow(title: "Emotional Regulation", value: judgment.emotionalRegulation)
                categoryRow(title: "Manipulation / Toxicity", value: judgment.manipulationToxicity)
            }
            .padding(DesignSystem.Spacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignSystem.Colors.bgCard)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(DesignSystem.Colors.border)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        }
    }
    
    func categoryRow(title: String, value: Int) -> some View {
        
        let categoryColor: Color = {
            switch value {
            case 0...3: return .red
            case 4...6: return .yellow
            default: return .green
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
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(judgment.reasoning)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(isReasoningExpanded ? nil : 4)
                    .animation(.easeInOut(duration: 0.25), value: isReasoningExpanded)
                
                if !isReasoningExpanded {
                    Text("Tap to view more")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textMuted)
                        .opacity(0.7)
                }
            }
            .padding(DesignSystem.Spacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignSystem.Colors.bgCard)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(DesignSystem.Colors.border)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
            .contentShape(Rectangle())
            .onTapGesture {
                lightHaptic()
                withAnimation(.easeInOut(duration: 0.25)) {
                    isReasoningExpanded.toggle()
                }
            }
        }
    }
    
    // MARK: Transcription

    var transcriptionSection: some View {
        
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            
            Text("TRANSCRIPT")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(DesignSystem.Colors.textMuted)
                .tracking(1.5)
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(argument.transcription)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(isTranscriptExpanded ? nil : 3)
                    .animation(.easeInOut(duration: 0.25), value: isTranscriptExpanded)
                
                if !isTranscriptExpanded {
                    Text("Tap to view more")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textMuted)
                        .opacity(0.7)
                }
            }
            .padding(DesignSystem.Spacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignSystem.Colors.bgCard)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(DesignSystem.Colors.border)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
            .contentShape(Rectangle())
            .onTapGesture {
                lightHaptic()
                withAnimation(.easeInOut(duration: 0.25)) {
                    isTranscriptExpanded.toggle()
                }
            }
        }
    }
    
    func deleteArgument() {
        
        guard !isDeleting else { return }
        
        isDeleting = true
        deleteError = nil
        
        RequestManager.shared.sendRequest(
            endpoint: "/arguments/\(argument.id)",
            method: "DELETE",
            responseType: EmptyResponse.self
        ) { result in
            
            isDeleting = false
            
            switch result {
            case .success:
                lightHaptic()
                
                // Instantly update parent list
                onDelete()
                
                // Dismiss back
                dismiss()
                
            case .failure:
                deleteError = "Failed to delete case."
            }
        }
    }
}

struct EmptyResponse: Decodable {}
