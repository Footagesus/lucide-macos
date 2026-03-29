//
//  LucideIcon.swift
//  lucide-macos
//
//  Created by oftgs on 28.03.2026.
//


import SwiftUI

struct LucideIcon: Identifiable, Hashable, Equatable {
    let id: String
    var name: String
    var categories: [String]
    var tags: [String] = []
    var svgURL: URL? = nil
    var contributors: [String] = []
}
