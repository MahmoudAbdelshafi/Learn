//
//  LessonsDetailsViewModel.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import Foundation
import Combine

protocol LessonDetailsViewModelOutput {
    
}

protocol LessonDetailsViewModelInput {
    func dowloadVideo(videoURL: String)
    func viewDidLoad()
    func cancelDownLoad()
    var lesson: Lesson { get }
    var lessonVideoLocalURL: URL? { get }
    var downLoadProgressData: PassthroughSubject<DownloadProgressData,Never> { get }
    var cancellableBag: Set<AnyCancellable> { get set }
    var isVideoDownloadedBefore: PassthroughSubject<Bool,Never>  {get }
}

protocol LessonDetailsViewModel: LessonDetailsViewModelOutput, LessonDetailsViewModelInput { }

final class DefaultLessonDetailsViewModel: LessonDetailsViewModel {
    
    //MARK: - Private Properties -
    
    private let downloadLessonVideoUseCase: DownloadLessonVideoUseCase
    
    //MARK: - Properties -
    
    let lesson: Lesson
    var lessonVideoLocalURL: URL?
    var cancellableBag = Set<AnyCancellable>()
    var downLoadProgressData = PassthroughSubject<DownloadProgressData, Never>()
    var isVideoDownloadedBefore = PassthroughSubject<Bool, Never>()
    var downloadTask: URLSessionDownloadTask?
    
    //MARK: - Init -
    
    init(downloadLessonVideoUseCase: DownloadLessonVideoUseCase,
         lesson: Lesson) {
        self.downloadLessonVideoUseCase = downloadLessonVideoUseCase
        self.lesson = lesson
        observeOnDownloadProgress()
    }
    
}

//MARK: - Input -

extension DefaultLessonDetailsViewModel {
    
    func dowloadVideo(videoURL: String) {
        if !isVideoExist(videoURL: videoURL) {
            downloadLessonVideoUseCase.execute(videoURL: videoURL)
        }
    }
    
    func cancelDownLoad() {
        downloadLessonVideoUseCase.cancelDownLoad()
    }
    
    
    func observeOnDownloadProgress() {
        downloadLessonVideoUseCase.getDownloadProgress().sink { _ in
        } receiveValue: { downloadProgressData in
            self.downLoadProgressData.send(downloadProgressData)
        }.store(in: &cancellableBag)
    }
    
    func viewDidLoad() {
        isVideoDownloadedBefore.send(isVideoExist(videoURL: lesson.videoURL))
    }
    
}

//MARK: - Private functions -

extension DefaultLessonDetailsViewModel {
    
    private func isVideoExist(videoURL: String) -> Bool {
        guard let url = URL(string: videoURL) else { return false }
        guard let destinationURL = downloadLessonVideoUseCase.localFilePath(for: url) else { return false}
        let isVideoExist = downloadLessonVideoUseCase.isVideoExist(destinationPath: destinationURL.path)
        self.lessonVideoLocalURL = isVideoExist ? destinationURL : nil
        return isVideoExist
    }
}
