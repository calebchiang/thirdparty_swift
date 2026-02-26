import SwiftUI
import Foundation
import KeychainAccess

struct LiveModeView: View {
    
    let personAName: String
    let personBName: String
    let persona: Persona
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isRecording = false
    @State private var recordingDuration = 0
    @State private var transcript: String = ""
    @State private var timer: Timer?
    @State private var pulse = false
    
    @State private var recordedAudioURL: URL?
    @State private var goToProcessing = false
    
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
                    .fill(DesignSystem.Colors.primary.opacity(0.06))
                    .frame(width: 250, height: 250)
                    .blur(radius: 80)
                    .offset(x: 120, y: -120)
                
                Circle()
                    .fill(DesignSystem.Colors.secondary.opacity(0.06))
                    .frame(width: 250, height: 250)
                    .blur(radius: 80)
                    .offset(x: -120, y: 200)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                participantsRow
                statusSection
                transcriptSection
                controlSection
            }
        }
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                withAnimation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                ) {
                    pulse = true
                }
            } else {
                pulse = false
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goToProcessing) {
            if let url = recordedAudioURL {
                ProcessingView(
                    personAName: personAName,
                    personBName: personBName,
                    persona: persona,
                    audioURL: url
                )
            }
        }
    }
}

private extension LiveModeView {
    
    var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(DesignSystem.Colors.bgCard))
                    .overlay(Circle().stroke(DesignSystem.Colors.border))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("LIVE MODE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .tracking(1.5)
                
                Text("Recording")
                    .font(DesignSystem.Typography.h3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            Spacer()
            Spacer().frame(width: 40)
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .padding(.vertical, DesignSystem.Spacing.md)
    }
    
    var participantsRow: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            participantBubble(name: personAName, color: DesignSystem.Colors.secondary)
            
            HStack(spacing: 6) {
                Rectangle().fill(DesignSystem.Colors.border).frame(width: 20, height: 1)
                Text("VS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textMuted)
                    .tracking(2)
                Rectangle().fill(DesignSystem.Colors.border).frame(width: 20, height: 1)
            }
            
            participantBubble(name: personBName, color: DesignSystem.Colors.primary)
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
    }
    
    func participantBubble(name: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(name)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(DesignSystem.Colors.bgCard)
        .overlay(Capsule().stroke(DesignSystem.Colors.border))
        .clipShape(Capsule())
    }
    
    var statusSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            
            if isRecording {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.error.opacity(0.4))
                        .frame(width: 130, height: 130)
                        .offset(y: 30)
                    
                    ZStack {
                        Circle().fill(DesignSystem.Colors.error.opacity(0.1)).frame(width: 90, height: 90)
                        Circle().fill(DesignSystem.Colors.error.opacity(0.3)).frame(width: 54, height: 54)
                        Circle().fill(DesignSystem.Colors.error).frame(width: 28, height: 28)
                    }
                }
                .scaleEffect(pulse ? 1.12 : 1.0)
                
                Text(formatDuration(recordingDuration))
                    .font(DesignSystem.Typography.hero)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Recording in progress")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
            } else {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.primary.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .overlay(Circle().stroke(DesignSystem.Colors.primary.opacity(0.3)))
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                
                Text("Tap to start recording your conversation")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    var transcriptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("TRANSCRIPT")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textMuted)
                .tracking(1.5)
            
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .fill(DesignSystem.Colors.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                            .stroke(DesignSystem.Colors.border)
                    )
                
                Text("Transcript will appear here...")
                    .foregroundColor(DesignSystem.Colors.textMuted)
                    .italic()
            }
            .frame(height: 160)
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }
    
    var controlSection: some View {
        VStack {
            Button { toggleRecordingUI() } label: {
                HStack(spacing: 8) {
                    Image(systemName: isRecording ? "gavel.fill" : "mic.fill")
                    Text(isRecording ? "End & Get Judgment" : "Start Recording")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isRecording ?
                    AnyView(RoundedRectangle(cornerRadius: 12).stroke(DesignSystem.Colors.primary, lineWidth: 2))
                    :
                    AnyView(LinearGradient(
                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(DesignSystem.Spacing.screenPadding)
    }
    
    func toggleRecordingUI() {
        Task {
            if isRecording {
                timer?.invalidate()
                timer = nil
                
                let url = AudioManager.shared.stopRecording()
                recordingDuration = 0
                
                withAnimation { isRecording = false }
                
                if let url = url {
                    recordedAudioURL = url
                    goToProcessing = true
                }
                
            } else {
                let granted = await AudioManager.shared.requestPermission()
                guard granted else { return }
                
                do {
                    try AudioManager.shared.startRecording()
                } catch {
                    return
                }
                
                recordingDuration = 0
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    recordingDuration += 1
                }
                
                withAnimation { isRecording = true }
            }
        }
    }
}
