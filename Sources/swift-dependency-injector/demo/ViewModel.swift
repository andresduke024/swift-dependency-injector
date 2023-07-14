//
//  ViewModel.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

class ViewModel {
    @Injectable
    private var service: Service?
    
    @Injectable(injection: .singleton)
    private var networkManager: NetworkManager?
    
    var data: [Int] = []
    
    func loadData() {
        guard let service else { return }
        networkManager?.validateConnection()
        data = service.getData()
    }
}
