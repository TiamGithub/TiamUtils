import Foundation

extension Bundle {
    /// Decodes a JSON file present in this Bundle
    /// - Parameters:
    ///   - type: the Decodable metatype
    ///   - filename: the name of the file without the ".json" extension
    func decode<T: Decodable>(_ type: T.Type, filename: String) -> T {
        guard let url = self.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to locate \(filename) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(filename) from bundle.")
        }

        let decoder = JSONDecoder()

        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(filename) from bundle.")
        }

        return loaded
    }

    /// Semantic version number
    var marketingVersion: String? {
        self.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    /// Integer or floating point number
    var buildVersion: String? {
        self.infoDictionary?["CFBundleVersion"] as? String
    }
}
