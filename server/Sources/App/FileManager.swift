//
//  FileManager.swift
//  App
//
//  Created by yenz0redd on 16.12.2019.
//

import Foundation

/// For configuration from file
final class FileManager {
    static let shared = FileManager()

    private init() { }

    var configDict: [String: String]? {
        return self.parseConfigFile()
    }

    private let configPath: String? = {
        return Bundle.main.path(forResource: "config", ofType: "txt")
    }()

    private func getFileContent() -> [String]? {
        guard let path = self.configPath else { return nil }
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let lines = data.components(separatedBy: .newlines)
            return lines
        } catch {
            return []
        }
    }

    private func parseConfigFile() -> [String: String]? {
        guard let lines = self.getFileContent() else { return nil }
        var result: [String: String] = [:]
        for line in lines {
            let keyValue = line.components(separatedBy: "~")
            result[keyValue[0]] = keyValue[1]
        }
        return result
    }
}
