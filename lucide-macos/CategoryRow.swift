//
//  CategoryRow.swift
//  lucide-macos
//
//  Created by oftgs on 26.03.2026.
//

import SwiftUI

struct CategoryRow: View {
    let title: String
    let icon: String
    let count: Int?
    let viewModel: IconsViewModel
    
    var body: some View {
        HStack {
            UseIcon(icon: icon, viewModel: viewModel, size: 16, color: Color.gray)
            Text(title)
            if let count = count {
                Spacer()
                Text("\(count)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.leading, 20)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.gray.opacity(0.35))
                .frame(width: 1, height: 32)
                .padding(.leading, 8)
        }
    }
}

#Preview {
    ContentView()
}
