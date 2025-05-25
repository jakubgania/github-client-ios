//
//  KeychainManager.swift
//  GitHubClient
//
//  Created by Jakub on 25.05.25.
//

import Foundation

class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "Jakub.GitHubClient"
    private let account = "github_access_token"
    
    private init() {}
    
    func saveToken(_ token: String) -> Bool {
        guard let tokenData = token.data(using: .utf8) else {
            print("Failed to convert token to data")
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: tokenData
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("Token saved successfully")
            return true
        } else {
            print("Failed to save token: \(status)")
            return false
        }
    }
    
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data, let token = String(data: data, encoding: .utf8) {
            return token
        } else {
            print("Failed to retrieve token: \(status)")
            return nil
        }
    }
    
    func deleteToken() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess || status == errSecItemNotFound {
            print("Token deleted successfully or not found")
            return true
        } else {
            print("Failed to delete token: \(status)")
            return false
        }
    }
}
