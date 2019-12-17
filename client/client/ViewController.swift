//
//  ViewController.swift
//  client
//
//  Created by yenz0redd on 15.12.2019.
//  Copyright © 2019 yenz0redd. All rights reserved.
//

import UIKit
import SnapKit

final class ViewController: UIViewController {
    private var messageTextField: UITextField!
    private var usernameTextField: UITextField!
    private var queuesTableView: UITableView!
    private var queueLabel: UILabel!
    private var sendButton: UIButton!
    private var titleLabel: UILabel!

    private let model: Model = ModelImpl()
    private var queuesNames = [String]()

    override func loadView() {
        self.view = UIView()

        self.titleLabel = UILabel()
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(self.view.safeAreaLayoutGuide)
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(100.0)
        }

        self.queuesTableView = UITableView()
        self.view.addSubview(self.queuesTableView)
        self.queuesTableView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(5)
            make.centerY.equalTo(self.view.safeAreaLayoutGuide)
            make.width.height.equalToSuperview().dividedBy(2)
        }

        self.queueLabel = UILabel()
        self.view.addSubview(self.queueLabel)
        self.queueLabel.snp.makeConstraints { make in
            make.leading.width.equalTo(self.queuesTableView)
            make.top.equalTo(self.queuesTableView.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(40.0)
        }

        self.usernameTextField = UITextField()
        self.view.addSubview(self.usernameTextField)
        self.view.addSubview(self.usernameTextField)
        self.usernameTextField.snp.makeConstraints { make in
            make.leading.equalTo(self.queuesTableView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalToSuperview().dividedBy(3)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(1)
        }
        self.usernameTextField.backgroundColor = .white

        self.messageTextField = UITextField()
        self.view.addSubview(self.messageTextField)
        self.messageTextField.snp.makeConstraints { make in
            make.centerX.width.equalTo(self.usernameTextField)
            make.height.equalToSuperview().dividedBy(3)
            make.top.equalTo(self.usernameTextField.snp.bottom).offset(1)
        }
        self.messageTextField.backgroundColor = .white

        self.sendButton = UIButton(type: .system)
        self.view.addSubview(self.sendButton)
        self.sendButton.snp.makeConstraints { make in
            make.centerX.width.equalTo(self.messageTextField)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.messageTextField.snp.bottom).offset(1)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black

        self.messageTextField.textAlignment = .center
        self.messageTextField.placeholder = "Input your message"

        self.usernameTextField.textAlignment = .center
        self.usernameTextField.placeholder = "Input your name"

        self.sendButton.setTitle("Send", for: .normal)
        self.sendButton.setTitleColor(.white, for: .normal)
        self.sendButton.backgroundColor = .orange
        self.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        self.queueLabel.textAlignment = .center
        self.queueLabel.text = "Empty"
        self.queueLabel.textColor = .white
        self.queueLabel.font = UIFont(name: "Avenir-Roman", size: 40)

        self.titleLabel.textAlignment = .center
        self.titleLabel.text = "Choose\nQueue"
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textColor = .white
        self.titleLabel.font = UIFont(name: "Avenir-Roman", size: 30)

        self.queuesTableView.delegate = self
        self.queuesTableView.dataSource = self
        self.queuesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "queueNameCell")
        self.queuesTableView.layer.cornerRadius = 20.0
        self.queuesTableView.clipsToBounds = true

        self.model.getNames { names in
            self.queuesNames = names
            self.queuesTableView.reloadData()
        }
    }

    private func showAlert(with title: String, for message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let alertAction = UIAlertAction(
            title: "Ok",
            style: .default,
            handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }
        )
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }

    private func showResultAlert() {
        self.showAlert(with: "Success", for: "Your message was sended")
    }

    private func showErrorAlert() {
        self.showAlert(with: "Error", for: "Please setup all fields")
    }

    @objc private func sendButtonTapped() {
        guard let messageText = self.messageTextField.text else { self.showErrorAlert(); return }
        guard let usernameText = self.usernameTextField.text else { self.showErrorAlert(); return }
        guard let queueName = self.queueLabel.text, queueName != "Empty" else { self.showErrorAlert(); return }

        NetworkManagerImpl.shared.sendMessage(
            with: "[\(queueName)] ~ \(messageText)",
            username: usernameText,
            queueName: queueName,
            completion: { [weak self] operationCompleted in
                if operationCompleted {
                    self?.showResultAlert()
                } else {
                    self?.showErrorAlert()
                }
            }
        )
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.queueLabel.text = self.queuesNames[indexPath.row]
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.queuesNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "queueNameCell", for: indexPath)
        cell.textLabel?.text = self.queuesNames[indexPath.row]
        return cell
    }
}
