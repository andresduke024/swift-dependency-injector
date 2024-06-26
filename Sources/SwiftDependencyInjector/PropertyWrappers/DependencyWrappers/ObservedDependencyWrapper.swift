//
//  ObservedDependencyWrapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation
import Combine

/// Manage the lifecycle of an Abstraction that will be injected using the @ObservedInjectable/@ObservedInject property wrapper
final class ObservedDependencyWrapper<Abstraction>: DependencyWrapper<Abstraction> {

    /// To store the subscription to the abstraction's publisher
    private var subscriber: AnyCancellable?

    /// To identify this wrapper as an unique subscriber
    private let id: String

    init(args: DependencyWrapperArgs) {
        let fileName = Utils.extractFileName(of: args.file, withExtension: false)
        let abstractionName = Utils.createName(for: Abstraction.self)
        let generatedId = UUID().uuidString

        self.id = String.join(fileName, abstractionName, generatedId, separator: ":")
        super.init(args.file, args.line, args.context)
        subscribeToDependencyPublisher()
        manageOnInitInstantiation()
    }

    /// **Override** A facade function used to perform all the validations and processes required before obtain an injected implementation.
    /// Validate if the implementation is not injected yet and will request an injection if is necessary.
    /// - Returns: An optional implementation of the given abstraction.
    override func unwrapValue() -> Abstraction? {
        if value == nil {
            tryToUpdateValue()
        }

        checkInjectionError()
        return value
    }

    /// To validate if the class is successfully subscribed to the dependency publisher and request an update from it.
    private func tryToUpdateValue() {
        if subscriber == nil { subscribeToDependencyPublisher() }
        DependenciesContainer.global.get(context).requestPublisherUpdate(of: Abstraction.self, subscriber: id)
    }

    /// To manage and define the way and the moment at the implementation has to be instantiated.
    /// It will request a injection of the given abstraction but only for this wrapper.
    private func manageOnInitInstantiation() {
        DependenciesContainer.global.get(context).requestPublisherUpdate(of: Abstraction.self, subscriber: id)
    }

    /// It obtains and subscribes to a publisher of the given abstraction.
    private func subscribeToDependencyPublisher() {
        guard let publisher = DependenciesContainer.global.get(context).getPublisher(of: Abstraction.self) else {
            catchErrorGettingPublisher()
            return
        }

        subscriber = publisher
            .map { wrapper -> PublishedValueWrapper<Abstraction> in
                PublishedValueWrapper(id: wrapper.subscriberId, value: AbstractionMapper.map(wrapper.value))
            }.sink { [weak self] completion in
                self?.onSubscriptionEnded(completion)
            } receiveValue: { [weak self] wrapper in
                self?.onNewImplementationReceived(wrapper)
            }
    }

    /// To log an error in case the publisher could not be obtained and set a default implementation instance for the 'value' property.
    private func catchErrorGettingPublisher() {
        let abstractionName = Utils.createName(for: Abstraction.self)
        Logger.log(InjectionErrors.noPublisherFounded(abstractionName))
        value = DependenciesContainer.global.get(context).get(with: .regular, key: constraintKey)
    }

    /// To manage when the abstraction's publisher send a completion event.
    /// - Parameter completion: The completion event with an error of type 'InjectionErrors'.
    private func onSubscriptionEnded(_ completion: Subscribers.Completion<InjectionErrors>) {
        if case .failure(let error) = completion {
            self.catchSinkError(error)
        }
    }

    /// To log an error sended by the abstraction's publisher and set as nil the 'value' property.
    /// - Parameter error: The specific error.
    private func catchSinkError(_ error: InjectionErrors) {
        Logger.log(error)
        self.value = nil
    }

    /// To manage the new implementations sended by the abstraction's publisher.
    /// If the id stored inside the wrapper is nil means the implementation was sended to all subscribers.
    /// - Parameter wrapper: A wrapper that contains the new implementation and an optional id to identify the specific subscriber to which the event was sent.
    private func onNewImplementationReceived(_ wrapper: PublishedValueWrapper<Abstraction>) {
        if wrapper.id == nil {
            setNewImplementation(wrapper.value)
        } else if let id = wrapper.id, id == self.id {
            setNewImplementation(wrapper.value)
        }
    }

    /// To set a new implementation an log the changes.
    /// - Parameter value: The new implementation value.
    private func setNewImplementation(_ value: Abstraction?) {
        let isNilValue = value != nil ? "not " : ""
        let abstractionName = Utils.createName(for: Abstraction.self)

        Logger.log("New implementation of '\(abstractionName)' with a \(isNilValue)nil value received on subscriber: \(id)")
        self.value = value
    }
}
