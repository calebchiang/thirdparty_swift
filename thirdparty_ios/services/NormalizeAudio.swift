//
//  NormalizeAudio.swift
//

import Foundation
import AVFoundation

enum NormalizeAudioError: Error {
    case assetLoadFailed
    case exportFailed
}

struct NormalizeAudio {
    
    static func process(inputURL: URL) async throws -> URL {
        
        let asset = AVURLAsset(url: inputURL)
        let duration = try await asset.load(.duration)
        
        guard duration.seconds > 0 else {
            throw NormalizeAudioError.assetLoadFailed
        }
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")
        
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetAppleM4A
        ) else {
            throw NormalizeAudioError.exportFailed
        }
        
        do {
            try await exportSession.export(to: outputURL, as: .m4a)
            return outputURL
        } catch {
            throw NormalizeAudioError.exportFailed
        }
    }
}
