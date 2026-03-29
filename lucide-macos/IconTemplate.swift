//
//  IconTemplate.swift
//  lucide-macos
//
//  Created by oftgs on 26.03.2026.
//


import SwiftUI
import SVGView
import AppKit

struct IconTemplate: View {
    let icon: LucideIcon
    @Binding var selection: Int?
    let viewModel: IconsViewModel
    
    var style: IconStyleState
    
    @Binding var isInspectorPresented: Bool
    @Binding var inspectorContent: LucideIcon?


    @State private var isHovered = false
    @State private var isClicked = false
    
    
    
    
    
    var body: some View {
        HStack {
            Button {
                isInspectorPresented = true
                inspectorContent = icon
                isClicked = true
            } label: {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        let svgCode = SVGUtils.prepareSVG(icon: icon, size: style.size, weight: style.weight, absoluteWeight: style.absoluteWeight)
                        if !svgCode.isEmpty {
                            Rectangle()
                                .fill(style.color)
                                .frame(width: style.size + 12, height: style.size + 12)
                                .mask {
                                    SVGView(string: svgCode)
                                        .frame(width: style.size + 12, height: style.size + 12)
                                }
                        } else {
                            Color.clear.frame(width: style.size, height: style.size)
                        }
                        
                    }
                    .frame(height: isHovered ? 55 : 80)
                    .animation(.easeInOut(duration: 0.1), value: isHovered)
                    .frame(maxWidth: .infinity)
                    .background(.secondary.opacity(0.1))
                    
                    
                    
                    HStack {
                        
                        Text(icon.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(isHovered ? .white : .clear)
                            .minimumScaleFactor(0.5)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 6)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: isHovered ? 25 : 0)
                    .background(.accent)
                    //.offset(y: isHovered ? 0 : 20)
                    .animation(.easeInOut(duration: 0.1), value: isHovered)
                    
                }
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 12)
                    .stroke(.accent, lineWidth: isClicked ? 5 : 0))
                .animation(.easeInOut(duration: 0.1), value: isClicked)
                    
                .animation(.easeInOut(duration: 0.1), value: isHovered)
                .cornerRadius(12)
                
                
                .onHover { hovering in
                    isHovered = hovering
                }
                
                .popover(isPresented: $isClicked) {
                    Popover(icon: icon, style: style, viewModel: viewModel, selection: $selection)
                }
            }
            .buttonStyle(ShrinkButtonStyle())
        }
        .cornerRadius(12)
        
        .contextMenu {
            Button {
                if let url = icon.svgURL,
                   let data = try? Data(contentsOf: url),
                   let svg = String(data: data, encoding: .utf8) {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(svg, forType: .string)
                }
            } label: {
                Label("Copy SVG", systemImage: "doc.on.doc")
            }
            

            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(icon.name, forType: .string)
            } label: {
                Label("Copy Name", systemImage: "textformat")
            }
            .keyboardShortcut("c", modifiers: .command)

            Button {
                if let url = icon.svgURL {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url.path, forType: .string)
                }
            } label: {
                Label("Copy Path", systemImage: "link")
            }
            
            Button {
                IconExporter.downloadSVG(icon: icon, settings: DownloadSettings.shared)
            } label: {
                Label("Download SVG", systemImage: "arrow.down.circle")
            }
             
            Button {
                IconExporter.downloadPNG(icon: icon, settings: DownloadSettings.shared)
            } label: {
                Label("Download PNG", systemImage: "photo")
            }
             
        }
    }
}

struct CategoryItem: View {
    let category: String
    @Binding var selection: Int?
    let viewModel: IconsViewModel
    
    @State private var isHovered = false
    @State private var isClicked = false

    var body: some View {
        Button {
            let categories: Array = viewModel.categories
            if let index: Int = categories.firstIndex(where: { $0.title == category }) {
                selection = 99 + index
            }
        } label: {
            Text(category)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.secondary.opacity(isHovered ? 0.45 : 0.15))
                .cornerRadius(99)
                .onHover { hovered in
                    isHovered = hovered
                }
                .animation(.easeInOut(duration: 0.05), value: isHovered)
        }
        .buttonStyle(ShrinkButtonStyle())
        
    }
}

extension Color {
    func toHex() -> String? {
        let nsColor = NSColor(self)
        
        guard let rgbColor = nsColor.usingColorSpace(.sRGB) else { return nil }
        
        let r = Float(rgbColor.redComponent)
        let g = Float(rgbColor.greenComponent)
        let b = Float(rgbColor.blueComponent)
        
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }
}

#Preview {
    ContentView()
}
