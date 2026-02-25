//
//  Persona.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-24.
//

import Foundation

enum Persona: String, CaseIterable, Hashable {
    case mediator
    case judgeJudy
    case comedian

    var backendValue: String {
        switch self {
        case .mediator:
            return "mediator"
        case .judgeJudy:
            return "judge"
        case .comedian:
            return "comedic"
        }
    }

    var title: String {
        switch self {
        case .mediator: return "The Mediator"
        case .judgeJudy: return "Judge Judy"
        case .comedian: return "The Comedian"
        }
    }

    var description: String {
        switch self {
        case .mediator:
            return "Fair, diplomatic, and balanced."
        case .judgeJudy:
            return "Direct, no-nonsense, brutally honest."
        case .comedian:
            return "Witty and humorous but still decisive."
        }
    }

    var icon: String {
        switch self {
        case .mediator: return "face.smiling"
        case .judgeJudy: return "bolt.shield.fill"
        case .comedian: return "theatermasks.fill"
        }
    }
}
