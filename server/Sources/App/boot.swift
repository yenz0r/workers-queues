import Vapor

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    let workerTime = LocalConfigurations.shared.configturations.workerPeriod
    let dumpTime = LocalConfigurations.shared.configturations.dumpPeriod

    func notifyObservers(task: RepeatedTask) {
        NotificationCenter.default.post(name: Notification.Name("workerTriggered"), object: nil)
    }
    func dumpData(task: RepeatedTask) {
        NotificationCenter.default.post(name: Notification.Name("needToDumpData"), object: nil)
        // TODO: - implement dump logic
    }

    app.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(2), delay: TimeAmount.seconds(workerTime), notifyObservers)
    app.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(2), delay: TimeAmount.seconds(dumpTime), dumpData)
}
