//
//  SmartlockTests.m
//  SmartlockTests
//
//  Created by RivenL on 15/3/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface SmartlockTests : XCTestCase

@end

@implementation SmartlockTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#if 0
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self gcdDemo4];
}
#pragma mark - 串行队列
- (void)gcdDemo1 {
    // 1. 串行队列
    // 在使用GCD的时候，先敲dispatch
    // 在C语言中，定义对象通常是以 _t 或者 Ref 结尾的
    dispatch_queue_t q = dispatch_queue_create("myQueueName", DISPATCH_QUEUE_SERIAL); //DISPATCH_QUEUE_SERIAL 的值为 NULL
    NSLog(@"%@", [NSThread currentThread]);
    // 2. 同步任务 sync(实际开发中没用)
    for (int i = 0; i < 10; i++) {
        dispatch_sync(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
    }
    // 2. 异步任务 async，能够开线程
    // 串行队列中，异步任务最多只能开一条线程，所有任务顺序执行！
    // 串行队列，异步任务，在多线程中，是斯坦福大学最推荐的一种多线程方式！
    // 优点：将任务放在其他线程中工作，每个任务顺序执行，便于调试
    // 缺点：并发能力不强，最多只能使用一条线程！
    for (int i = 0; i < 10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
    }
}

#pragma mark - 并行队列
- (void)gcdDemo2 {
    // 1. 并行队列
    dispatch_queue_t q = dispatch_queue_create("myQueueName", DISPATCH_QUEUE_CONCURRENT);
    // 非ARC中，需要自己释放队列
    //    dispatch_release(q);
    // 2. 同步任务，不会开启新的线程
    // 在实际开发中，同步任务可以保证执行完成之后，才让后续的异步任务开始执行，用于控制任务之间的先后顺序，如在后台线程中，处理“用户登录”等
    for (int i = 0; i < 10; i++) {
        dispatch_sync(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
    }
    // 3. 异步任务，会在多条线程上工作，具体开多少条线程，由系统决定
    // 仍然是按照任务添加到队列中的顺序被调度，只是执行先后可能会有差异！
    // *** 能够将耗时的操作，放到子线程中工作
    // *** 与串行队列异步任务相比，并发性能更好！但是执行的先后顺序，不固定
    for (int i = 0; i < 10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
    }
}

#pragma mark - 全局并行(并发)队列（使用更为普遍一些）
- (void)gcdDemo3 {
    // 1. 获取全局队列（与自定义并行队列的区别就是名字显示，其他都一样）
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 使用全局队列，不需要考虑共享的问题
    // 2. 同步任务
    for (int i = 0; i < 10; i++) {
        dispatch_sync(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
    }
    // 3. 异步任务
    for (int i = 0; i < 10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
    }
}

#pragma mark - 主队列（专门调度在主线程上工作的队列，不能开线程）
- (void)gcdDemo4 {
    // 1. 获取主队列
    dispatch_queue_t q = dispatch_get_main_queue();
    // 2. 不要同步任务(死锁！！！)
    dispatch_sync(q, ^{
        NSLog(@"不会输出的!!!");
    });
    // 3. 异步任务，在主线程上依次顺序执行
    for (int i = 0; i < 10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
    }
}
#endif

@end
