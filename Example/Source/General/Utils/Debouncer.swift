//
//  Debouncer.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/17.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class Debouncer {
    
    private let label: String
    private let interval: Int
    private let queue: DispatchQueue
    private var workItem: DispatchWorkItem?
    private var lock: DispatchSemaphoreWrapper
    
    /// interval: 单位毫秒
    init(label: String = "Debouncer", interval: Int = 500) {
        self.label = label
        self.interval = interval
        self.queue = DispatchQueue(label: label)
        self.lock = DispatchSemaphoreWrapper(value: 1)
    }
    
    func call(_ callback: @escaping (() -> ())) {
        self.lock.sync {
            self.workItem?.cancel()
            self.workItem = DispatchWorkItem {
                DispatchQueue.main.async {
                    callback()
                }
            }
            
            if let workItem = self.workItem {
                self.queue.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(interval), execute: workItem)
            }
        }
    }
    
}

struct DispatchSemaphoreWrapper {
    private var lock: DispatchSemaphore
    init(value: Int) {
        self.lock = DispatchSemaphore(value: 1)
    }
    
    func sync(execute: () -> ()) {
        _ = lock.wait(timeout: DispatchTime.distantFuture)
        lock.signal()
        execute()
    }
}

let debouncer = Debouncer()
