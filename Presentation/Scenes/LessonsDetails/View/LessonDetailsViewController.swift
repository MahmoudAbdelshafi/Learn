//
//  LessonDetailsViewController.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import UIKit
import SwiftUI
import AVFoundation
import AVKit

struct LessonDetailsViewControllerWrapper: UIViewControllerRepresentable {
    
    let lesson: Lesson
    
    class Coordinator {
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = LessonsScenesDiContainer.makeLessonDetailsViewController(lesson: lesson)
        context.coordinator.parentObserver = viewController.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.title = vc.title
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems 
        })
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController,
                                context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
}

class LessonDetailsViewController: UIViewController {
    
    //MARK: - Private Properties -
    
    private var viewModel: LessonDetailsViewModel

    //MARK: - UIProperties -
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var navigationRightItemStackView = UIStackView()
    private let btnDownloadIcon = UIButton.init(type: .custom)
    private let btnDownload = UIButton.init(type: .custom)
    private let btnCancel = UIButton.init(type: .custom)
    private var rightBarButton = UIBarButtonItem()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.backgroundColor = .gray
        progressView.progressTintColor = .systemBlue
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 2
        progressView.sizeToFit()
        return progressView
    }()
    
    private lazy var videoButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didClickVideoThumbnailButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var videoThumbnailImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var playerIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "play.fill")
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28.0)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.numberOfLines = 0
        return label
    }()
    
    //MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupUI()
        fillData()
        viewModel.viewDidLoad()
    }
    
    //MARK: - Init -
    
    init(viewModel: LessonDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private Functions -

extension LessonDetailsViewController: AVPlayerViewControllerDelegate {
    
    @objc private func didClickVideoThumbnailButton(_ sender: Any) {
        playVideo()
    }
    
    @objc private func downloadButtonPressed(_ sender: Any) {
        viewModel.dowloadVideo(videoURL: viewModel.lesson.videoURL)
        showDownloadProgressView()
    }
    
    @objc private func cancelButtonPressed(_ sender: Any) {
        viewModel.cancelDownLoad()
        showDownloadBtn()
    }
    
    private func setupUI() {
        contentView.addSubview(videoThumbnailImg)
        contentView.addSubview(playerIconImage)
        contentView.addSubview(videoButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        setupScrollView()
        setupConstraints()
        setupNavigationBarDownloadButton()
    }
    
    private func showDownloadProgressView() {
        progressView.isHidden = false
        btnCancel.isHidden = false
        btnDownload.isHidden = true
        btnDownloadIcon.isHidden = true
    }
    
    private func showDownloadBtn() {
        progressView.isHidden = true
        btnCancel.isHidden = true
        btnDownload.isHidden = false
        btnDownloadIcon.isHidden = false
    }
    
    private func setupConstraints() {
        videoThumbnailImg.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        videoThumbnailImg.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        videoThumbnailImg.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        videoThumbnailImg.heightAnchor.constraint(equalToConstant: 350).isActive = true
        videoThumbnailImg.translatesAutoresizingMaskIntoConstraints = false
        
        videoButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        videoButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        videoButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        videoButton.heightAnchor.constraint(equalTo: videoThumbnailImg.heightAnchor).isActive = true
        videoButton.translatesAutoresizingMaskIntoConstraints = false
        
        playerIconImage.centerXAnchor.constraint(equalTo: self.videoButton.centerXAnchor, constant: 0).isActive = true
        playerIconImage.centerYAnchor.constraint(equalTo: self.videoButton.centerYAnchor, constant: 0).isActive = true
        playerIconImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
        playerIconImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        playerIconImage.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.topAnchor.constraint(equalTo: self.videoButton.bottomAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16).isActive = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -24).isActive = true
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    private func setupNavigationBarDownloadButton() {
        btnDownload.setTitle("Download", for: .normal)
        btnDownload.setTitleColor(.systemBlue, for: .normal)
        btnDownload.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(.systemBlue, for: .normal)
        btnCancel.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        btnDownloadIcon.setImage(UIImage(systemName: "icloud.and.arrow.down"), for: .normal)
        btnDownloadIcon.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
        progressView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        navigationRightItemStackView = UIStackView.init(arrangedSubviews: [ btnDownloadIcon, btnDownload, btnCancel, progressView ])
        progressView.isHidden = true
        btnCancel.isHidden = true
        navigationRightItemStackView.distribution = .equalSpacing
        navigationRightItemStackView.axis = .horizontal
        navigationRightItemStackView.alignment = .center
        navigationRightItemStackView.spacing = 3
        
        rightBarButton = UIBarButtonItem(customView: navigationRightItemStackView)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func playVideo() {
        var url: URL?
        guard let videoURL = URL(string: viewModel.lesson.videoURL) else { return }
        url = videoURL
        if viewModel.lessonVideoLocalURL != nil {
            url = viewModel.lessonVideoLocalURL
        }
        player = AVPlayer(url: url!)
        let playervc = AVPlayerViewController()
        playervc.delegate = self
        playervc.player = player
        self.present(playervc, animated: true) {
            playervc.player!.play()
        }
    }
    
    private func fillData() {
        videoThumbnailImg.downloadImage(withUrl: viewModel.lesson.thumbnail)
        titleLabel.text = viewModel.lesson.name
        descriptionLabel.text = viewModel.lesson.description
    }
    
    private func bind() {
        viewModel.downLoadProgressData.sink { _ in
        } receiveValue: { [weak self] progressData in
            let calculatedProgress = Float(progressData.totalBytesWritten) / Float(progressData.totalBytesExpectedToWrite)
            self?.progressView.progress = calculatedProgress
            if progressData.totalBytesWritten == progressData.totalBytesExpectedToWrite {
                self?.rightBarButton.isHidden = true
            }
        }.store(in: &viewModel.cancellableBag)
        
        viewModel.isVideoDownloadedBefore.sink { bool in
            if bool {
                self.rightBarButton.isHidden = true
            }
        }.store(in: &viewModel.cancellableBag)
    }
    
}
