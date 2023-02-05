//
//  MainLessonsHostingController.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 31/01/2023.
//

import UIKit
import Combine
import SwiftUI

class MainLessonsHostingController: UIHostingController<MainView<DefaultMainLessonsViewModel>> {
    
    override init(rootView: MainView<DefaultMainLessonsViewModel>) {
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct MainView<T : MainLessonsViewModel> : View {
    
    //MARK: - Properties -
    
    @ObservedObject var viewModel: T
    
    //MARK: - Body -
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(viewModel.lessonsData.enumerated()), id: \.offset) { index, lesson in
                    NavigationLink(destination: LessonDetailsViewControllerWrapper(lesson: lesson,
                                                                                   nextLessons: viewModel.filterNextLessonsArray(index: index))) {
                        LessonCellView(imageURL: lesson.thumbnail,
                                       title: lesson.name)
                    }
                    .foregroundColor(Color.blue)
                }
            }
            .navigationTitle("Lessons")
        }
        .onAppear {
            viewModel.viewAppeared()
        }
    }
    
}

