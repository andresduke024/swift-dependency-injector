//
//  App.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

class App {
    init() {
        ApplicationSetup.start()
    }
    
    func main() {
        let viewModel = ViewModel()
        viewModel.loadData()
        print("The data was loaded \(viewModel.data)")
    }
}
