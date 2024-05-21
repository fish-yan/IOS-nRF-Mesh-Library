//
//  MeshTaskManager.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class MeshTaskManager {
    typealias MeshTaskType = (task: MeshTask, status: MeshTaskStatus)
    
    var current: Int = -1
    var tasks: [MeshTaskType] = []
    
    func append(_ task: MeshTask) {
        tasks.append((task, .pending))
    }
    
    func update(status: MeshTaskStatus) {
        guard current < tasks.count, current >= 0 else { return }
        tasks[current].status = status
    }
    
    var finished: Bool { current >= tasks.count }
    
    var task: MeshTask? {
        if current >= 0 && current < tasks.count {
            return tasks[current].task
        } else {
            return nil
        }
    }
    
    var nextTask: MeshTask? {
        if current < tasks.count - 1 {
            current += 1
            return tasks[current].task
        } else {
            return nil
        }
    }
}
