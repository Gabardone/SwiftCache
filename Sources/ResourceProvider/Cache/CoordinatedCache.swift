//
//  CoordinatedCache.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

private actor SyncCacheCoordinator<ID: Hashable, Value> {
    typealias Parent = SyncResourceProvider<ID, Value>

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

public extension SyncResourceProvider {
    func coordinated() -> AsyncResourceProvider<ID, Value> {
        let coordinator = SyncCacheCoordinator(parent: self)

        return .init { id in
            await coordinator.taskFor(id: id).value
        }
    }
}

private actor ThrowingSyncCacheCoordinator<ID: Hashable, Value> {
    typealias Parent = ThrowingSyncResourceProvider<ID, Value>

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

public extension ThrowingSyncResourceProvider {
    func coordinated() -> ThrowingAsyncResourceProvider<ID, Value> {
        let coordinator = ThrowingSyncCacheCoordinator(parent: self)

        return .init { id in
            try await coordinator.taskFor(id: id).value
        }
    }
}

private actor AsyncCacheCoordinator<ID: Hashable, Value> {
    typealias Parent = AsyncResourceProvider<ID, Value>

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

public extension AsyncResourceProvider {
    func coordinated() -> AsyncResourceProvider {
        let coordinator = AsyncCacheCoordinator(parent: self)

        return .init { id in
            await coordinator.taskFor(id: id).value
        }
    }
}

private actor ThrowingAsyncCacheCoordinator<ID: Hashable, Value> {
    typealias Parent = ThrowingAsyncResourceProvider<ID, Value>

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

public extension ThrowingAsyncResourceProvider {
    func coordinated() -> ThrowingAsyncResourceProvider {
        let coordinator = ThrowingAsyncCacheCoordinator(parent: self)

        return .init { id in
            try await coordinator.taskFor(id: id).value
        }
    }
}
