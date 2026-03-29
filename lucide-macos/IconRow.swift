//
//  IconRow.swift
//  lucide-macos
//
//  Created by oftgs on 28.03.2026.
//


import SwiftUI
import SVGView

struct IconRow: View {
    let index: Int
    let icon: LucideIcon
    @Binding var selection: Int?
    let viewModel: IconsViewModel
    
    var style: IconStyleState
    
    @Binding var isInspectorPresented: Bool
    @Binding var inspectorContent: LucideIcon?
    
    @State private var isClicked = false
    
    
    var body: some View {
        Button {
            isClicked = true
        } label: {
            HStack {
                let svgCode = SVGUtils.prepareSVG(icon: icon, size: style.size, weight: style.weight, absoluteWeight: style.absoluteWeight)
                if !svgCode.isEmpty {
                    Rectangle()
                        .fill(style.color)
                        .frame(width: style.size, height: style.size)
                        .mask {
                            SVGView(string: svgCode)
                                .frame(width: style.size, height: style.size)
                        }
                } else {
                    Color.clear.frame(width: style.size, height: style.size)
                }
                
                Text(icon.name)
                    .font(.system(size: 14, weight: .regular))
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                //            HStack(spacing: -6) {
                //
                //                ForEach(icon.contributors, id: \.self) { url in
                //                    AsyncImage(url: URL(string: url + "&s=32")) { image in
                //                        image.resizable()
                //                    } placeholder: {
                //                        Circle().fill(.gray.opacity(0.2))
                //                    }
                //                    .frame(width: 22, height: 22)
                //                    .clipShape(Circle())
                //                    .overlay(Circle().stroke(.white.opacity(0.1), lineWidth: 1))
                //                }
                //            }
                //            .onTapGesture {
                //                print(icon.contributors)
                //            }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isClicked ? .accent.opacity(0.9) : Color.clear)
            .background(index % 2 == 0 ? Color.secondary.opacity(0.1) : Color.clear)
            .cornerRadius(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(ShrinkButtonStyle())
        .frame(maxWidth: .infinity)
        
        .popover(isPresented: $isClicked) {
            Popover(icon: icon, style: style, viewModel: viewModel, selection: $selection)
        }
        
        
    }
}

#Preview {
    ContentView()
}
