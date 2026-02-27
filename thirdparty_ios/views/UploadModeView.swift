//
//  UploadModeView.swift
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct UploadModeView: View {
    
    let personAName: String
    let personBName: String
    let persona: Persona
    let onFlowComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSourceSheet = false
    @State private var showFileImporter = false
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedFileURL: URL?
    @State private var selectedFileName: String?
    
    @State private var goToProcessing = false
    @State private var uploadedMediaURL: URL?
    
    @State private var isPreparingMedia = false
    @State private var extractionProgress: Double = 0
    
    @State private var fakeProgressTask: Task<Void, Never>?
    
    private var hasSelectedFile: Bool {
        selectedFileName != nil
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
            
            VStack(spacing: 0) {
                header
                participantsRow
                content
                footerCTA
            }
        }
        .navigationBarHidden(true)
        
        .navigationDestination(isPresented: $goToProcessing) {
            if let url = uploadedMediaURL {
                ProcessingView(
                    personAName: personAName,
                    personBName: personBName,
                    persona: persona,
                    audioURL: url,
                    onFlowComplete: onFlowComplete 
                )
            }
        }
        
        .onChange(of: selectedPhotoItem) { newItem in
            guard newItem != nil else { return }
            selectedFileName = "Video selected"
            selectedFileURL = nil
            showSourceSheet = false
        }
        
        .sheet(isPresented: $showSourceSheet) {
            SourcePickerSheet(
                selectedPhotoItem: $selectedPhotoItem,
                showFileImporter: $showFileImporter
            )
            .presentationDetents([.height(240)])
            .presentationDragIndicator(.visible)
        }
        
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.audio, .movie],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result,
               let url = urls.first {
                selectedFileURL = url
                selectedFileName = url.lastPathComponent
            }
        }
    }
}

private extension UploadModeView {
    
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
                Text("UPLOAD MODE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .tracking(1.5)
                
                Text("Upload Audio")
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
    
    var content: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            
            Text("Upload an audio file or video of an argument and let AI decide who's right.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            
            uploadCard
            
            Spacer()
        }
    }
    
    var uploadCard: some View {
        Button {
            if !hasSelectedFile {
                lightHaptic()
                showSourceSheet = true
            }
        } label: {
            VStack(spacing: DesignSystem.Spacing.md) {
                
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.primary.opacity(0.15))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: hasSelectedFile ? "checkmark.circle.fill" : "waveform")
                        .font(.system(size: 40))
                        .foregroundColor(hasSelectedFile ? .green : DesignSystem.Colors.primary)
                }
                
                if let fileName = selectedFileName {
                    Text(fileName)
                        .foregroundColor(.white)
                    
                    Button("Remove File") {
                        clearSelection()
                    }
                    .foregroundColor(.red)
                } else {
                    VStack(spacing: 4) {
                        Text("Tap to select audio file")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Text("Video or audio file supported")
                            .foregroundColor(DesignSystem.Colors.textMuted)
                            .font(.caption)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                    .fill(DesignSystem.Colors.bgCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                    .stroke(
                        hasSelectedFile
                        ? DesignSystem.Colors.border
                        : DesignSystem.Colors.borderLight,
                        style: hasSelectedFile
                        ? StrokeStyle(lineWidth: 1)
                        : StrokeStyle(
                            lineWidth: 2,
                            dash: [6, 6]
                          )
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }
    
    var footerCTA: some View {
            VStack {
                Button {
                    if hasSelectedFile && !isPreparingMedia {
                        lightHaptic()
                        handleGetJudgment()
                    }
                } label: {
                    if isPreparingMedia {
                        Text("Extracting Audio (\(Int(extractionProgress * 100))%)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        HStack {
                            Image(systemName: "gavel.fill")
                            Text("Get Judgment")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                }
                .background(
                    hasSelectedFile ?
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
                .disabled(!hasSelectedFile || isPreparingMedia)
                .buttonStyle(.plain)
                .padding(DesignSystem.Spacing.screenPadding)
            }
        }
        
        // MARK: Core Logic
        
        func handleGetJudgment() {
            extractionProgress = 0
            isPreparingMedia = true
            startFakeProgress()
            
            Task {
                do {
                    var rawURL: URL?
                    var needsSecurityAccess = false
                    
                    if let fileURL = selectedFileURL {
                        rawURL = fileURL
                        needsSecurityAccess = true
                    } else if let item = selectedPhotoItem {
                        rawURL = try await createTempURL(from: item)
                    }
                    
                    guard let inputURL = rawURL else {
                        await MainActor.run { isPreparingMedia = false }
                        return
                    }
                    
                    if needsSecurityAccess {
                        guard inputURL.startAccessingSecurityScopedResource() else {
                            throw NormalizeAudioError.assetLoadFailed
                        }
                    }
                    
                    let normalizedURL = try await NormalizeAudio.process(inputURL: inputURL)
                    
                    if needsSecurityAccess {
                        inputURL.stopAccessingSecurityScopedResource()
                    }
                    
                    await MainActor.run {
                        completeProgressAndNavigate(with: normalizedURL)
                    }
                    
                } catch {
                    await MainActor.run {
                        isPreparingMedia = false
                        fakeProgressTask?.cancel()
                        print("UPLOAD ERROR:", error)
                    }
                }
            }
        }
        
        // MARK: Fake Progress Logic
        
        func startFakeProgress() {
            fakeProgressTask?.cancel()
            
            fakeProgressTask = Task {
                while !Task.isCancelled {
                    
                    if extractionProgress < 0.90 {
                        // Early stage — steady climb
                        extractionProgress += 0.004   // slower base speed
                    }
                    else if extractionProgress < 0.95 {
                        // Slow down noticeably
                        extractionProgress += 0.0015
                    }
                    else if extractionProgress < 0.98 {
                        // Crawl near the end
                        extractionProgress += 0.0005
                    }
                    
                    extractionProgress = min(extractionProgress, 0.98)
                    
                    try? await Task.sleep(nanoseconds: 40_000_000) // 0.04s tick
                }
            }
        }
        
        func completeProgressAndNavigate(with url: URL) {
            fakeProgressTask?.cancel()
            
            extractionProgress = 1.0
            
            Task {
                try? await Task.sleep(nanoseconds: 200_000_000)
                
                uploadedMediaURL = url
                isPreparingMedia = false
                goToProcessing = true
            }
        }
        
        func createTempURL(from item: PhotosPickerItem) async throws -> URL? {
            if let data = try await item.loadTransferable(type: Data.self) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mov")
                try data.write(to: tempURL)
                return tempURL
            }
            return nil
        }
        
        func clearSelection() {
            selectedPhotoItem = nil
            selectedFileURL = nil
            selectedFileName = nil
        }
        
        func lightHaptic() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

struct SourcePickerSheet: View {
    
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var showFileImporter: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                Capsule()
                    .fill(DesignSystem.Colors.border)
                    .frame(width: 40, height: 4)
                    .padding(.top, 8)
                
                Text("Select Source")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .videos
                    ) {
                        sheetButton(icon: "photo.on.rectangle", title: "Camera Roll")
                    }
                    
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showFileImporter = true
                        }
                    } label: {
                        sheetButton(icon: "folder", title: "Files")
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func sheetButton(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(DesignSystem.Colors.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(DesignSystem.Colors.border)
        )
    }
}

#Preview {
    UploadModeView(
        personAName: "Person A",
        personBName: "Person B",
        persona: .mediator,
        onFlowComplete: {}
    )
}
