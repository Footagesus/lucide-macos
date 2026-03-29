//
//  ContentView.swift
//  lucide-macos
//
//  Created by oftgs on 26.03.2026.
//


import SwiftUI
import SVGView


struct ContentView: View {
    @State private var viewModel = IconsViewModel()
    @State private var selection: Int? = 0
    @State private var searchQuery: String = ""

    @State private var style = IconStyleState()

    @State private var isInspectorPresented: Bool = false
    @State private var inspectorContent: LucideIcon? = nil

    @State private var mode: ViewMode = .grid
    
    @State private var isInfoPopoverClicked = false
    @State private var isCustomizePopoverClicked = false
    
    @Namespace private var segmentedNamespace

    enum ViewMode: String {
        case grid
        case list
    }
    
    

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Text("View")
                    .font(.system(size: 13, weight: .medium))
                    .opacity(0.65)
                    .padding(5)

                Text("All").tag(0).padding(.leading, 5)
                Text("Categories").tag(1).padding(.leading, 5)

                ForEach(Array(viewModel.categories.enumerated()), id: \.element.id) { index, category in
                    CategoryRow(title: category.title, icon: category.icon ?? "", count: nil, viewModel: viewModel)
                        .tag(index + 99)
                }            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 300)

        } detail: {
            Group {
                if selection == 1 {
                    allCategoriesList
                } else {
                    iconsGrid
                }
            }
            .navigationTitle(selectionTitle)
            .navigationSubtitle("\(currentIconsCount) icons")
        }
        .task {
            await viewModel.syncIcons()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: -6) {
                    ForEach([ViewMode.grid, ViewMode.list], id: \.self) { m in
                        Button {
                            withAnimation(.spring(duration: 0.2)) {
                                mode = m
                            }
                        } label: {
                            UseIcon(
                                icon: m == .grid ? "grid-2x2" : "list",
                                viewModel: viewModel,
                                size: 20,
                                color: mode == m ? Color.primary : Color.secondary
                            )
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background {
                                if mode == m {
                                    RoundedRectangle(cornerRadius: 999)
                                        .fill(Color.secondary.opacity(0.15))
                                        .matchedGeometryEffect(id: "segmented", in: segmentedNamespace)
                                }
                            }
                            .padding(4)
                        }
                        .buttonStyle(ShrinkButtonStyle())
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 999))
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    isCustomizePopoverClicked = true
                } label: {
                    UseIcon(icon: "paintbrush", viewModel: viewModel, size: 20, color: Color.primary)
                        .padding(.horizontal, 8)
                }
                .buttonStyle(ShrinkButtonStyle())
                .popover(isPresented: $isCustomizePopoverClicked) {
                    controlPanel
                }
            }
            
            ToolbarItem(placement: .navigation) {
                Button {
                    isInfoPopoverClicked = true
                } label: {
                    HStack(spacing: 6) {
                        ZStack {
                            Image("lucidepink")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.lucidelogopink)
                            Image("lucidewhite")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.lucidelogowhite)
                        }
                        Text("Lucide")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 10)
                }
                .buttonStyle(ShrinkButtonStyle())
                .popover(isPresented: $isInfoPopoverClicked) {
                    HStack(spacing: 0) {
                        
                        VStack(alignment: .leading) {
                            HStack {
                                ZStack {
                                    Image("lucidepink")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .foregroundStyle(.lucidelogopink)
                                    Image("lucidewhite")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .foregroundStyle(.lucidelogowhite)
                                }
                                
                                Text("Lucide Icons")
                                    .font(.system(size: 21, weight: .medium))
                            }
                            
                            HStack {
                                Button {
                                    if let url = URL(string: "https://lucide.dev") {
                                        NSWorkspace.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        UseIcon(icon: "link", viewModel: viewModel, size: 16, color: Color.white)
                                        Text("Website")
                                            .foregroundStyle(.white)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(.accent.opacity(0.9))
                                    .cornerRadius(999)
                                }
                                .buttonStyle(ShrinkButtonStyle())
                                
                                
                                
                                Button {
                                    if let url = URL(string: "https://github.com/lucide-icons/lucide") {
                                        NSWorkspace.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        Text("Github")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(.secondary.opacity(0.2))
                                    .cornerRadius(999)
                                }
                                .buttonStyle(ShrinkButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        
        .searchable(text: $searchQuery)
        .frame(minWidth: 800, minHeight: 500)
        .focusedValue(\.selectedIcon, inspectorContent)
    }

    
    var allCategoriesList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                let sorted = viewModel.categories

                ForEach(sorted, id: \.self) { category in
                    let icons = viewModel.icons.filter {
                        $0.categories.contains(category.title) &&
                        (searchQuery.isEmpty ||
                         $0.name.lowercased().contains(searchQuery.lowercased()) ||
                         $0.tags.contains { $0.lowercased().contains(searchQuery.lowercased()) })
                    }

                    if !icons.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(category.title)
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal)

                            if mode == .grid {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                    ForEach(Array(icons.enumerated()), id: \.element.id) { index, icon in
                                        IconTemplate(
                                            icon: icon,
                                            selection: $selection,
                                            viewModel: viewModel,
                                            style: style,
                                            isInspectorPresented: $isInspectorPresented,
                                            inspectorContent: $inspectorContent
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                LazyVStack(spacing: 0) {
                                    ForEach(Array(icons.enumerated()), id: \.element.id) { index, icon in
                                        IconRow(
                                            index: index,
                                            icon: icon,
                                            selection: $selection,
                                            viewModel: viewModel,
                                            style: style,
                                            isInspectorPresented: $isInspectorPresented,
                                            inspectorContent: $inspectorContent
                                        )
                                    }
                                }
                                .padding(12)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 30)
        }
    }

    var iconsGrid: some View {
        ScrollView {
            let filtered = viewModel.icons.filter {
                (selection == 0 || $0.categories.contains(selectionCategoryName ?? "")) &&
                (searchQuery.isEmpty ||
                 $0.name.lowercased().contains(searchQuery.lowercased()) ||
                 $0.tags.contains { $0.lowercased().contains(searchQuery.lowercased()) })
            }

            if mode == .grid {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, icon in
                        IconTemplate(
                            icon: icon,
                            selection: $selection,
                            viewModel: viewModel,
                            style: style,
                            isInspectorPresented: $isInspectorPresented,
                            inspectorContent: $inspectorContent
                        )
                    }
                }
                .padding()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, icon in
                        IconRow(
                            index: index,
                            icon: icon,
                            selection: $selection,
                            viewModel: viewModel,
                            style: style,
                            isInspectorPresented: $isInspectorPresented,
                            inspectorContent: $inspectorContent
                        )
                    }
                }
                .padding(12)
            }
        }
        
    }

    var controlPanel: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack {
                    Text("Customizer")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Button {
                        resetSettings()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    Text("Color")
                    Spacer()
                    ColorPicker("", selection: $style.color).labelsHidden()
                }

                VStack(alignment: .leading) {
                    HStack {
                        Text("Size")
                        Spacer()
                        Text("\(Int(style.size))px")
                    }
                    Slider(value: $style.size, in: 16...80)
                }

                VStack(alignment: .leading) {
                    HStack {
                        Text("Weight")
                        Spacer()
                        Text(String(format: "%.1f", style.weight))
                    }
                    Slider(value: $style.weight, in: 0.5...3)
                }

                HStack {
                    Text("Absolute weight")
                    Spacer()
                    Toggle("", isOn: $style.absoluteWeight)
                        .toggleStyle(.switch)
                }
            }
            .padding(16)
            .frame(width: 200)
        }
    }

    private func resetSettings() {
        style.color = .primary
        style.size = 24
        style.weight = 2
        style.absoluteWeight = false
    }
    
    private var selectionTitle: String {
        if selection == 0 { return "All Icons" }
        if selection == 1 { return "Categories" }
        let idx = (selection ?? 0) - 99
        let cats = viewModel.categories
        return (idx >= 0 && idx < cats.count) ? cats[idx].title : "Lucide"
    }

    private var currentIconsCount: Int {
        viewModel.icons.filter {
            (selection == 0 || $0.categories.contains(selectionCategoryName ?? "")) &&
            (searchQuery.isEmpty ||
             $0.name.lowercased().contains(searchQuery.lowercased()) ||
             $0.tags.contains { $0.lowercased().contains(searchQuery.lowercased()) })
        }.count
    }

    private var selectionCategoryName: String? {
        guard let selection, selection >= 99 else { return nil }
        let idx = selection - 99
        let cats = viewModel.categories
        return (idx >= 0 && idx < cats.count) ? cats[idx].title : nil
    }
}

#Preview {
    ContentView()
}
