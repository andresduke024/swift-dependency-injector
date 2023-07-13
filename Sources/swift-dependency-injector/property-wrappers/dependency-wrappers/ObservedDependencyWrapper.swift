//
//  ObservedDependencyWrapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation
import Combine

final class ObservedDependencyWrapper<Value>: DependencyWrapper<Value> {
    private var subscriber: AnyCancellable?
    
    override init(_ filePath: String, _ line: Int) {
        super.init(filePath, line)
        subscribeToDependencyPublisher()
    }
    
    override func manageOnInitInstantiation() {
        DependenciesContainer.shared.requestPublisherUpdate(of: Value.self, observer: id)
    }
    
    private func subscribeToDependencyPublisher() {
        guard let publisher = DependenciesContainer.shared.getPublisher(of: Value.self) else {
            catchErrorGettingPublisher()
            return
        }
        
        subscriber = publisher
            .map { wrapper -> Wrapper<Value> in
                Wrapper(id: wrapper.observerId, value: AbstractionMapper.map(wrapper.value))
            }
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.catchSinkError(error)
                }
            } receiveValue: { [weak self] wrapper in
                self?.onNewImplementationReceived(wrapper: wrapper)
            }
    }
    
    private func catchErrorGettingPublisher() {
        Logger.log(InjectionErrors.noPublisherFounded(abstractionName: abstractionName))
        value = DependenciesContainer.shared.get(with: .regular)
    }
    
    private func onNewImplementationReceived(wrapper: Wrapper<Value>) {
        if let id = wrapper.id, id == self.id {
            self.value = wrapper.value
            return
        }
        
        if wrapper.id == nil {
            self.value = wrapper.value
        }
    }
    
    private func catchSinkError(_ error: Error) {
        Logger.log(error)
        self.value = nil
    }
    
    override func unwrapValue() -> Value? {
        if value == nil {
            DependenciesContainer.shared.requestPublisherUpdate(of: Value.self, observer: id)
        }
        
        checkInjectionError()
        return value
    }
    
    deinit { subscriber?.cancel() }
}
