//
//  Model.swift
//  client
//
//  Created by yenz0redd on 15.12.2019.
//  Copyright © 2019 yenz0redd. All rights reserved.
//

import Foundation

protocol Model {
    func getNames(completion: @escaping ([String]) -> Void)
}

final class ModelImpl: Model {
    func getNames(completion: @escaping ([String]) -> Void) {
        NetworkManagerImpl.shared.getQueues(completion: completion)
    }
}
