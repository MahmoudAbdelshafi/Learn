//
//  CoreDataLessonsResponseStorage.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 03/02/2023.
//

import Foundation
import CoreData
import Combine

final class CoreDataLessonsResponseStorage {
    
    private let coreDataStorage: CoreDataStorage
    
    init(coreDataStorage: CoreDataStorage = CoreDataStorage.shared) {
        self.coreDataStorage = coreDataStorage
    }
}

//MARK: - LessonsResponseStorage -

extension CoreDataLessonsResponseStorage: LessonsResponseStorage {
    
    func getCached() -> AnyPublisher<LessonsDTO, CoreDataStorageError> {
        let pass = PassthroughSubject<LessonsDTO,CoreDataStorageError>()
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = CoreDataLesson.fetchRequest()
                let requestEntity = try context.fetch(fetchRequest)
                let coreDataDTO = CoreDataLesson.toLessonsDTO(requestEntity)
                pass.send(coreDataDTO)
            } catch {
                pass.send(completion: .failure(error as! CoreDataStorageError))
            }
        }
        return pass.eraseToAnyPublisher()
    }
    
    
    func cacheLessonsResponse(response: LessonsDTO) {
        coreDataStorage.performBackgroundTask { [weak self] context in
            self?.clearAllCachedLessons()
            guard let lessons = response.lessons else {return}
            for lesson in lessons {
                if let _ = lesson.toCoreDataLessonEntityForInserting(context: context) {
                    do {
                        try context.save()
                    } catch {
                        ///Error
                    }
                }
            }
        }
    }
    
    
}

// MARK: - Private Functions-

extension CoreDataLessonsResponseStorage {
    
    private func clearAllCachedLessons() {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = CoreDataLesson.fetchRequest()
                let requestEntity = try context.fetch(fetchRequest)
                _ = requestEntity.map {context.delete($0)}
                try context.save()
            } catch {
                print(error)
            }
        }
    }
}
