//
//  IconStyle.swift
//  lucide-macos
//
//  Created by oftgs on 27.03.2026.
//


import SwiftUI

@Observable
final class IconStyle {
    var color: Color   = .primary
    var size: CGFloat  = 32
    var weight: CGFloat = 2
    var absolute: Bool = false

    var effectiveStroke: CGFloat {
        absolute ? weight : weight  
    }
}

extension EnvironmentValues {
    @Entry var iconStyle: IconStyle = IconStyle()
}
