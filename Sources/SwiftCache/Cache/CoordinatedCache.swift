//
//  File.swift
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
        if let ongoingTask = taskManager[id] {
            // Avoid reentrancy, just wait for the ongoing task that is already doing the stuff.
            return await ongoingTask.value
        } else {
            let newTask = Task {
                let result = parent.cachedValueWith(id: id)
                taskManager.removeValue(forKey: id)
                return result
            }

            taskManager[id] = newTask
            return try await newTask.value
        }
    }
}

extension SyncCache {
    func coordinated() -> some AsyncCache {
        CoordinatedSyncCache(parent: self)
    }
}

private actor CoordinatedAsyncCache {

}
