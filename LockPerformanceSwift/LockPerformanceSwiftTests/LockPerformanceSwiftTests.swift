//
//  LockPerformanceSwiftTests.swift
//  LockPerformanceSwiftTests
//
//  Created by g on 2019/12/30.
//  Copyright © 2019 g. All rights reserved.
//

import XCTest
@testable import LockPerformanceSwift

class LockPerformanceSwiftTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    
    func testStringFormat() {
        print(String(format: "%03d ms", 1))
    }
    //不在安全的自旋锁
    func testSpinLock() {
        var spinLock = OS_SPINLOCK_INIT
        executeLockTest { (block) in
            OSSpinLockLock(&spinLock)
            block()
            OSSpinLockUnlock(&spinLock)
        }
    }

    //只有ios10能用的unfairlock
    func testUnfairLock() {
        var unfairLock = os_unfair_lock_s()
        executeLockTest { (block) in
            os_unfair_lock_lock(&unfairLock)
            block()
            os_unfair_lock_unlock(&unfairLock)
        }
    }
    
    //信号量
    func testDispatchSemaphore() {
        let sem = DispatchSemaphore(value: 1)
        executeLockTest { (block) in
            _ = sem.wait(timeout: DispatchTime.distantFuture)
            block()
            sem.signal()
        }
    }

    //NSLock
    /**
NSLock只是在内部封装了一个pthread_mutex，属性为PTHREAD_MUTEX_ERRORCHECK，它会损失一定性能换来错误提示。这里使用宏定义的原因是，OC 内部还有其他几种锁，他们的 lock 方法都是一模一样，仅仅是内部pthread_mutex互斥锁的类型不同。通过宏定义，可以简化方法的定义。
     NSLock比pthread_mutex略慢的原因在于它需要经过方法调用，同时由于缓存的存在，多次方法调用不会对性能产生太大的影响。
    */
    func testNSLock() {
        let lock = NSLock()
        executeLockTest { (block) in
            lock.lock()
            block()
            lock.unlock()
        }
    }

    // pthread互斥
    func testPthreadMutex() {
        var mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
        executeLockTest{ (block) in
            pthread_mutex_lock(&mutex)
            block()
            pthread_mutex_unlock(&mutex)
        }
        pthread_mutex_destroy(&mutex);
    }

    // syncronize关键词
    func testSyncronized() {
        let obj = NSObject()
        executeLockTest{ (block) in
            objc_sync_enter(obj)
            block()
            objc_sync_exit(obj)
        }
    }

    //队列
    func testQueue() {
        let lockQueue = DispatchQueue.init(label: "com.test.LockQueue")
        executeLockTest{ (block) in
            lockQueue.sync() {
                block()
            }
        }
    }

    // 测试没有锁
    func disabled_testNoLock() {
        executeLockTest { (block) in
            block()
        }
    }
    
    func executeLockTest(performBlock:@escaping (_ block:() -> Void) -> Void) {
        let dispatchBlockCount = 16
        let iterationCountPerBlock = 100
        // This is an example of a performance test case.
        let queues = [
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive),
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default),
            DispatchQueue.global(qos: DispatchQoS.QoSClass.utility),
            ]
        var value = 0
        self.measure {
            let group = DispatchGroup.init()
            for block in 0..<dispatchBlockCount {
                group.enter()
                let blockModRes = block / queues.count
                print("block余数",blockModRes)
                let queue = queues[block % queues.count]
                queue.async(execute: {
                    for count in 0..<iterationCountPerBlock {
                        print(count)
                        performBlock({
                            value = value + 2
                            value = value - 1
                        })
                    }
                    group.leave()
                })
            }
            _ = group.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    
    
}
