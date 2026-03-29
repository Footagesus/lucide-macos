//
//  SVGUtils.swift
//  lucide-macos
//
//  Created by oftgs on 27.03.2026.
//

import AppKit


enum SVGUtils {
    static func prepareSVG(icon: LucideIcon, size: CGFloat, weight: CGFloat, absoluteWeight: Bool) -> String {
        guard let url = icon.svgURL,
              var svgString = try? String(contentsOf: url) else {
            return ""
        }
        
        let scale = size / 24.0
        let finalWeight = absoluteWeight ? weight / scale : weight
        let weightString = String(format: "%.2f", finalWeight)
        
        return svgString.replacingOccurrences(
            of: "stroke-width=\"2\"",
            with: "stroke-width=\"\(weightString)\""
        )
    }
}
