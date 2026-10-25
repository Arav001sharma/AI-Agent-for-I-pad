import Foundation

public struct ResourceHelper {
    /// Safely locate a resource file across all available bundles without crashing in Swift Playgrounds
    public static func findResource(name: String, ext: String, subdirectory: String? = nil) -> URL? {
        // 1. Try Bundle.main
        if let sub = subdirectory, let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: sub) {
            return url
        }
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            return url
        }
        if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Resources") {
            return url
        }
        if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "App/Resources") {
            return url
        }
        if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Resources/Sounds") {
            return url
        }

        // 2. Try all loaded bundles
        for bundle in Bundle.allBundles {
            if let sub = subdirectory, let url = bundle.url(forResource: name, withExtension: ext, subdirectory: sub) {
                return url
            }
            if let url = bundle.url(forResource: name, withExtension: ext) {
                return url
            }
            if let url = bundle.url(forResource: name, withExtension: ext, subdirectory: "Resources") {
                return url
            }
            if let url = bundle.url(forResource: name, withExtension: ext, subdirectory: "App/Resources") {
                return url
            }
        }

        // 3. Fallback direct file path check
        let possiblePaths = [
            "App/Resources/\(name).\(ext)",
            "Resources/\(name).\(ext)",
            "App/Resources/Sounds/\(name).\(ext)",
            "Resources/Sounds/\(name).\(ext)"
        ]
        for rel in possiblePaths {
            let full = Bundle.main.bundleURL.appendingPathComponent(rel)
            if FileManager.default.fileExists(atPath: full.path) {
                return full
            }
        }

        return nil
    }
}
