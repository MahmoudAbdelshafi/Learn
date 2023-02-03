//
//  LessonScenesFlow.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 31/01/2023.
//

import UIKit
import SwiftUI

protocol LessonsScenesFlowCoordinatorDependencies {
    func makeMainLessonsHostingController() -> MainLessonsHostingController
   static func makeLessonDetailsViewController(lesson: Lesson, nextLessons: [Lesson]) -> LessonDetailsViewController
}

final class LessonsScenesCoordinator {
    
    private weak var navigationController: UINavigationController?
     let dependencies: LessonsScenesFlowCoordinatorDependencies
    
    private weak var mainLessonsVC: MainLessonsHostingController?
    
    init(navigationController: UINavigationController,
         dependencies: LessonsScenesFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let hostingController = dependencies.makeMainLessonsHostingController()
        navigationController?.pushViewController(hostingController, animated: false)
        mainLessonsVC = hostingController
    }

}
