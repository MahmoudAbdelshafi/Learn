//
//  MainViewUITests.swift
//  MainViewUITests
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import XCTest

final class MainViewUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    func testMainView_NavigationTitle_isEnabled() throws {
        let navigationTitle = "Lessons"
        app.launch()
        let lessonsStaticText = app.navigationBars[navigationTitle].staticTexts[navigationTitle]
        
        XCTAssert(lessonsStaticText.exists)
        XCTAssertEqual(lessonsStaticText.label, navigationTitle)
    }

    func testMainView_ListIsEnabled_AND_HasCorrectItemsNumber() throws {
        app.launch()
        let lessonsList = app.collectionViews["LessonsList"]
        XCTAssertTrue(lessonsList.waitForExistence(timeout: 5), "Lessons List should be visable")

        let cellPredicate = NSPredicate(format: "identifier CONTAINS 'cell_'")
        let buttonItems = lessonsList.buttons.containing(cellPredicate)
        
        XCTAssertTrue(buttonItems.staticTexts["The Key To Success In iPhone Photography"].exists)
        XCTAssertEqual(buttonItems.count, 9, "Item in the List should match 9")
    }

}
