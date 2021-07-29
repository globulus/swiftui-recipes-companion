//
//  CombineExtensions.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation
import Combine

typealias CallbackPublisher<T> = AnyPublisher<T, Error>
typealias SuccessPublisher = AnyPublisher<Void, Error>

func callbackJust<Output>(_ value: Output) -> CallbackPublisher<Output> {
    Just(value)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
}

func successJust() -> SuccessPublisher {
    callbackJust(())
}

extension Publisher {
    func emptySinkAndStore(in collection: inout Set<AnyCancellable>) {
        sink { (_) in
        } receiveValue: { (_) in
        }.store(in: &collection)
    }
}

extension Publisher {
    func logDebug(_ f: @escaping (Output) -> String) -> Publishers.HandleEvents<Self> {
        self.handleEvents(receiveSubscription: nil,
                          receiveOutput: { log.debug(f($0)) },
                          receiveCompletion: nil,
                          receiveCancel: nil,
                          receiveRequest: nil)
    }
    
    func logInfo(_ f: @escaping (Output) -> String) -> Publishers.HandleEvents<Self> {
        self.handleEvents(receiveSubscription: nil,
                          receiveOutput: { log.info(f($0)) },
                          receiveCompletion: nil,
                          receiveCancel: nil,
                          receiveRequest: nil)
    }
}

extension Publisher where Failure == Error {
    func sinkJust(onSuccess: @escaping (Output) -> Void,
                  onError: @escaping (Failure) -> Void,
                  onDone: (() -> Void)? = nil
    ) -> AnyCancellable {
        self.receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    onDone?()
                    onError(error)
                }
            } receiveValue: { value in
                onDone?()
                onSuccess(value)
            }
    }
}

struct ProgressPublisher<Progress, Output> {
    let progress: AnyPublisher<Progress, Never>?
    let result: CallbackPublisher<Output>
}

public extension Publishers {
    struct RetryIf<P: Publisher>: Publisher {
        public typealias Output = P.Output
        public typealias Failure = P.Failure
        
        let publisher: P
        let times: Int
        let condition: (P.Failure) -> Bool
                
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            guard times > 0 else { return publisher.receive(subscriber: subscriber) }
            
            publisher.catch { (error: P.Failure) -> AnyPublisher<Output, Failure> in
                if condition(error)  {
                    return RetryIf(publisher: publisher, times: times - 1, condition: condition).eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }.receive(subscriber: subscriber)
        }
    }
}

public extension Publisher {
    func retry(times: Int, if condition: @escaping (Failure) -> Bool) -> Publishers.RetryIf<Self> {
        Publishers.RetryIf(publisher: self, times: times, condition: condition)
    }
}
