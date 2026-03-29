//
//  lucide_macosApp.swift
//  lucide-macos
//
//  Created by oftgs on 26.03.2026.
//

import SwiftUI


extension FocusedValues {
    @Entry var selectedIcon: LucideIcon? = nil
}


@main
struct lucide_macosApp: App {
    @FocusedValue(\.selectedIcon) var selectedIcon
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 650, height: 750)
        .commands {
            CommandGroup(replacing: .pasteboard) {
                Button("Copy") {
                    guard let icon = selectedIcon else { return }
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(icon.name, forType: .string)
                }
                .keyboardShortcut("c", modifiers: .command)
            }
        }
    }
}

#Preview {
    ContentView()
}
