import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10), "WebView не загрузился")
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поле логина не найдено")
        loginTextField.tap()
        loginTextField.typeText("test@example.com")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10), "Поле пароля не найдено")
        passwordTextField.tap()
        passwordTextField.typeText("password123")
        webView.swipeUp()
        
        let loginButton = webView.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10), "Кнопка логина не найдена")
        loginButton.tap()
        
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15), "Лента не загрузилась")
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Лента не загрузилась")
        
        firstCell.swipeUp()
        
        // Лайк / дизлайк
        let secondCell = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5), "Вторая ячейка не найдена")
        
        let likeButton = secondCell.buttons["like button off"]
        if likeButton.exists {
            likeButton.tap()
            
            let likedButton = secondCell.buttons["like button on"]
            XCTAssertTrue(likedButton.waitForExistence(timeout: 3), "Кнопка после лайка не появилась")
            likedButton.tap()
        } else {
            // Если уже лайкнуто
            let likedButton = secondCell.buttons["like button on"]
            likedButton.tap()
            
            let unlikedButton = secondCell.buttons["like button off"]
            XCTAssertTrue(unlikedButton.waitForExistence(timeout: 3), "Кнопка после дизлайка не появилась")
            unlikedButton.tap()
        }
        
        // Открытие картинки
        secondCell.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5), "Картинка не открылась")
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["nav back button white"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка назад не найдена")
        backButton.tap()
    }
    
    func testProfile() throws {
        // 1. Подождать, пока откроется экран ленты
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Лента не загрузилась")
        
        // 2. Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // 3. Проверить персональные данные
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        
        // 4. Выйти из профиля
        app.buttons["logout button"].tap()
        app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
        sleep(2)
        // 5. Проверить, что открылся экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка авторизации не появилась после выхода")
    }
}
