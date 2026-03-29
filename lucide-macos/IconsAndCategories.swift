//
//  IconsAndCategories.swift
//  lucide-macos
//
//  Created by oftgs on 26.03.2026.
//


import SwiftUI
import Observation
import ZIPFoundation


@Observable
final class IconsViewModel {

    var categories: [LucideCategory] = []
    var icons: [LucideIcon] = []

    var searchQuery: String = "" {
        didSet { applyFilters() }
    }

    var selectionCategory: String? = nil {
        didSet { applyFilters() }
    }

    var filteredIcons: [LucideIcon] = []

    private var categoryKeysToTitle: [String: String] = [:]
    private var contributorsCache: [String: [String]] = [:]

    private let zipURL = URL(string: "https://github.com/lucide-icons/lucide/archive/refs/heads/main.zip")!

    private var rootCacheDir: URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("Lucide Icons/cache", isDirectory: true)
    }

    private var svgCacheDir: URL {
        rootCacheDir.appendingPathComponent("svg", isDirectory: true)
    }

    private var localZipURL: URL {
        rootCacheDir.appendingPathComponent("lucide.zip")
    }

    private func ensureDirectories() {
        let fm = FileManager.default
        try? fm.createDirectory(at: svgCacheDir, withIntermediateDirectories: true)
    }

    func syncIcons() async {
        ensureDirectories()

        if FileManager.default.fileExists(atPath: localZipURL.path) {
            try? await parseZip(at: localZipURL)
        }

        do {
            var request = URLRequest(url: zipURL)

            if let etag = UserDefaults.standard.string(forKey: "zip_etag") {
                request.setValue(etag, forHTTPHeaderField: "If-None-Match")
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return }

            if http.statusCode == 304 { return }

            if http.statusCode == 200 {
                if let newETag = http.allHeaderFields["ETag"] as? String {
                    UserDefaults.standard.set(newETag, forKey: "zip_etag")
                }
                try data.write(to: localZipURL)
                try await parseZip(at: localZipURL)
            }
        } catch {
            print("Sync error:", error)
        }
    }

    func searchIcons(query: String) -> [LucideIcon] {
        guard !query.isEmpty else { return icons }
        let q = query.lowercased()
        return icons.filter {
            $0.name.lowercased().contains(q) ||
            $0.tags.contains(where: { $0.lowercased().contains(q) })
        }
    }

    func loadContributors(for icon: String) async -> [String] {
        if let cached = contributorsCache[icon] { return cached }

        guard let url = URL(string: "https://api.github.com/repos/lucide-icons/lucide/contributors") else {
            return []
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                let avatars = json.compactMap { $0["avatar_url"] as? String }
                let limited = Array(avatars.prefix(5))
                contributorsCache[icon] = limited
                return limited
            }
        } catch {
            print("Contributors error:", error)
        }
        return []
    }

    private func parseZip(at url: URL) async throws {
        guard let archive = Archive(url: url, accessMode: .read) else { return }

        var parsedCategories: [String: LucideCategory] = [:]
        var iconJsons: [(name: String, categories: [String], tags: [String], svgPath: String?)] = []

        for entry in archive where entry.path.contains("categories/") && entry.path.hasSuffix(".json") {
            var data = Data()
            _ = try archive.extract(entry) { data.append($0) }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let title = json["title"] as? String {
                let key = URL(fileURLWithPath: entry.path).deletingPathExtension().lastPathComponent
                let icon = json["icon"] as? String
                categoryKeysToTitle[key] = title
                parsedCategories[key] = LucideCategory(id: key, title: title, icon: icon)
            }
        }

        for entry in archive where entry.path.contains("icons/") && entry.path.hasSuffix(".json") {
            var data = Data()
            _ = try archive.extract(entry) { data.append($0) }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let catKeys = json["categories"] as? [String] {

                let name = URL(fileURLWithPath: entry.path)
                    .deletingPathExtension()
                    .lastPathComponent

                let tags = json["tags"] as? [String] ?? []
                let svgPath = entry.path.replacingOccurrences(of: ".json", with: ".svg")
                let mappedTitles = catKeys.compactMap { categoryKeysToTitle[$0] }

                iconJsons.append((name: name, categories: mappedTitles, tags: tags, svgPath: svgPath))
            }
        }

        var finalIcons: [LucideIcon] = []
        for iconData in iconJsons {
            let iconCacheURL = svgCacheDir.appendingPathComponent("\(iconData.name).svg")

            if let svgPath = iconData.svgPath,
               !FileManager.default.fileExists(atPath: iconCacheURL.path),
               let svgEntry = archive[svgPath] {
                try archive.extract(svgEntry, to: iconCacheURL)
            }

            finalIcons.append(LucideIcon(
                id: iconData.name,
                name: iconData.name,
                categories: iconData.categories,
                tags: iconData.tags,
                svgURL: iconCacheURL
            ))
        }

        let finalCategories = parsedCategories.values.sorted { $0.title < $1.title }

        await MainActor.run {
            self.icons = finalIcons.sorted { $0.name < $1.name }
            self.categories = finalCategories
            applyFilters()
        }
    }

    private func applyFilters() {
        let query = searchQuery.lowercased()
        filteredIcons = icons.filter { icon in
            let matchCategory = selectionCategory == nil || icon.categories.contains(selectionCategory!)
            let matchSearch = query.isEmpty ||
                icon.name.lowercased().contains(query) ||
                icon.tags.contains { $0.lowercased().contains(query) }
            return matchCategory && matchSearch
        }
    }
}
