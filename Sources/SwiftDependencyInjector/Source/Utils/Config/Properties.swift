//
//  Properties.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 3/04/25.
//

struct Properties: Sendable {
    static private let container = ConcurrencySafeStorage<Bool>(initialValues: [
        Keys.informationLogsAreActive.rawValue: true,
        Keys.isLoggerActive.rawValue: true
    ])
    
    private enum Keys: String {
        case informationLogsAreActive
        case isLoggerActive
    }
    
    /// To define if the messages that are only informative will be printed on console or not.
    static var informationLogsAreActive: Bool {
        get {
            container.get(key: Keys.informationLogsAreActive.rawValue) ?? false
        } set {
            container.set(key: Keys.informationLogsAreActive.rawValue, newValue)
        }
    }
    
    /// To define if the messages will be printed on console or not.
    static var isLoggerActive: Bool {
        get {
            container.get(key: Keys.isLoggerActive.rawValue) ?? false
        } set {
            container.set(key: Keys.isLoggerActive.rawValue, newValue)
        }
    }
}
