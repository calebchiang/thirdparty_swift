//
//  HistoryView.swift
//  thirdparty_ios
//

import SwiftUI

struct HistoryArgumentResponse: Decodable, Identifiable {
    let id: Int
    let userId: Int
    let personAName: String
    let personBName: String
    let persona: String
    let status: String
    let createdAt: String
    let transcription: String
    let judgment: HistoryJudgmentResponse?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case userId = "UserID"
        case personAName = "PersonAName"
        case personBName = "PersonBName"
        case persona = "Persona"
        case status = "Status"
        case createdAt = "CreatedAt"
        case transcription = "Transcription"
        case judgment = "Judgment"
    }
}

struct HistoryJudgmentResponse: Decodable {
    let id: Int
    let winner: String
    let reasoning: String
    let fullResponse: String
    
    let respect: Int
    let empathy: Int
    let accountability: Int
    let emotionalRegulation: Int
    let manipulationToxicity: Int
    
    let conversationHealthScore: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case winner = "Winner"
        case reasoning = "Reasoning"
        case fullResponse = "FullResponse"
        case respect = "Respect"
        case empathy = "Empathy"
        case accountability = "Accountability"
        case emotionalRegulation = "EmotionalRegulation"
        case manipulationToxicity = "ManipulationToxicity"
        case conversationHealthScore = "ConversationHealthScore"
    }
}

struct HistoryView: View {
    
    @State private var arguments: [HistoryArgumentResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var animateCards = false
    
    func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    var body: some View {
        NavigationStack {
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
                
                glowOrbs
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    
                    headerSection
                    
                    contentSection
                    
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .padding(.top, DesignSystem.Spacing.xl)
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchArguments()
            }
        }
    }
}

// MARK: - Header

private extension HistoryView {
    
    var contentSection: some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(DesignSystem.Colors.primary)
                    .padding(.top, DesignSystem.Spacing.lg)
            }
            else if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(DesignSystem.Colors.error)
                    .padding(.top, DesignSystem.Spacing.lg)
            }
            else if arguments.isEmpty {
                Text("No verdicts yet.")
                    .foregroundColor(DesignSystem.Colors.textMuted)
                    .padding(.top, DesignSystem.Spacing.lg)
            }
            else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        
                        ForEach(Array(arguments.enumerated()), id: \.element.id) { index, argument in
                            
                            if let judgment = argument.judgment {
                                
                                NavigationLink {
                                    ExpandedHistoryView(
                                        argument: argument,
                                        judgment: judgment,
                                        onDelete: {
                                                   withAnimation(.easeInOut) {
                                                       arguments.removeAll { $0.id == argument.id }
                                                   }
                                               }
                                    )
                                } label: {
                                    historyCard(argument)
                                        .opacity(animateCards ? 1 : 0)
                                        .offset(y: animateCards ? 0 : 20)
                                        .animation(
                                            .easeOut(duration: 0.5)
                                                .delay(Double(index) * 0.05),
                                            value: animateCards
                                        )
                                }
                                .buttonStyle(.plain)
                                .simultaneousGesture(
                                    TapGesture().onEnded {
                                        lightHaptic()
                                    }
                                )
                                
                            } else {
                                historyCard(argument)
                            }
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.md)
                }
            }
        }
    }
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("YOUR CASES")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.primary)
                .tracking(2)
            
            Text("History")
                .font(DesignSystem.Typography.h1)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            if !arguments.isEmpty {
                Text("\(arguments.count) verdict\(arguments.count != 1 ? "s" : "") rendered")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .padding(.top, 4)
            }
            
            Rectangle()
                .fill(DesignSystem.Colors.divider)
                .frame(height: 1)
                .padding(.top, 12)
        }
    }
}

// MARK: - Card

private extension HistoryView {
    
    func historyCard(_ argument: HistoryArgumentResponse) -> some View {
        
        let winnerColor: Color? = {
            guard let winner = argument.judgment?.winner else { return nil }
            switch winner {
            case "person_a": return DesignSystem.Colors.secondary
            case "person_b": return DesignSystem.Colors.primary
            case "tie": return DesignSystem.Colors.primary
            default: return nil
            }
        }()
        
        return VStack(spacing: 0) {
            
            if let winnerColor {
                Rectangle()
                    .fill(winnerColor)
                    .frame(height: 3)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                
                // Header row (Names + Date)
                HStack(alignment: .top) {
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(DesignSystem.Colors.secondary)
                            .frame(width: 8, height: 8)
                        
                        Text(argument.personAName)
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("vs")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textMuted)
                        
                        Circle()
                            .fill(DesignSystem.Colors.primary)
                            .frame(width: 8, height: 8)
                        
                        Text(argument.personBName)
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text(formattedDate(from: argument.createdAt))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textMuted)
                }
                
                if let judgment = argument.judgment {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12))
                            .foregroundColor(winnerColor)
                        
                        Text(
                            judgment.winner == "tie"
                            ? "Tie"
                            : "\(winnerName(for: judgment.winner, argument: argument)) wins"
                        )
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(winnerColor)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(winnerColor?.opacity(0.15))
                    .cornerRadius(DesignSystem.Radius.sm)
                }
                
                Rectangle()
                    .fill(DesignSystem.Colors.divider)
                    .frame(height: 1)
                
                // Footer row (Health left, Chevron right)
                HStack {
                    
                    if let health = argument.judgment?.conversationHealthScore {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text("\(health)%")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(DesignSystem.Colors.bgTertiary)
                        .cornerRadius(DesignSystem.Radius.sm)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(DesignSystem.Colors.textMuted)
                }
            }
            .padding(DesignSystem.Spacing.cardPadding)
        }
        .background(DesignSystem.Colors.bgCard)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
        .cornerRadius(DesignSystem.Radius.xl)
    }
    
    func formattedDate(from string: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        guard let date = formatter.date(from: string) else {
            return ""
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        }
        
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMMM d, yyyy"
        return displayFormatter.string(from: date)
    }
    
    func winnerName(for winner: String, argument: HistoryArgumentResponse) -> String {
        switch winner {
        case "person_a": return argument.personAName
        case "person_b": return argument.personBName
        case "tie": return "Tie"
        default: return winner
        }
    }
}

// MARK: - Glow Background

private extension HistoryView {
    
    var glowOrbs: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Colors.primary.opacity(0.2))
                .frame(width: 250, height: 250)
                .blur(radius: 120)
                .offset(x: 120, y: -120)
            
            Circle()
                .fill(DesignSystem.Colors.secondary.opacity(0.2))
                .frame(width: 250, height: 250)
                .blur(radius: 120)
                .offset(x: -120, y: 200)
        }
        .ignoresSafeArea()
    }
}

// MARK: - API

private extension HistoryView {
    
    func fetchArguments() {
        isLoading = true
        errorMessage = nil
        
        RequestManager.shared.sendRequest(
            endpoint: "/arguments",
            method: "GET",
            responseType: [HistoryArgumentResponse].self
        ) { result in
            
            isLoading = false
            
            switch result {
            case .success(let data):
                arguments = data
                
                animateCards = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        animateCards = true
                    }
                }
            case .failure:
                errorMessage = "Failed to load history."
            }
        }
    }
}
