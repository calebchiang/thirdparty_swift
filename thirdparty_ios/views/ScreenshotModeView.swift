//
//  ScreenshotModeView.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-27.
//

import SwiftUI
import PhotosUI

struct ScreenshotModeView: View {
    
    let personAName: String
    let personBName: String
    let persona: Persona
    let onFlowComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showPhotoPicker = false
    @State private var loadedImages: [UIImage] = []
    @State private var goToProcessing = false
    
    private var hasSelection: Bool {
        !selectedItems.isEmpty
    }
    
    private func loadSelectedImages() {
        loadedImages.removeAll()
        
        for item in selectedItems {
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    DispatchQueue.main.async {
                        loadedImages.append(uiImage)
                    }
                }
            }
        }
    }
    
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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    participantsRow
                    content
                    bottomSection
                }
                .padding(.bottom, 8)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: selectedItems) {
            loadSelectedImages()
        }
        .navigationDestination(isPresented: $goToProcessing) {
            ScreenshotProcessingView(
                personAName: personAName,
                personBName: personBName,
                persona: persona,
                images: loadedImages,
                onFlowComplete: onFlowComplete
            )
        }
    }
}

private extension ScreenshotModeView {
    
    // MARK: Header
    
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
                Text("SCREENSHOT MODE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .tracking(1.5)
                
                Text("Upload Screenshot")
                    .font(DesignSystem.Typography.h3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            Spacer()
            Spacer().frame(width: 40)
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .padding(.vertical, DesignSystem.Spacing.md)
    }
    
    // MARK: Participants
    
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
    
    // MARK: Content
    
    var content: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            
            Text("Upload screenshots of your text conversation.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            
            screenshotCard
        }
    }
    
    // MARK: Screenshot Card
    
    var screenshotCard: some View {
        GeometryReader { geo in
            
            let cardWidth = geo.size.width * 0.6
            let cardHeight = cardWidth * 1.7
            
            Button {
                lightHaptic()
                showPhotoPicker = true
            } label: {
                cardContent(width: cardWidth, height: cardHeight)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedItems,
                maxSelectionCount: 10,
                matching: .images
            )
        }
        .frame(height: 400)
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }
    
    // MARK: Combined Bottom Section
    
    var bottomSection: some View {
        VStack(spacing: 14) {
            
            // Info Box
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                
                Image(systemName: "info.circle.fill")
                    .foregroundColor(DesignSystem.Colors.primary)
                    .font(.system(size: 18))
                
                Text("The right side of the conversation should be from the perspective of \(Text(personAName).bold())")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .fill(DesignSystem.Colors.bgCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(DesignSystem.Colors.border)
            )
            
            // Get Judgment Button
            Button {
                guard hasSelection else { return }
                lightHaptic()
                goToProcessing = true
            } label: {
                HStack {
                    Image(systemName: "gavel.fill")
                    Text("Get Judgment")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .background(
                hasSelection ?
                LinearGradient(
                    colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                :
                LinearGradient(
                    colors: [DesignSystem.Colors.bgTertiary, DesignSystem.Colors.bgTertiary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!hasSelection)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    // MARK: Haptic
    
    func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func cardContent(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: hasSelection ? "checkmark.circle.fill" : "photo.fill")
                    .font(.system(size: 36))
                    .foregroundColor(
                        hasSelection ? .green : DesignSystem.Colors.primary
                    )
            }
            
            if hasSelection {
                Text("\(selectedItems.count) screenshot\(selectedItems.count > 1 ? "s" : "") selected")
                    .foregroundColor(.white)
                
                Button("Remove Screenshots") {
                    selectedItems.removeAll()
                }
                .foregroundColor(.red)
            } else {
                VStack(spacing: 4) {
                    Text("Tap to select screenshots")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text("PNG or JPG supported")
                        .foregroundColor(DesignSystem.Colors.textMuted)
                        .font(.caption)
                }
            }
        }
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                .fill(DesignSystem.Colors.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                .stroke(
                    hasSelection
                    ? DesignSystem.Colors.border
                    : DesignSystem.Colors.borderLight,
                    style: hasSelection
                    ? StrokeStyle(lineWidth: 1)
                    : StrokeStyle(lineWidth: 2, dash: [6,6])
                )
        )
    }
}
