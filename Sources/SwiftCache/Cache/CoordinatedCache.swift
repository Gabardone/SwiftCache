//
//  CoordinatedCache.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

private actor CoordinatedSyncCache<
    ID: Hashable,
    Value,
    Parent: SyncCache
> where Parent.ID == ID, Parent.Value == Value {
    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, Never>]()
}

extension CoordinatedSyncCache: AsyncCache {
    public func cachedValueWith(id: ID) async -> Value {
        await taskFor(id: id).value
    }

    private func taskFor(id: ID) -> Task<Value, Never> {
        taskManager[id] ?? {
            let newTask = Task {
                let result = parent.cachedValueWith(id: id)
                taskManager.removeValue(forKey: id)
                return result
            }

            taskManager[id] = newTask
            return newTask
        }()
    }
}

public extension SyncCache {
    func coordinated() -> some AsyncCache<ID, Value> {
        CoordinatedSyncCache(parent: self)
    }
}

private actor CoordinatedThrowingSyncCache<
    ID: Hashable,
    Value,
    Parent: ThrowingSyncCache
> where Parent.ID == ID, Parent.Value == Value {
    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, Error>]()
}

extension CoordinatedThrowingSyncCache: ThrowingAsyncCache {
    public func cachedValueWith(id: ID) async throws -> Value {
        try await taskFor(id: id).value
    }

    private func taskFor(id: ID) -> Task<Value, Error> {
        taskManager[id] ?? {
            let newTask = Task { [self] in
                defer {
                    self.taskManager.removeValue(forKey: id)
                }

                return try parent.cachedValueWith(id: id)
            }

            taskManager[id] = newTask
            return newTask
        }()
    }
}

public extension ThrowingSyncCache {
    func coordinated() -> some ThrowingAsyncCache<ID, Value> {
        CoordinatedThrowingSyncCache(parent: self)
    }
}

private actor CoordinatedAsyncCache<
    ID: Hashable,
    Value,
    Parent: AsyncCache
> where Parent.ID == ID, Parent.Value == Value {
    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, Never>]()
}

extension CoordinatedAsyncCache: AsyncCache {
    public func cachedValueWith(id: ID) async -> Value {
        await taskFor(id: id).value
    }

    private func taskFor(id: ID) -> Task<Value, Never> {
        taskManager[id] ?? {
            let newTask = Task {
                let result = await parent.cachedValueWith(id: id)
                taskManager.removeValue(forKey: id)
                return result
            }

            taskManager[id] = newTask
            return newTask
        }()
    }
}

public extension AsyncCache {
    func coordinated() -> some AsyncCache<ID, Value> {
        CoordinatedAsyncCache(parent: self)
    }
}

private actor CoordinatedThrowingAsyncCache<
    ID: Hashable,
    Value,
    Parent: ThrowingAsyncCache
> where Parent.ID == ID, Parent.Value == Value {
    init(parent: Parent) {
        self.parent = parent
    }

    let parent: Parent

    var taskManager = [ID: Task<Value, Error>]()
}

extension CoordinatedThrowingAsyncCache: ThrowingAsyncCache {
    public func cachedValueWith(id: ID) async throws -> Value {
        try await taskFor(id: id).value
    }

    private func taskFor(id: ID) -> Task<Value, Error> {
        taskManager[id] ?? {
            let newTask = Task { [self] in
                defer {
                    self.taskManager.removeValue(forKey: id)
                }

                return try await parent.cachedValueWith(id: id)
            }

            taskManager[id] = newTask
            return newTask
        }()
    }
}

public extension ThrowingAsyncCache {
    func coordinated() -> some ThrowingAsyncCache<ID, Value> {
        CoordinatedThrowingAsyncCache(parent: self)
    }
}
