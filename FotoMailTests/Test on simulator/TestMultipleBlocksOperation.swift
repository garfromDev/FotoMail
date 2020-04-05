//
//  TestMultipleBlocksOperation.swift
//  SimulatorFotoMailTests
//
//  Created by Alistef on 01/09/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

import XCTest

class MultipleBlockOperationTests: XCTestCase {
    var q=OperationQueue()
    var tasks:MultipleBlockOperation!
    var resultValue : String!
    
    let Task1ExecutedExpectation = XCTestExpectation(description: "Test1 executed")
    let Task2ExecutedExpectation = XCTestExpectation(description: "Test2 executed")
    let cancelledExpectation = XCTestExpectation(description: "cancelled")
    
    override func setUp() {
        super.setUp()
        tasks = MultipleBlockOperation(
            blocs:[
                { (p:Any?) in
                    guard let n = p as! Int? else {return nil}
                    print("=========== bloc \(n) executed")
                    self.Task1ExecutedExpectation.fulfill()
                    sleep(1)
                    return n+1
                },
                { (p:Any?) in
                    guard let n = p as! Int? else {return nil}
                    print("========== bloc \(n) executed")
                    self.Task2ExecutedExpectation.fulfill()
                    return n+1
                },
                ],
            queue:q,
            firstParameter:1,
            cancelHandler:{self.cancelledExpectation.fulfill()
                print("======== cancelled")})
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBlocExecution() {
            q.addOperation(tasks)
            self.wait(for: [Task1ExecutedExpectation,Task2ExecutedExpectation], timeout: 2.0)
    }
    
    func testCancellation(){
        q.addOperation(tasks)
        self.wait(for: [Task1ExecutedExpectation], timeout: 0.5)
        q.cancelAllOperations()
        self.wait(for: [cancelledExpectation], timeout: 5.0)
    }
    
    func testReturnValueOnMainThread(){
        let taskFinished = XCTestExpectation(description: "task finished")
        q.addOperation ( MultipleBlockOperation(blocs: [{ (v:Any?) in
            DispatchQueue.main.async {
                [weak self, taskFinished] in
                    self?.resultValue = "dispatch done"
                taskFinished.fulfill()
                    print("======= value changed")
                }
            }],
            queue:q)
        )

    self.wait(for: [taskFinished], timeout: 1.0)
        XCTAssert(self.resultValue == "dispatch done", "return value must changed to dispatch done")
        print("==== value is \(String(describing: self.resultValue))")
    }
}
