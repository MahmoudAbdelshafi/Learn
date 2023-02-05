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
    func filterNextLessonsArray(index: Int) -> [Lesson]
    var error: Swift.Error? { get set }
}

protocol MainLessonsViewModelViewModelInput {
    func viewAppeared()
}

protocol MainLessonsViewModel: ObservableObject, MainLessonsViewModelViewModelInput, MainLessonsViewModelModelOutput { }

final class DefaultMainLessonsViewModel: ObservableObject, MainLessonsViewModel {
    
    
    //MARK: - Output Properties -
    
    @Published var lessonsData: [Lesson] = []
    
    //MARK: - Private Properties -
    
    private let fetchLessonsUseCase: FetchLessonsUseCase
    fileprivate var cancellableBag = Set<AnyCancellable>()
    @Published var error: Swift.Error?
    
    //MARK: - Init -
    
    init(fetchLessonsUseCase: FetchLessonsUseCase) {
        self.fetchLessonsUseCase = fetchLessonsUseCase
    }
    
    //MARK: - Priavte Functions -
    
    private func loadAllLessons() {
        fetchLessonsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink {  [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                }
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
    
    func filterNextLessonsArray(index: Int) -> [Lesson] {
        var arrayFiltered = lessonsData
        arrayFiltered.remove(atOffsets: IndexSet(0...index))
        return arrayFiltered
    }
}
