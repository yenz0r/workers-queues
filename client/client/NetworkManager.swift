//
//  NetworkManager.swift
//  client
//
//  Created by yenz0redd on 15.12.2019.
//  Copyright © 2019 yenz0redd. All rights reserved.
//

import Foundation

protocol NetworkManager {
    func sendMessage(with text: String, username: String, queueName: String, completion: @escaping (Bool) -> Void)
    func getQueues(completion: @escaping ([String]) -> Void)
}

final class NetworkManagerImpl: NetworkManager {
    static let shared = NetworkManagerImpl()

    private let urlSession = URLSession.shared

    private init() { }

    func getQueues(completion: @escaping ([String]) -> Void) {
        let url = URL(string: "http://localhost:8080/get-queues-names")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        self.urlSession.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            guard let dict = try? JSONDecoder().decode([String: [String]].self, from: data) else {
                 return
            }
            guard let names = dict["names"] else { return }
            DispatchQueue.main.async {
                completion(names)
            }
        }.resume()
    }

    func sendMessage(with text: String,
                     username: String,
                     queueName: String,
                     completion: @escaping (Bool) -> Void) {
        let url = URL(string: "http://localhost:8080/send-message")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"

        let parameters: [String: Any] = [
            "message": text,
            "username": username,
            "queueName": queueName
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

        self.urlSession.dataTask(with: request) { _, response, error in
            guard let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                completion(true)
            }
        }.resume()
    }
}
