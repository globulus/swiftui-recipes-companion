//
//  DIFramework.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation

public struct Service {
    public enum LifeCycle {
       case singleton
       case factory
    }

    /// Holds the lifecycle of the current service
    public var cycle: LifeCycle

    /// Unique name for each service
    public let name: ObjectIdentifier

    /// The closure that will resolve the service
    private let resolve: (Dependencies) -> Any

    var instance: Any?

    func createInstance(d: Dependencies) -> Any {
       return resolve(d)
    }

    /// Initialize a service with a resolver
    public init<Service>(_ cycle: LifeCycle = .factory, _ resolve: @escaping (Dependencies) -> Service) {
        self.name = ObjectIdentifier(Service.self)
        self.resolve = resolve
        self.cycle = cycle
    }
    
    public init<Service>(of: Service.Type, _ cycle: LifeCycle = .factory, _ resolve: @escaping (Dependencies) -> Service) {
        self.init(cycle, resolve)
    }
}

public class Dependencies {
    public var factories: [ObjectIdentifier: Service] = [:]

    private init() { }

    deinit {
        factories.removeAll()
    }
}

private extension Dependencies {

    /// Resolve a serice based on its ObjectIdentifier
    func resolve<Service>() -> Service {
        var service = self.factories[ObjectIdentifier(Service.self)]!
        guard let instance = service.instance,
              service.cycle == .singleton else {
            service.instance = service.createInstance(d: self)
            self.factories[service.name] = service
            return service.instance as! Service
        }
        return instance as! Service
    }

    /// Register a service with our resolver
    private func register(_ service: Service) {
        self.factories[service.name] = service
    }
}

public extension Dependencies {
    /// Create a overridable main resolver
    static var main = Dependencies()

    func get<Service>() -> Service {
        return resolve()
    }

    @resultBuilder struct DependencyBuilder {
        public static func buildBlock(_ services: Service...) -> [Service] { services }
        public static func buildBlock(_ service: Service) -> Service { service }
    }

    convenience init(@DependencyBuilder _ services: () -> [Service]) {
        self.init()
        services().forEach { register($0) }
    }

    convenience init(@DependencyBuilder _ service: () -> Service) {
        self.init()
        register(service())
    }

    func build() {
        Self.main = self
    }
}

@propertyWrapper
struct Inject<Service> {
    typealias DelayedInjection = () -> Service

    var service: Service?
    var delayed: DelayedInjection?

    init() {
        delayed = { Dependencies.main.resolve() }
    }

    var wrappedValue: Service {
        mutating get {
            if let service = service {
                return service
            } else if let delayed = delayed {
                service = delayed()
                return service!
            } else {
                fatalError()
            }
        }
    }
}

func inject<Service>() -> Service {
    Dependencies.main.get()
}
