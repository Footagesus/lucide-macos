//
//  UseIcon.swift
//  lucide-macos
//
//  Created by oftgs on 28.03.2026.
//

import SwiftUI
import SVGView

struct UseIcon: View {
    let icon: String
    let viewModel: IconsViewModel
    var size: CGFloat = 20
    var color: Color = Color.primary

    var body: some View {
        if let url = viewModel.icons.first(where: { $0.id == icon })?.svgURL,
           let data = try? Data(contentsOf: url),
           let svg = String(data: data, encoding: .utf8) {
            Rectangle()
                .fill(color)
                .frame(width: size, height: size)
                .mask {
                    SVGView(string: svg)
                        .frame(width: size, height: size)
                }
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(width: size, height: size)
        }
    }
}
