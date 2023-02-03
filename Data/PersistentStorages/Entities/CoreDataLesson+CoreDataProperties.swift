//
//  CoreDataLesson+CoreDataProperties.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 03/02/2023.
//
//

import Foundation
import CoreData

extension CoreDataLesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataLesson> {
        return NSFetchRequest<CoreDataLesson>(entityName: "CoreDataLesson")
    }
    
    @objc public class func insertCoreDataLessonObject(context: NSManagedObjectContext) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: "CoreDataLesson", into: context)
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var lessonDescription: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var videoURL: String?

}

extension CoreDataLesson : Identifiable {

}
// MARK: - DTO -

extension CoreDataLesson {
    
    static func toLessonsDTO(_ coreDataLessons: [CoreDataLesson]) -> LessonsDTO {
        var dtos = [LessonDTO]()
        for lesson in coreDataLessons {
            let dto = LessonDTO(id: Int(lesson.id),
                                name: lesson.name,
                                description: lesson.lessonDescription,
                                thumbnail: lesson.thumbnail,
                                videoURL: lesson.videoURL)
            dtos.append(dto)
        }
        return LessonsDTO(lessons: dtos)
        
    }
}

//MARK: - To CoreDataLesson -

extension LessonDTO {
    
     func toCoreDataLessonEntityForInserting(context: NSManagedObjectContext) -> CoreDataLesson? {
        if let coreDataLessonEntity = CoreDataLesson.insertCoreDataLessonObject(context: context) as? CoreDataLesson {
            coreDataLessonEntity.id =  Int16(self.id ?? 0)
            coreDataLessonEntity.name = self.name
            coreDataLessonEntity.lessonDescription = self.description
            coreDataLessonEntity.thumbnail = self.thumbnail
            coreDataLessonEntity.videoURL = self.videoURL
            return coreDataLessonEntity
        }
       return nil
    }
    
}
