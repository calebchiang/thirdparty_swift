//
//  ScreenshotProcessingView.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-27.
//

import SwiftUI
import UIKit

struct ScreenshotProcessingView: View {
    
    let personAName: String
    let personBName: String
    let persona: Persona
    let images: [UIImage]
    let onFlowComplete: () -> Void
    
    @State private var messageIndex = 0
    @State private var errorMessage: String?
    @State private var goToJudgment = false
    
    @State private var messageTimer: Timer?
    @State private var finishedMessageCycle = false
    
    @State private var pulse = false
    @State private var glowOpacity: Double = 0.3
    @State private var messageOpacity: Double = 1
    @State private var judgment: JudgmentResponse?
    @State private var hasCompleted = false
    
    private let messages = [
        "Analyzing conversation...",
        "Extracting messages...",
        "Evaluating tone...",
        "Assessing behavior...",
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
            startMessageCycle()
            uploadScreenshots()
        }
        .onDisappear {
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

private extension ScreenshotProcessingView {
    
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

            progressBar
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }
    
    var progressBar: some View {
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
    
    var progressWidth: CGFloat {
        let total: CGFloat = 220
        let progress = CGFloat(messageIndex + 1) / CGFloat(messages.count)
        return total * progress
    }
}

private extension ScreenshotProcessingView {
    
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
    
    func startMessageCycle() {
        messageTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            
            withAnimation { messageOpacity = 0 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if messageIndex < messages.count - 1 {
                    messageIndex += 1
                } else {
                    finishedMessageCycle = true
                    timer.invalidate()
                    checkIfReady()
                }
                withAnimation { messageOpacity = 1 }
            }
        }
    }
    
    func uploadScreenshots() {
        RequestManager.shared.uploadScreenshots(
            personAName: personAName,
            personBName: personBName,
            persona: persona.backendValue,
            images: images
        ) { result in
            
            switch result {
            case .success(let argument):
                hasCompleted = true
                judgment = argument.judgment
                checkIfReady()
                
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
    
    func checkIfReady() {
        if hasCompleted && finishedMessageCycle {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                goToJudgment = true
            }
        }
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
