//
//  DownloadManager.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 03/02/2023.
//

import Foundation
import Combine

final class DownloadManager: NSObject {
    
    private lazy var urlSession = URLSession(configuration: .default,
                                             delegate: self,
                                             delegateQueue: nil)
    
//    var downloadTask: URLSessionDownloadTask?
    var downloadingVideos: [ URL : DownloadVideoModel ] = [:]
    var downloadStreamProgress = PassthroughSubject<DownloadProgressData, Never>()
    let pass = PassthroughSubject<[Lesson], Never>()
    
    static let shared = DownloadManager()
    
    private override init() {}
    
    func localFilePath(for url: URL) -> URL? {
        getLocalFilePath(for: url)
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        debugPrint("Task has been resumed")
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        debugPrint("Downloaded")
        downloadStreamProgress.send(completion: .finished)
        guard let sourceUrl = downloadTask.originalRequest?.url else {
            return
        }
        guard let destinationURL = localFilePath(for: sourceUrl) else { return }
        debugPrint(destinationURL)
        do {
            let _ = try
            FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
            try FileManager.default.moveItem(at: location, to: destinationURL)
            debugPrint(destinationURL)
            debugPrint(location)
        } catch {
            debugPrint ("file error: \(error)")
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        let download = DownloadProgressData(session: session,
                                            downloadTask: downloadTask,
                                            bytesWritten: bytesWritten,
                                            totalBytesWritten: totalBytesWritten,
                                            totalBytesExpectedToWrite: totalBytesExpectedToWrite)
//        if downloadTask == self.downloadTask {
            DispatchQueue.main.async { [weak self] in
                self?.downloadStreamProgress.send(download)
                guard let url = downloadTask.response?.url else { return }
                self?.downloadingVideos[url]?.progressStreem.send(download)
//            }
        }
    }
    
     func download(with url: String) {
        guard let url = URL(string: url) else { return }
        let destinationURL = localFilePath(for: url)
        if isFileExist(destinationPath: destinationURL!.path) {
            debugPrint("video is available")
        } else {
            if !downloadingVideos.contains(where: { $0.key.absoluteURL == url}) {
                let downloadTask = urlSession.downloadTask(with: url)
                downloadTask.resume()
                let downloadModel = DownloadVideoModel(sessionTask: downloadTask)
                self.downloadingVideos.updateValue(downloadModel, forKey: url)
            }
        }
    }
    
    func isFileExist(destinationPath: String) -> Bool {
        return FileManager.default.fileExists(atPath: destinationPath)
    }
    
     func getLocalFilePath(for url: URL) -> URL? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
}

struct DownloadVideoModel {
    var isDownloading: Bool = false
    var progress: Float = 0.0
    var progressStreem = PassthroughSubject<DownloadProgressData, Never>()
    var sessionTask: URLSessionDownloadTask?
}