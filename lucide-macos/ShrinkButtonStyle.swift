//
//  ShrinkButtonStyle.swift
//  lucide-macos
//
//  Created by oftgs on 27.03.2026.
//

import SwiftUI

struct ShrinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}
