//
//  Color+hex.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-23.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xff) / 255
        let g = Double((int >> 8) & 0xff) / 255
        let b = Double(int & 0xff) / 255

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
