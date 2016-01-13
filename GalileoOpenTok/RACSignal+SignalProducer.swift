
import ReactiveCocoa

extension SignalProducer {
    func castSignal<T>() -> SignalProducer<T, Error> {
        return self.map({ $0 as! T })
    }
    
    func cantError() -> SignalProducer<Value, NoError> {
        // If we inline this, Swift will try to implicitly return the fatalError
        // expression. If we put an explicit return to stop this, it complains
        // it can never execute. One is an error, the other a warning, so we're
        // taking the coward's way out and doing this to sidestep the problem.
        func swallowError(error: Error) -> SignalProducer<Value, NoError> {
            fatalError("Underlying signal errored! \(error)")
        }
        
        return self.flatMapError(swallowError)
    }
}

extension RACSignal {
    func cast<T>() -> SignalProducer<T, NoError> {
        return self.toSignalProducer().cantError().map({ $0! }).castSignal()
    }
}
