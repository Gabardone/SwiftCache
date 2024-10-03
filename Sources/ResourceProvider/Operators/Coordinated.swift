//
//  Coordinated.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

private actor SyncProviderCoordinator<ID: Hashable, Value> {
    typealias Parent = SyncProvider<ID, Value>

    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, Never>]()

    fileprivate func taskFor(id: ID) -> Task<Value, Never> {
        taskManager[id] ?? {
            let newTask = Task {
                let result = parent.valueForID(id)
                taskManager.removeValue(forKey: id)
                return result
            }

            taskManager[id] = newTask
            return newTask
        }()
    }
}

public extension SyncProvider {
    func coordinated() -> AsyncProvider<ID, Value> {
        let coordinator = SyncProviderCoordinator(parent: self)

        return .init { id in
            await coordinator.taskFor(id: id).value
        }
    }
}

private actor ThrowingSyncProviderCoordinator<ID: Hashable, Value> {
    typealias Parent = ThrowingSyncProvider<ID, Value>

    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, Error>]()

    fileprivate func taskFor(id: ID) -> Task<Value, Error> {
        taskManager[id] ?? {
            let newTask = Task { [self] in
                defer {
                    self.taskManager.removeValue(forKey: id)
                }

                return try parent.valueForID(id)
            }

            taskManager[id] = newTask
            return newTask
        }()
    }
}

public extension ThrowingSyncProvider {
    func coordinated() -> ThrowingAsyncProvider<ID, Value> {
        let coordinator = ThrowingSyncProviderCoordinator(parent: self)

        return .init { id in
            try await coordinator.taskFor(id: id).value
        }
    }
}

private actor AsyncProviderCoordinator<ID: Hashable, Value> {
    typealias Parent = AsyncProvider<ID, Value>

    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, Never>]()

    fileprivate func taskFor(id: ID) -> Task<Value, Never> {
        taskManager[id] ?? {
            let newTask = Task {
                let result = await parent.valueForID(id)
                taskManager.removeValue(forKey: id)
                return result
            }

            taskManager[id] = newTask
            return newTask
        }()
    }
}

public extension AsyncProvider {
    func coordinated() -> AsyncProvider {
        let coordinator = AsyncProviderCoordinator(parent: self)

        return .init { id in
            await coordinator.taskFor(id: id).value
        }
    }
}

private actor ThrowingAsyncProviderCoordinator<ID: Hashable, Value> {
    typealias Parent = ThrowingAsyncProvider<ID, Value>

    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, Error>]()

    fileprivate func taskFor(id: ID) -> Task<Value, Error> {
        taskManager[id] ?? {
            let newTask = Task { [self] in
                defer {
                    self.taskManager.removeValue(forKey: id)
                }

                return try await parent.valueForID(id)
            }

            taskManager[id] = newTask
            return newTask
        }()
    }
}

public extension ThrowingAsyncProvider {
    func coordinated() -> ThrowingAsyncProvider {
        let coordinator = ThrowingAsyncProviderCoordinator(parent: self)

        return .init { id in
            try await coordinator.taskFor(id: id).value
        }
    }
}
