//
//  DesignSystem.swift
//  thirdparty_ios
//
//  Created by Caleb Chiang on 2026-02-23.
//

import SwiftUI

enum DesignSystem {
    
    enum Colors {
        static let bgDeep = Color(hex: "#050508")
        static let bgPrimary = Color(hex: "#0A0A0F")
        static let bgSecondary = Color(hex: "#12121A")
        static let bgTertiary = Color(hex: "#1A1A26")
        static let bgCard = Color(hex: "#1E1E2D")
        static let bgElevated = Color(hex: "#262638")

        static let primary = Color(hex: "#34D399")
        static let primaryLight = Color(hex: "#6EE7B7")
        static let primaryDark = Color(hex: "#10B981")
        static let primaryGlow = Color(hex: "#34D399").opacity(0.2)

        static let secondary = Color(hex: "#FF2E97")
        static let secondaryDark = Color(hex: "#CC2579")

        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "#B4B4C7")
        static let textMuted = Color(hex: "#6E6E85")
        static let textInverse = Color(hex: "#0A0A0F")

        static let border = Color.white.opacity(0.08)
        static let borderLight = Color.white.opacity(0.15)
        static let divider = Color.white.opacity(0.06)

        static let error = Color(hex: "#FF4757")
    }

    // MARK: - TYPOGRAPHY
    
    enum Typography {
        static let hero = Font.system(size: 56, weight: .black)
        static let h1 = Font.system(size: 36, weight: .heavy)
        static let h2 = Font.system(size: 28, weight: .bold)
        static let h3 = Font.system(size: 22, weight: .bold)
        static let body = Font.system(size: 16, weight: .medium)
        static let bodyMedium = Font.system(size: 16, weight: .semibold)
        static let caption = Font.system(size: 13, weight: .semibold)
        static let button = Font.system(size: 16, weight: .bold)
    }

    // MARK: - SPACING
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48

        static let screenPadding: CGFloat = 20
        static let cardPadding: CGFloat = 20
    }

    // MARK: - BORDER RADIUS
    
    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 18
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let button: CGFloat = 16
        static let input: CGFloat = 14
    }

    // MARK: - SHADOWS
    
    enum Shadows {
        static func lg() -> some ViewModifier {
            ShadowModifier(
                color: .black,
                radius: 20,
                x: 0,
                y: 10,
                opacity: 0.3
            )
        }

        static func glowGreen() -> some ViewModifier {
            ShadowModifier(
                color: Colors.primary,
                radius: 16,
                x: 0,
                y: 0,
                opacity: 0.4
            )
        }

        static func glowPink() -> some ViewModifier {
            ShadowModifier(
                color: Colors.secondary,
                radius: 20,
                x: 0,
                y: 0,
                opacity: 0.5
            )
        }
    }

    // MARK: - Animation
    
    enum Animation {
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let normal = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let dramatic = SwiftUI.Animation.easeInOut(duration: 0.6)

        static let pressedScale: CGFloat = 0.95
    }
}

// MARK: - Shadow Modifier

struct ShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(opacity),
                    radius: radius,
                    x: x,
                    y: y)
    }
}
