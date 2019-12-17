//
//  LocalConfiguration.swift
//  App
//
//  Created by yenz0redd on 17.12.2019.
//

import Foundation

struct ConfigParams {
    let numberOfWorkers: Int
    let dumpPeriod: Int
    let workerPeriod: Int
}

protocol Configurations {
    var configturations: ConfigParams { get }
}

final class LocalConfigurations: Configurations {
    static let shared = LocalConfigurations()

    private init() { }

    var configturations: ConfigParams {
        return self.configFromFile()
    }

    private var localConfigDict: ConfigParams {
        return ConfigParams(numberOfWorkers: 5, dumpPeriod: 100, workerPeriod: 5)
    }

    private func configFromFile() -> ConfigParams {
        guard let dict = FileManager.shared.configDict else { return self.localConfigDict }
        guard let strWorkersCount = dict["numberOfWorkers"], let workerCount = Int(strWorkersCount) else { return self.localConfigDict }
        guard let strDumpPeriod = dict["dumpPeriod"], let dumpPeriod = Int(strDumpPeriod) else { return self.localConfigDict }
        guard let strWorkerPeriod = dict["workerPeriod"], let workerPeriod = Int(strWorkerPeriod) else { return self.localConfigDict }
        return ConfigParams(numberOfWorkers: workerCount, dumpPeriod: dumpPeriod, workerPeriod: workerPeriod)
    }
}
