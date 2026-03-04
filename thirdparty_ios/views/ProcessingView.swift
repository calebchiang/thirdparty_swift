import SwiftUI

struct ProcessingView: View {
    
    let personAName: String
    let personBName: String
    let persona: Persona
    let audioURL: URL
    let onFlowComplete: () -> Void
    
    @State private var argumentId: Int?
    
    @State private var messageIndex = 0
    @State private var errorMessage: String?
    @State private var goToJudgment = false
    
    @State private var pollingTimer: Timer?
    @State private var messageTimer: Timer?
    
    @State private var hasCompleted = false
    @State private var finishedMessageCycle = false
    
    @State private var pulse = false
    @State private var glowOpacity: Double = 0.3
    @State private var messageOpacity: Double = 1
    @State private var judgment: JudgmentResponse?
    
    private let messages = [
        "Analyzing arguments...",
        "Weighing the evidence...",
        "Consulting legal precedents...",
        "Researching relevant facts...",
        "Preparing verdict..."
    ]
    
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
            
            glowOrbs
            
            if let errorMessage {
                errorView(message: errorMessage)
            } else {
                contentView
                    .transaction { transaction in
                                transaction.animation = nil
                            }
            }
        }
        .onAppear {
            startAnimations()
            uploadArgument()
            startMessageCycle()
        }
        .onDisappear {
            pollingTimer?.invalidate()
            messageTimer?.invalidate()
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goToJudgment) {
            if let judgment {
                JudgmentView(
                    judgment: judgment,
                    personAName: personAName,
                    personBName: personBName,
                    onDone: onFlowComplete 
                )
            }
        }
    }
}

private extension ProcessingView {
    
    var glowOrbs: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Colors.primary.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 120)
                .offset(x: 120, y: -120)
                .opacity(glowOpacity)
            
            Circle()
                .fill(DesignSystem.Colors.secondary.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 120)
                .offset(x: -150, y: 200)
                .opacity(glowOpacity)
        }
        .ignoresSafeArea()
    }
    
    var contentView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .scaleEffect(pulse ? 1.1 : 1.0)
                    .modifier(DesignSystem.Shadows.glowGreen())
                
                Circle()
                    .fill(DesignSystem.Colors.bgCard)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(DesignSystem.Colors.primary.opacity(0.4), lineWidth: 2)
                    )
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(DesignSystem.Colors.primary)
                        .frame(width: 10, height: 10)
                        .opacity(pulse ? 1 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: pulse
                        )
                }
            }
            
            Text(messages[messageIndex])
                .font(DesignSystem.Typography.h3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(messageOpacity)
                .animation(.easeInOut(duration: 0.2), value: messageOpacity)
            
            Text("Our AI is carefully considering both sides of the argument")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            progressBar
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }
    
    var progressBar: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Colors.bgCard)
                    .frame(height: 6)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary,
                                DesignSystem.Colors.primaryDark
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progressWidth, height: 6)
                    .animation(.easeInOut(duration: 0.4), value: messageIndex)
            }
            .frame(width: 220)
        }
    }
    
    var progressWidth: CGFloat {
        let total: CGFloat = 220
        let progress = CGFloat(messageIndex + 1) / CGFloat(messages.count)
        return total * progress
    }
    
    func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.error.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(DesignSystem.Colors.error)
            }
            
            Text("Something went wrong")
                .font(DesignSystem.Typography.h2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Button {
                onFlowComplete()
            } label: {
                Text("Go Back")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: 200)
                    .padding(.vertical, 12)
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
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
    }
}

private extension ProcessingView {
    
    func startAnimations() {
        withAnimation(
            .easeInOut(duration: 1)
            .repeatForever(autoreverses: true)
        ) {
            pulse.toggle()
        }
        
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            glowOpacity = 0.6
        }
    }
    
    func uploadArgument() {
        RequestManager.shared.uploadArgument(
            personAName: personAName,
            personBName: personBName,
            persona: persona.backendValue,
            audioURL: audioURL
        ) { result in
            
            switch result {
            case .success(let argument):
                argumentId = argument.id
                startPolling()
                
            case .failure(let error):
                
                let message = error.localizedDescription.lowercased()
                
                if message.contains("credit") {
                    errorMessage = "You don't have enough credits to generate a verdict."
                } else {
                    errorMessage = "Failed to analyze conversation."
                }
            }
        }
    }
    
    func startMessageCycle() {
        messageTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            
            withAnimation {
                messageOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if messageIndex < messages.count - 1 {
                    messageIndex += 1
                } else {
                    finishedMessageCycle = true
                    timer.invalidate()
                    checkIfReadyToNavigate()
                }
                
                withAnimation {
                    messageOpacity = 1
                }
            }
        }
    }
    
    func startPolling() {
        guard let id = argumentId else { return }
        
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            checkArgumentStatus(id: id)
        }
    }
    
    func checkArgumentStatus(id: Int) {
        RequestManager.shared.sendRequest(
            endpoint: "/arguments/\(id)",
            method: "GET",
            responseType: ArgumentDetailResponse.self
        ) { result in
            
            switch result {
            case .success(let argument):
                
                let normalized = argument.Status
                    .lowercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if normalized.contains("complete") {
                    hasCompleted = true
                    judgment = argument.Judgment
                    pollingTimer?.invalidate()
                    checkIfReadyToNavigate()
                }
                
                if normalized == "failed" {
                    pollingTimer?.invalidate()
                    errorMessage = "Failed to generate judgment."
                }
                
            case .failure:
                errorMessage = "Network error."
            }
        }
    }
    
    func checkIfReadyToNavigate() {
        if hasCompleted && finishedMessageCycle {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                goToJudgment = true
            }
        }
    }
}

struct ArgumentDetailResponse: Decodable {
    let ID: Int
    let UserID: Int
    let PersonAName: String
    let PersonBName: String
    let Persona: String
    let Transcription: String
    let Status: String
    let CreatedAt: String
    let Judgment: JudgmentResponse?
}

struct JudgmentResponse: Decodable {
    let ID: Int
    let ArgumentID: Int
    let Winner: String
    let Reasoning: String
    let FullResponse: String
    
    let Respect: Int
    let Empathy: Int
    let Accountability: Int
    let EmotionalRegulation: Int
    let ManipulationToxicity: Int
    let ConversationHealthScore: Int
    
    let CreatedAt: String
}

struct ArgumentResponse: Decodable {
    let id: Int
    let user_id: Int
    let person_a_name: String
    let person_b_name: String
    let persona: String
    let status: String
    let created_at: String
}
