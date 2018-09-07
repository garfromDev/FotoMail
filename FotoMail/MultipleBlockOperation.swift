//
//  MultipleBlockOperation.swift
//  FotoMail
//
//  Created by Alistef on 01/09/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

import Foundation

// NOTE : not used in FotoMail

/**
  Allow to launch a sequence of block excution on a serial queue, with cancellation possible between each bloc
    cancellation is triggered by queue.cancelAllOperations()
    parameter are chained from output to input between bloc
    firstParameter will be provided to firdt bloc, the output will be next bloc input
    a cancel handler can be provided to clear what must be clear in case of cancellation
    any bloc can dispatch async on the main queue to update UI (see unit test for use)
*/
final class MultipleBlockOperation:Operation{
    private let queue : OperationQueue
    private let blocs:[(Any?)->Any?]
    private let firstParameter:Any?
    private let cancelHandler:()->()
    typealias ChainedBlocs =  [(Any?)->Any?]
    
    // impossible to declare ChainedBloc as escaping, need to create an add function instead? which return the Operation itself to allow chaining?
    init( blocs: ChainedBlocs,
          queue:OperationQueue = OperationQueue(),
          firstParameter:Any? = nil,
          cancelHandler:@escaping ()->() = {}){
        self.queue = queue
        self.queue.maxConcurrentOperationCount=1
        self.blocs = blocs
        self.firstParameter = firstParameter
        self.cancelHandler = cancelHandler
        super.init()
    }
    
    
    override func main(){
        guard !self.isCancelled else {
            cancelHandler()
            return
        }
        var input = self.firstParameter
        var output:Any?
        for b in blocs{
            output = b(input)
            guard !self.isCancelled else {
                cancelHandler()
                return
            }
            input=output
        }
    }
}

