
import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        clearToken()
        cleanCookies()
        clearProfileData()
    }
    
    // 1. Очистка токена авторизации
    private func clearToken() {
        OAuth2TokenStorage().token = nil
    }
    
    // 2. Очистка куков из браузера
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    // 3. Очистка данных профиля, аватарки и списка изображений
    private func clearProfileData() {
        ProfileService.shared.profile = nil
        ProfileImageService.shared.clearAvatar()
        ImagesListService.shared.clearPhotos()
    }
}
