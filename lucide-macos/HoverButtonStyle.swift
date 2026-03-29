//
//  HoverButtonStyle.swift
//  lucide-macos
//
//  Created by oftgs on 28.03.2026.
//

import SwiftUI

struct HoverButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 999)
                    .fill(isHovered ? Color.secondary.opacity(0.15) : Color.clear)
            )
            .onHover { isHovered = $0 }
    }
}
