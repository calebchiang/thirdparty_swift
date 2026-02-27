import SwiftUI

enum SetupMode: Identifiable {
    case live
    case upload
    case screenshot
    
    var id: String {
        switch self {
        case .live: return "live"
        case .upload: return "upload"
        case .screenshot: return "screenshot"
        }
    }
}

struct LiveSession: Identifiable, Hashable {
    let id = UUID()
    let personA: String
    let personB: String
    let persona: Persona
}

struct SetupView: View {
    
    @Environment(\.dismiss) private var dismiss
    let mode: SetupMode
    
    @State private var personAName: String = ""
    @State private var personBName: String = ""
    @State private var selectedPersona: Persona = .mediator
    @State private var animateJudges: Bool = false
    @State private var buttonPressed: Bool = false
    @State private var liveSession: LiveSession?
    @State private var uploadSession: LiveSession?
    
    let onFlowComplete: () -> Void
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case personA
        case personB
    }
    
    var canProceed: Bool {
        !personAName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !personBName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var ctaText: String {
        switch mode {
        case .live: return "Start Recording"
        case .upload: return "Upload Audio"
        case .screenshot: return "Upload Screenshot"
        }
    }
    
    var overlineText: String {
        switch mode {
        case .live: return "LIVE DEBATE"
        case .upload: return "UPLOAD AUDIO"
        case .screenshot: return "SCREENSHOT"
        }
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationBarHidden(true)
                .navigationDestination(item: $liveSession) { session in
                    LiveModeView(
                        personAName: session.personA,
                        personBName: session.personB,
                        persona: session.persona,
                        onFlowComplete: onFlowComplete
                    )
                }
                .navigationDestination(item: $uploadSession) { session in
                    UploadModeView(
                        personAName: session.personA,
                        personBName: session.personB,
                        persona: session.persona,
                        onFlowComplete: onFlowComplete
                    )
                }
        }
    }
    
    private var content: some View {
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
                
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                        participantsSection
                        judgesSection
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .padding(.top, DesignSystem.Spacing.xl)
                }
                
                footerCTA
            }
        }
        .onAppear {
            animateJudges = false
            DispatchQueue.main.async {
                animateJudges = true
            }
        }
    }
    
    // MARK: Header
    
    private var header: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            
            Button {
                dismiss()
                lightHaptic()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.bgTertiary)
                    )
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(overlineText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .tracking(1.5)
                
                Text("Set the Stage")
                    .font(DesignSystem.Typography.h2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .padding(.vertical, DesignSystem.Spacing.md)
        .overlay(
            Divider().background(DesignSystem.Colors.divider),
            alignment: .bottom
        )
    }
    
    // MARK: Participants
    
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            
            Text("PARTICIPANTS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textMuted)
                .tracking(1.5)
            
            participantInput(
                title: "First person's name",
                text: $personAName,
                field: .personA,
                accent: DesignSystem.Colors.primary
            )
            
            HStack {
                Rectangle().fill(DesignSystem.Colors.border).frame(height: 1)
                Text("VS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textMuted)
                    .tracking(2)
                Rectangle().fill(DesignSystem.Colors.border).frame(height: 1)
            }
            
            participantInput(
                title: "Second person's name",
                text: $personBName,
                field: .personB,
                accent: DesignSystem.Colors.secondary
            )
        }
    }
    
    // MARK: Judges
    
    private var judgesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            
            Text("CHOOSE YOUR JUDGE")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textMuted)
                .tracking(1.5)
            
            ForEach(Array(Persona.allCases.enumerated()), id: \.element) { index, persona in
                judgeCard(persona: persona)
                    .opacity(animateJudges ? 1 : 0)
                    .offset(x: animateJudges ? 0 : 40)
                    .animation(
                        .easeOut(duration: 0.4)
                        .delay(Double(index) * 0.1),
                        value: animateJudges
                    )
            }
        }
    }
    
    // MARK: Footer CTA
    
    private var footerCTA: some View {
        VStack {
            Divider()
            
            Button {
                mediumHaptic()
                
                if mode == .live {
                    liveSession = LiveSession(
                        personA: personAName,
                        personB: personBName,
                        persona: selectedPersona
                    )
                } else if mode == .upload {
                    uploadSession = LiveSession(
                        personA: personAName,
                        personB: personBName,
                        persona: selectedPersona
                    )
                }
                
            } label: {
                HStack {
                    Text(ctaText)
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(canProceed ? .white : DesignSystem.Colors.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: canProceed
                        ? [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.7)]
                        : [DesignSystem.Colors.bgTertiary, DesignSystem.Colors.bgTertiary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
                .scaleEffect(buttonPressed ? 0.96 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: buttonPressed)
            }
            .disabled(!canProceed)
            .buttonStyle(.plain)
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            .padding(.vertical, 12)
        }
        .background(DesignSystem.Colors.bgPrimary)
    }
    
    // MARK: Participant Input
    
    private func participantInput(
        title: String,
        text: Binding<String>,
        field: Field,
        accent: Color
    ) -> some View {
        HStack(spacing: 0) {
            Rectangle().fill(accent).frame(width: 4)
            
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(
                        focusedField == field
                        ? accent
                        : DesignSystem.Colors.textMuted
                    )
                
                TextField(title, text: text)
                    .focused($focusedField, equals: field)
                    .textInputAutocapitalization(.words)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            .padding()
        }
        .background(
            focusedField == field
            ? DesignSystem.Colors.bgElevated
            : DesignSystem.Colors.bgCard
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                .stroke(
                    focusedField == field
                    ? DesignSystem.Colors.borderLight
                    : DesignSystem.Colors.border,
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
    }
    
    // MARK: Judge Card
    
    private func judgeCard(persona: Persona) -> some View {
        Button {
            lightHaptic()
            selectedPersona = persona
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignSystem.Colors.bgTertiary)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: persona.icon)
                        .foregroundColor(
                            selectedPersona == persona
                            ? DesignSystem.Colors.primary
                            : DesignSystem.Colors.textSecondary
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(persona.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(
                            selectedPersona == persona
                            ? DesignSystem.Colors.primary
                            : DesignSystem.Colors.textPrimary
                        )
                    Text(persona.description)
                        .font(.system(size: 13))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(
                            selectedPersona == persona
                            ? DesignSystem.Colors.primary
                            : DesignSystem.Colors.border,
                            lineWidth: 2
                        )
                        .frame(width: 22, height: 22)
                    
                    if selectedPersona == persona {
                        Circle()
                            .fill(DesignSystem.Colors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding()
            .background(DesignSystem.Colors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: Haptics
    
    private func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func mediumHaptic() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

#Preview {
    SetupView(
        mode: .live,
        onFlowComplete: {}
    )
}
