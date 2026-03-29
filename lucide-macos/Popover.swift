//
//  Popover.swift
//  lucide-macos
//
//  Created by oftgs on 28.03.2026.
//


import SwiftUI
import SVGView

struct Popover: View {
    let icon: LucideIcon
    let style: IconStyleState
    let viewModel: IconsViewModel
    
    @Binding var selection: Int?
    
    @State private var isHoveredTitle = false
    @State private var isClickedTitle = false
    @State private var isCopied = false
    
    @State private var isDropdownPresented = false
    @State private var isPNGSettingsPresented = false
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ZStack {
                    GeometryReader { geometry in
                        Path { path in
                            let w = geometry.size.width
                            let h = geometry.size.height
                            
                            let count = Int(max(style.size, 1))
                            
                            for i in 0...count {
                                let fraction = CGFloat(i) / CGFloat(count)
                                
                                let x = fraction * w
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: h))
                                
                                let y = fraction * h
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: w, y: y))
                            }
                        }
                        .stroke(.iconGridStroke, lineWidth: 0.5)
                    }
                    .frame(width: 160, height: 160)
                    
                    let svgCode = SVGUtils.prepareSVG(icon: icon, size: style.size, weight: style.weight, absoluteWeight: style.absoluteWeight)
                    if !svgCode.isEmpty {
                        Rectangle()
                            .fill(style.color.opacity(0.85))
                            .frame(width: 160, height: 160)
                            .mask {
                                SVGView(string: svgCode)
                                    .frame(width: 160, height: 160)
                            }
                    } else {
                        Color.clear.frame(width: style.size, height: style.size)
                    }
                    
                }
                .background(.iconBackground)
                .cornerRadius(12)
                .background(RoundedRectangle(cornerRadius: 12)
                    .stroke(.iconGridStroke, lineWidth: 0.5))
                .padding(.top, 8)
                .padding(.bottom, 8)
                .padding(.leading, 8)
                
                VStack {
                    HStack {
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(icon.name, forType: .string)
                            
                            isCopied = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isCopied = false
                            }
                        } label: {
                            HStack {
                                Text(icon.name)
                                    .font(.largeTitle)
                                    .frame(alignment: .leading)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                
                                Image(systemName: isCopied ? "checkmark" : "square.on.square")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 10)
                                    .opacity(isHoveredTitle ? 0.6 : 0)
                            }
                            .background(isHoveredTitle ? .black.opacity(0.4) : .clear)
                            .cornerRadius(12)
                            .padding(.leading, 8)
                            .padding(.top, 8)
                            .onHover { hovering in
                                isHoveredTitle = hovering
                            }
                            .animation(.easeInOut(duration: 0.1), value: isHoveredTitle)
                        }
                        .buttonStyle(ShrinkButtonStyle())
                        
                        Spacer()
                    }
                    
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(icon.tags, id: \.self) { tag in
                                Text(tag)
                                    .opacity(0.75)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black, location: 0.05),
                                .init(color: .black, location: 0.95),
                                .init(color: .clear, location: 1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.bottom, 6)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(icon.categories, id: \.self) { category in
                                CategoryItem(category: category, selection: $selection, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black, location: 0.05),
                                .init(color: .black, location: 0.95),
                                .init(color: .clear, location: 1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    
                    HStack {
                        ButtonForIcon(
                            title: "Copy SVG",
                            icon: nil,
                            action: {
                                if let url = icon.svgURL,
                                   let data = try? Data(contentsOf: url),
                                   let svg = String(data: data, encoding: .utf8) {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(svg, forType: .string)
                                }
                            },
                            secondaryAction: {
                                isDropdownPresented = true
                            },
                            secondaryIcon: "chevron.down",
                            color: .accent
                        )
                        .popover(isPresented: $isDropdownPresented) {
                            VStack(alignment: .leading, spacing: 0) {
                                Button {
                                    if let url = icon.svgURL,
                                       let data = try? Data(contentsOf: url),
                                       let svg = String(data: data, encoding: .utf8) {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(svg, forType: .string)
                                    }
                                    isDropdownPresented = false
                                } label: { Label("Copy SVG", systemImage: "doc.on.doc") }
                                    .buttonStyle(HoverButtonStyle())

                                Button {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(icon.name, forType: .string)
                                    isDropdownPresented = false
                                } label: { Label("Copy Name", systemImage: "textformat") }
                                    .buttonStyle(HoverButtonStyle())

                                Button {
                                    IconExporter.downloadSVG(icon: icon, settings: DownloadSettings.shared)
                                    isDropdownPresented = false
                                } label: { Label("Download SVG", systemImage: "arrow.down.circle") }
                                    .buttonStyle(HoverButtonStyle())


                                Button {
                                    isPNGSettingsPresented = true
                                } label: {
                                    HStack {
                                        Label("Download PNG", systemImage: "photo")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                        
                                    }
                                }
                                .buttonStyle(HoverButtonStyle())
                                .popover(isPresented: $isPNGSettingsPresented) {
                                    VStack(spacing: 16) {
                                        VStack(spacing: 10) {
                                            HStack {
                                                Text("Size")
                                                Spacer()
                                                Text("\(Int(DownloadSettings.shared.size))px")
                                                    .foregroundStyle(.secondary)
                                                    .font(.system(size: 12))
                                            }
                                            Slider(value: Bindable(DownloadSettings.shared).size, in: 64...1024, step: 64)

                                            HStack {
                                                Text("Weight")
                                                Spacer()
                                                Text(String(format: "%.1f", DownloadSettings.shared.weight))
                                                    .foregroundStyle(.secondary)
                                                    .font(.system(size: 12))
                                            }
                                            Slider(value: Bindable(DownloadSettings.shared).weight, in: 0.5...3)

                                            HStack {
                                                Text("Color")
                                                Spacer()
                                                ColorPicker("", selection: Bindable(DownloadSettings.shared).color)
                                                    .labelsHidden()
                                            }

                                            HStack {
                                                Text("Absolute weight")
                                                Spacer()
                                                Toggle("", isOn: Bindable(DownloadSettings.shared).absoluteWeight)
                                                    .labelsHidden()
                                                    .toggleStyle(.switch)
                                            }
                                        }
                                        .font(.system(size: 13))

                                        Divider()

                                        HStack {
                                            Button("Reset") {
                                                DownloadSettings.shared.reset()
                                            }
                                            .buttonStyle(.plain)
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 14))

                                            Spacer()

                                            Button {
                                                IconExporter.downloadPNG(icon: icon, settings: DownloadSettings.shared)
                                                isPNGSettingsPresented = false
                                                isDropdownPresented = false
                                            } label: {
                                                Text("Download")
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(.accent)
                                                    .cornerRadius(999)
                                            }
                                            .buttonStyle(ShrinkButtonStyle())
                                        }
                                    }
                                    .padding(16)
                                    .frame(width: 260)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(6)
                        }
                     
                        ButtonForIcon(
                            title: "Website",
                            icon: "link",
                            action: {
                                if let url = URL(string: "https://lucide.dev/icons/\(icon.name)") {
                                    NSWorkspace.shared.open(url)
                                }
                            },
                            secondaryAction: nil,
                            secondaryIcon: nil,
                            color: .secondary.opacity(0.2)
                        )
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
                    .frame(height: 44)
                }
                
                Spacer()
            }
        }
        
        .frame(width: 560)
    }
}
