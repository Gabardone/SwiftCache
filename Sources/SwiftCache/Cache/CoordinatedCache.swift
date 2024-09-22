//
//  CoordinatedCache.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

private actor SyncCacheCoordinator<ID: Hashable, Value> {
    typealias Parent = SyncCache<ID, Value>

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

public extension SyncCache {
    func coordinated() -> AsyncCache<ID, Value> {
        let coordinator = SyncCacheCoordinator(parent: self)

        return .init { id in
            await coordinator.taskFor(id: id).value
        }
    }
}

private actor ThrowingSyncCacheCoordinator<ID: Hashable, Value> {
    typealias Parent = ThrowingSyncCache<ID, Value>

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

public extension ThrowingSyncCache {
    func coordinated() -> ThrowingAsyncCache<ID, Value> {
        let coordinator = ThrowingSyncCacheCoordinator(parent: self)

        return .init { id in
            try await coordinator.taskFor(id: id).value
        }
    }
}

private actor AsyncCacheCoordinator<ID: Hashable, Value> {
    typealias Parent = AsyncCache<ID, Value>

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

public extension AsyncCache {
    func coordinated() -> AsyncCache {
        let coordinator = AsyncCacheCoordinator(parent: self)

        return .init { id in
            await coordinator.taskFor(id: id).value
        }
    }
}

private actor ThrowingAsyncCacheCoordinator<ID: Hashable, Value> {
    typealias Parent = ThrowingAsyncCache<ID, Value>

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

public extension ThrowingAsyncCache {
    func coordinated() -> ThrowingAsyncCache {
        let coordinator = ThrowingAsyncCacheCoordinator(parent: self)

        return .init { id in
            try await coordinator.taskFor(id: id).value
        }
    }
}
