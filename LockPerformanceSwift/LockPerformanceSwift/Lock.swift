//
//  Lock.swift
//  LockPerformanceSwift
//
//  Created by g on 2019/12/30.
//  Copyright © 2019 g. All rights reserved.
//

import Foundation
import UIKit

class LockTest {
    
    public static let `default` = LockTest()
    
    typealias BenchResult = ( 测试方案: String, 消耗时间: Double)
    let tupleResults : [BenchResult] = [BenchResult]()
    
    func totalTest(_ count:UInt = 1000){
        print("Run (\(count)) begin")
        
        let benchmark_results = [
        
        
        //不在安全的自旋锁
            
            
        testBlock("自旋锁 oss_spin_lock",count: count,block: { count in
            var spinLock = OS_SPINLOCK_INIT
            for _ in 0...count {
               OSSpinLockLock(&spinLock)
               OSSpinLockUnlock(&spinLock)
            }
        }),
        
        //信号量
        testBlock("信号量 semaphore",count: count,block: { count in
            let sem = DispatchSemaphore(value: 1)
            for _ in 0...count {
               _ = sem.wait(timeout: DispatchTime.distantFuture)
               sem.signal()
            }
        }),
        
        //只有ios10能用的unfairlock
        testBlock("os_unfair_lock",count: count,block: { count in
            var unfairLock = os_unfair_lock()
            for _ in 0...count {
                os_unfair_lock_lock(&unfairLock)
                os_unfair_lock_unlock(&unfairLock)
            }
        }),
        
        //NSLock
            /**
        NSLock只是在内部封装了一个pthread_mutex，属性为PTHREAD_MUTEX_ERRORCHECK，它会损失一定性能换来错误提示。这里使用宏定义的原因是，OC 内部还有其他几种锁，他们的 lock 方法都是一模一样，仅仅是内部pthread_mutex互斥锁的类型不同。通过宏定义，可以简化方法的定义。
             NSLock比pthread_mutex略慢的原因在于它需要经过方法调用，同时由于缓存的存在，多次方法调用不会对性能产生太大的影响。
            */
        testBlock("NSLock",count: count,block: { count in
            let lock = NSLock()
            for _ in 0...count {
               lock.lock()
               lock.unlock()
            }
        }),
            
        
        // pthread互斥
        testBlock("pthread mutex",count: count,block: { count in
              var mutex = pthread_mutex_t()
              for _ in 0...count {
                  pthread_mutex_lock(&mutex)
                  pthread_mutex_unlock(&mutex)
              }
        }),
        
         
        
        //syncronize关键词 递归锁本质
        //http://yulingtianxia.com/blog/2015/11/01/More-than-you-want-to-know-about-synchronized/
        testBlock("Syncronized",count: count,block: { count in
               let obj = NSObject()
               for _ in 0...count {
                   objc_sync_enter(obj)
                   objc_sync_exit(obj)
               }
        }),

        //队列
        testBlock("GCD Queue",count: count,block: { count in
                 let lockQueue = DispatchQueue.init(label: "com.test.LockQueue")
                 for _ in 0...count {
                      lockQueue.sync() {}
                 }
        }),
        
        testBlock("NSCondition",count: count,block: { count in
                 let lock = NSCondition()
                 for _ in 0...count {
                    lock.lock()
                    lock.unlock()
                 }
        }),
        
        testBlock("pthread mutex recursive",count: count,block: { count in
                var lock = pthread_mutex_t()
                var attr = pthread_mutexattr_t()
                pthread_mutexattr_init(&attr)
                pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
                pthread_mutex_init(&lock, &attr)
                pthread_mutexattr_destroy(&attr)
                for _ in 0...count {
                    pthread_mutex_lock(&lock)
                    pthread_mutex_unlock(&lock)
                }
        }),
    
        testBlock("NSRecursiveLock",count: count,block: { count in
               let lock = NSRecursiveLock()
               for _ in 0...count {
                    lock.lock()
                    lock.unlock()
               }
        }),
           
        testBlock("NSConditionLock",count: count,block: { count in
               let lock = NSConditionLock()
               for _ in 0...count {
                    lock.lock()
                    lock.unlock()
               }
        }),
        
        //读写锁 写锁 读共享
        testBlock("pthread_rwlock_t",count: count,block: { count in
              var rwlock = pthread_rwlock_t()
              for _ in 0...count {
                  pthread_rwlock_wrlock(&rwlock)
                  pthread_rwlock_unlock(&rwlock)
              }
        }),
        
     
        
        
        ]
        
        //结果 时间越短越好 按照时间从短到长排序
        var index = 1
        for bench in benchmark_results.sorted(by:{$0.消耗时间 < $1.消耗时间}){
           let str = String(format:"测试方案\(index)：\(bench.测试方案)， %.2f ms", bench.消耗时间)
           print(str)
           index += 1
        }
        
        
        print("Run (\(count)) end")
    }
    func testBlock(_ testName:String, count:UInt = 1000, block: (_ count:UInt)-> () ) -> BenchResult {
        
        let begin:TimeInterval = CACurrentMediaTime()
        block( count )
        let end:TimeInterval = CACurrentMediaTime()
        
        let time_diff = (end-begin) * 1000
////        let str = String(format:"\(testName) %.2f ms", time_diff)
//        print(str)
        
        return (testName,time_diff)
    }
}
