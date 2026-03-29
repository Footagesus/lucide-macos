//
//  Button.swift
//  lucide-macos
//
//  Created by oftgs on 28.03.2026.
//

import SwiftUI

struct ButtonForIcon: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let secondaryAction: (() -> Void)?
    let secondaryIcon: String?
    
    let color: Color
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Text(title)
                    
                }
                .padding(.vertical, 9)
                .padding(.leading, 14)
                .padding(.trailing, secondaryAction != nil ? 9 : 14)
                .frame(maxHeight: .infinity)
                .background(color)
                .cornerRadius(secondaryAction != nil ? 0 : 999)
                .clipShape(
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 999, bottomLeading: 999))
                )
            }
            .buttonStyle(ShrinkButtonStyle())
            
            if let secondaryAction {
                Button(action: secondaryAction) {
                    HStack {
                        if let secondaryIcon {
                            Image(systemName: secondaryIcon)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 12.7)
                    .padding(.horizontal, 9)
                    .frame(maxHeight: .infinity)
                    .background(color)
                    .cornerRadius(0)
                    .clipShape(
                        UnevenRoundedRectangle(cornerRadii: .init(bottomTrailing: 999, topTrailing: 999))
                    )
                }
                .buttonStyle(ShrinkButtonStyle())
            }
        }
    }
}
