import Vapor

/// Register your application's routes here.

struct QueuesNames: Content {
    let names: [String]

    init() {
        self.names = Priorities.allCases.map { $0.rawValue }
    }
}

protocol IBaseJob {
    func perform(from workerId: Int)
}

class Work: IBaseJob {
    let id = UUID().uuidString
    private let username: String
    private let message: String

    func perform(from workerId: Int) {
        print("∆ [WORKER \(workerId)] = username: \(username) -> message: \(message)")
    }

    init(username: String, message: String) {
        self.username = username
        self.message = message
    }
}

// add new value to configure new priority
enum Priorities: String, CaseIterable {
    case high = "high"
    case middle = "middle"
    case low = "low"

    static let growUp: [Priorities] = [.high, .middle, .low]
}

func priotiryForValue(_ line: String) -> Priorities {
    for priotiry in Priorities.allCases {
        if priotiry.rawValue == line {
            return priotiry
        }
    }
    return .low
}

class Worker {
    private var worksDict: [Priorities: [Work]] = [:]
    private let id: Int

    init(id: Int) {
        print("created worker")
        self.id = id
        Priorities.allCases.forEach { self.worksDict[$0] = [] }
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData), name: Notification.Name("workerTriggered"), object:  nil)
    }

    @objc private func onDidReceiveData() {
        let priorityList = Priorities.growUp
        for priority in priorityList {
            guard var worksList = self.worksDict[priority] else { continue }
            guard !worksList.isEmpty else { continue }

            let work = worksList.removeFirst()
            work.perform(from: self.id)
            self.worksDict[priority] = worksList
            return
        }
    }

    func appendWork(_ work: Work, for priority: Priorities) {
        guard var works = self.worksDict[priority] else { return }
        works.append(work)
        self.worksDict[priority] = works
    }

    func numberOfWorks() -> Int {
        let priorityList = Priorities.growUp
        var result = 0
        for priority in priorityList {
            guard let works = self.worksDict[priority] else { continue }
            result += works.count
        }
        return result
    }

    func numberOfWorks(for priority: Priorities) -> Int {
        guard let works = self.worksDict[priority] else { return 0 }
        return works.count
    }
}

struct PostContent: Content {
    let username: String
    let message: String
    let queueName: String
}

func configureWorkers(for number: Int) -> [Worker] {
    var result = [Worker]()
    (0..<number).forEach { id in
        result.append(Worker(id: id))
    }
    return result
}

func getIndexOfSutableWorker(in list: [Worker], with priority: Priorities) -> Int {
    var minValue = 0
    var result = 0
    for (index, worker) in list.enumerated() {
        if index == 0 {
            minValue = worker.numberOfWorks(for: priority)
            continue
        }
        if minValue > worker.numberOfWorks(for: priority) {
            minValue = worker.numberOfWorks(for: priority)
            result = index
        }
    }
    return result
}

public func routes(_ router: Router) throws {
    let numberOfWorkers = LocalConfigurations.shared.configturations.numberOfWorkers
    let workers = configureWorkers(for: numberOfWorkers)

    router.get("get-queues-names") { req in
        return QueuesNames()
    }

    router.post(PostContent.self, at: "send-message") { req, reqDecodable -> Response in
        let response = Response(using: req)

        guard let data = req.http.body.data else {
            response.http.status = .notFound
            return response
        }
        guard let content = try? JSONDecoder().decode(PostContent.self, from: data) else {
            response.http.status = .notFound
            return response
        }
        let work = Work(username: content.username, message: content.message)
        let priority = priotiryForValue(content.queueName)
        let indexOfWorker = getIndexOfSutableWorker(in: workers, with: priority)
        workers[indexOfWorker].appendWork(work, for: priority)

        response.http.status = .ok
        return response
    }
}
