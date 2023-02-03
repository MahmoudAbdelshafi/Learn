//
//  LessonsScenesDiContainer.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 31/01/2023.
//

import UIKit

final class LessonsScenesDiContainer {
    
    // MARK: - Repositories -
    
    static func makeDefaultLessonsRepository() -> LessonsRepository {
        DefaultLessonsRepository(provider: Hover())
    }
    
    // MARK: - Use Cases -
    
    func makeDefaultFetchLessonsUseCase() -> FetchLessonsUseCase {
        DefaultFetchLessonsUseCase(lessonsRepository: LessonsScenesDiContainer.makeDefaultLessonsRepository())
    }
    
    static func makeDefaultDownloadLessonVideoUseCase() -> DownloadLessonVideoUseCase {
        DefaultDownloadLessonVideoUseCase(lessonsRepository: makeDefaultLessonsRepository())
    }
    
    //MARK: - ViewModels -
    
    func makeDefaultMainLessonsViewModel() -> DefaultMainLessonsViewModel {
        DefaultMainLessonsViewModel(fetchLessonsUseCase: makeDefaultFetchLessonsUseCase())
    }
    
   static func makeDefaultLessonDetailsViewModel(lesson: Lesson, nextLessons: [Lesson]) -> LessonDetailsViewModel {
       DefaultLessonDetailsViewModel(downloadLessonVideoUseCase: makeDefaultDownloadLessonVideoUseCase(),
                                     lesson: lesson,
                                     nextLessons: nextLessons)
    }
    
}

// MARK: - LessonsScenes Router Dependencies -

extension LessonsScenesDiContainer: LessonsScenesFlowCoordinatorDependencies {
    
   static func makeLessonDetailsViewController(lesson: Lesson, nextLessons: [Lesson]) -> LessonDetailsViewController {
       LessonDetailsViewController(viewModel: makeDefaultLessonDetailsViewModel(lesson: lesson, nextLessons: nextLessons))
    }
    
    func makeMainLessonsHostingController() -> MainLessonsHostingController {
        let viewModel = makeDefaultMainLessonsViewModel()
        return MainLessonsHostingController(rootView: MainView(viewModel: viewModel))
    }
    
    func makeLessonsScenesCoordinator(navigationController: UINavigationController) -> LessonsScenesCoordinator {
        LessonsScenesCoordinator(navigationController: navigationController, dependencies: self)
    }
}

