//
//  MainLessonsViewModel.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 31/01/2023.
//

import Foundation
import Combine
import SwiftUI

protocol MainLessonsViewModelModelOutput {
    var lessonsData: [Lesson] { get }
}

protocol MainLessonsViewModelViewModelInput {
    func viewAppeared()
}

protocol MainLessonsViewModel: ObservableObject, MainLessonsViewModelViewModelInput, MainLessonsViewModelModelOutput { }

final class DefaultMainLessonsViewModel: MainLessonsViewModel {
 
    
    //MARK: - Output Properties -
    
    @Published var lessonsData: [Lesson] = []
    
    //MARK: - Private Properties -
    
    private let fetchLessonsUseCase: FetchLessonsUseCase
    fileprivate var cancellableBag = Set<AnyCancellable>()
    
    //MARK: - Init -
    
    init(fetchLessonsUseCase: FetchLessonsUseCase) {
        self.fetchLessonsUseCase = fetchLessonsUseCase
    }
    
    //MARK: - Priavte Functions -
    
    private func loadAllLessons() {
        fetchLessonsUseCase.execute()
            .sink { error in
                debugPrint(error)
            } receiveValue: { [weak self] lessons in
                self?.lessonsData.removeAll()
                self?.lessonsData = lessons
            }.store(in: &cancellableBag)
    }
    
}

//MARK: - Inputs -

extension DefaultMainLessonsViewModel {
    
    func viewAppeared() {
        loadAllLessons()
    }
}

//MARK: - Outputs -

extension DefaultMainLessonsViewModel {
    
    
}
