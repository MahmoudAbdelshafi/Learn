//
//  LessonsDTO.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import Foundation

// MARK: - LessonsDTO -

struct LessonsDTO: Codable {
    let lessons: [LessonDTO]?
}

// MARK: - Lesson -

struct LessonDTO: Codable {
    let id: Int?
    let name, description: String?
    let thumbnail: String?
    let videoURL: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, thumbnail
        case videoURL = "video_url"
    }
}

//MARK: - LessonDTO To Domain -

extension LessonDTO {
    
    func toLessonDomain() -> Lesson {
        
        return Lesson(id: self.id ?? 0,
                      name: self.name ?? "",
                      description: self.description ?? "",
                      thumbnail: self.thumbnail ?? "",
                      videoURL: self.videoURL ?? "")
    }
}

//MARK: - LessonsDTO To Domain -

extension LessonsDTO {
    
    func toLessonDomain() -> [Lesson] {
        return self.lessons?.compactMap {$0.toLessonDomain()} ?? []
    }
}
