import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    func hideKeyboard() {
        app.tap() // Тапаем на экран, чтобы скрыть клавиатуру
        sleep(1) // Даем время для скрытия клавиатуры
    }
    
    func testAuth() throws {
        // Нажимаем кнопку "Войти"
        app.buttons["Войти"].tap()
        
        // Ищем WebView и ждем его появления
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 30), "WebView не загрузился")
        
        // Ожидаем появления поля для ввода логина
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поле для ввода логина не найдено")
        
        // Вводим логин
        loginTextField.tap()
        loginTextField.typeText("test")
        
        // Скрываем клавиатуру перед тем, как перейти к паролю
        hideKeyboard()
        
        // Прокручиваем страницу вверх, чтобы увидеть поле для пароля
        webView.swipeUp()
        
        // Ожидаем появления поля для пароля
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10), "Поле для ввода пароля не найдено")
        
        // Пытаемся кликнуть в поле пароля, чтобы он получил фокус
        passwordTextField.tap()
        
        // Вводим пароль
        passwordTextField.typeText("Iecnh25")
        
        // Нажимаем на кнопку входа
        let loginButton = webView.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10), "Кнопка входа не найдена")
        loginButton.tap()
        
        // Ожидаем загрузки ленты
        let cell = app.tables.cells.element(boundBy: 0)
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
        XCTAssertTrue(app.staticTexts["Lyubov Shabunkina"].exists)
        XCTAssertTrue(app.staticTexts["@shabunkina_l"].exists)
        
        // 4. Выйти из профиля
        app.buttons["logout button"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        sleep(2)
        // 5. Проверить, что открылся экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка авторизации не появилась после выхода")
    }
}
