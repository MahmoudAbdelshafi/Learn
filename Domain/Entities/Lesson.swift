//
//  Lesson.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import Foundation

struct Lesson: Identifiable {
    let id: Int
    let name, description: String
    let thumbnail: String
    let videoURL: String
}
