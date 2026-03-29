//
//  IconStyleState.swift
//  lucide-macos
//
//  Created by oftgs on 28.03.2026.
//


import SwiftUI
import Observation

@Observable
final class IconStyleState {
    var color: Color = .primary
    var size: CGFloat = 24
    var weight: CGFloat = 2
    var absoluteWeight: Bool = false
}