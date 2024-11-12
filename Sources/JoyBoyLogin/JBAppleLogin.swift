//
//  JBAppleManager.swift
//  SwiftBasicTopics
//
//  Created by Prakash Skyraan on 07/11/24.
//

import Foundation
import AuthenticationServices
import UIKit
import Security

@available(iOS 14.0, *)
public class JBAppleManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    static let shared = JBAppleManager()
    let keyChain = KeychainManager.shared
    
    // Completion handler for handling sign-in results
    var onSignInCompletion: ((AuthInfo?, Error?) -> Void)?
    
    // MARK: - Start Apple Sign-In
   public func startAppleSignIn(completion: @escaping (AuthInfo?, Error?) -> Void) {
        self.onSignInCompletion = completion
        
        // Create the request for Apple ID
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        // Set up the authorization controller
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    
    public var authContinuation: CheckedContinuation<AuthInfo, Error>?
    
    public func startAppleSignInAsyncThrows() async throws -> AuthInfo {
        return try await withCheckedThrowingContinuation { continuation in
            // Create the request for Apple ID
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            // Set up the authorization controller
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
            // Store a reference to the continuation
            self.authContinuation = continuation
        }
    }
    
    // MARK: - ASAuthorizationControllerDelegate Methods
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Extract user details from credential
            var userId = appleIDCredential.user
            var givenName = "\(appleIDCredential.fullName?.givenName ?? "")"
            var familyName = "\(appleIDCredential.fullName?.familyName ?? "")"
            var fullName = givenName+familyName
            var email = appleIDCredential.email ?? ""
            
            //                        if UserDefaults.standard.string(forKey: "givenName") ?? "" == "" && UserDefaults.standard.string(forKey: "familyName") ?? "" == "" && UserDefaults.standard.string(forKey: "fullName") ?? "" == "" && UserDefaults.standard.string(forKey: "email") ?? "" == ""{
            //                            UserDefaults.standard.set(givenName, forKey: "givenName")
            //                            UserDefaults.standard.set(familyName, forKey: "familyName")
            //                            UserDefaults.standard.set(fullName, forKey: "fullName")
            //                            UserDefaults.standard.set(email, forKey: "email")
            //                            UserDefaults.standard.set(userId, forKey: "userId")
            //                            print("""
            //                                givenName = \(givenName)
            //                                familyName = \(familyName)
            //                                name : \(fullName)
            //                                email : \(email)
            //                                userid : \(userId)
            //                                """)
            //                            print("Check")
            //                            let authInfo = AuthInfo(
            //                                isDataAvail: true,
            //                                name: fullName,
            //                                email: email,
            //                                familyName: familyName,
            //                                givenName: givenName,
            //                                appleOAuthId: userId
            //                            )
            //
            //                                let dic : [String:Any] = [
            //                                    "givenName":givenName,
            //                                    "familyName":familyName,
            //                                    "fullName":fullName,
            //                                    "email":email,
            //                                    "userId":userId
            //                                ]
            //                                do{
            //
            //                                                    print("""
            //                                                        givenName = \(givenName)
            //                                                        familyName = \(familyName)
            //                                                        name : \(fullName)
            //                                                        email : \(email)
            //                                                        userid : \(userId)
            //                                                        """)
            //                                                    print("Check")
            //                                    try keyChain.storeDictionary(dic, forAccount: "AppleLogIn@Details.com")
            //                                    let authInfo = AuthInfo(
            //                                        isDataAvail: true,
            //                                        name: fullName,
            //                                        email: email,
            //                                        familyName: familyName,
            //                                        givenName: givenName,
            //                                        appleOAuthId: userId
            //                                    )
            //                                    UserDefaults.standard.set(userId, forKey: "appleUserID")
            //                                    // Return the result through the completion handler
            //                                    authContinuation?.resume(returning: authInfo)
            //                                    onSignInCompletion?(authInfo, nil)
            //
            //                                }catch let error{
            //                                    print(error.localizedDescription)
            //                                }
            //
            //                        }else{
            //                            userId = UserDefaults.standard.string(forKey: "userId") ?? ""
            //                            email = UserDefaults.standard.string(forKey: "email") ?? ""
            //                            fullName = UserDefaults.standard.string(forKey: "fullName") ?? ""
            //                            givenName = UserDefaults.standard.string(forKey: "givenName") ?? ""
            //                            familyName = UserDefaults.standard.string(forKey: "familyName") ?? ""
            //                            print("""
            //                                givenName = \(givenName)
            //                                familyName = \(familyName)
            //                                name : \(fullName)
            //                                email : \(email)
            //                                userid : \(userId)
            //                                """)
            //                            print("Check")
            //                            let authInfo = AuthInfo(
            //                                isDataAvail: true,
            //                                name: fullName,
            //                                email: email,
            //                                familyName: familyName,
            //                                givenName: givenName,
            //                                appleOAuthId: userId
            //                            )
            //
            //                            // Return the result through the completion handler
            //                            authContinuation?.resume(returning: authInfo)
            //                            onSignInCompletion?(authInfo, nil)
            //                        }
            
            if givenName != "" && familyName != "" && fullName != "" && userId != "" {
                let dic : [String:Any] = [
                    "givenName":givenName,
                    "familyName":familyName,
                    "fullName":fullName,
                    "email":email,
                    "userId":userId
                ]
                UserDefaults.standard.set(givenName, forKey: "givenName")
                UserDefaults.standard.set(familyName, forKey: "familyName")
                UserDefaults.standard.set(fullName, forKey: "fullName")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(userId, forKey: "userId")
                do{
                    
                    print("""
                                        givenName = \(givenName)
                                        familyName = \(familyName)
                                        name : \(fullName)
                                        email : \(email)
                                        userid : \(userId)
                                        """)
                    print("Check")
                    try keyChain.storeDictionary(dic, forAccount: "AppleLogIn@Details.com")
                    let authInfo = AuthInfo(
                        isDataAvail: true,
                        name: fullName,
                        email: email,
                        familyName: familyName,
                        givenName: givenName,
                        appleOAuthId: userId
                    )
                    UserDefaults.standard.set(userId, forKey: "appleUserID")
                    // Return the result through the completion handler
                    authContinuation?.resume(returning: authInfo)
                    onSignInCompletion?(authInfo, nil)
                    
                }catch let error{
                    print(error.localizedDescription)
                }
            }else{
                if UserDefaults.standard.string(forKey: "givenName") ?? "" == "" && UserDefaults.standard.string(forKey: "familyName") ?? "" == "" && UserDefaults.standard.string(forKey: "fullName") ?? "" == "" && UserDefaults.standard.string(forKey: "email") ?? "" == ""{
                    do{
                        let data = try keyChain.retrieveDictionary(forAccount: "AppleLogIn@Details.com")
                        givenName = data?["givenName"] as? String ?? ""
                        fullName = data?["fullName"] as? String ?? ""
                        familyName = data?["familyName"] as? String ?? ""
                        email = data?["email"] as? String ?? ""
                        userId = data?["userId"] as? String ?? ""
                        
                        print("""
                                            givenName = \(givenName)
                                            familyName = \(familyName)
                                            name : \(fullName)
                                            email : \(email)
                                            userid : \(userId)
                                            """)
                        print("Check")
                        UserDefaults.standard.set(userId, forKey: "appleUserID")
                        let authInfo = AuthInfo(
                            isDataAvail: true,
                            name: fullName,
                            email: email,
                            familyName: familyName,
                            givenName: givenName,
                            appleOAuthId: userId
                        )
                        // Return the result through the completion handler
                        authContinuation?.resume(returning: authInfo)
                        onSignInCompletion?(authInfo, nil)
                    }catch let error{
                        print(error.localizedDescription)
                    }
                }else{
                    userId = UserDefaults.standard.string(forKey: "userId") ?? ""
                    email = UserDefaults.standard.string(forKey: "email") ?? ""
                    fullName = UserDefaults.standard.string(forKey: "fullName") ?? ""
                    givenName = UserDefaults.standard.string(forKey: "givenName") ?? ""
                    familyName = UserDefaults.standard.string(forKey: "familyName") ?? ""
                    print("""
                                                    givenName = \(givenName)
                                                    familyName = \(familyName)
                                                    name : \(fullName)
                                                    email : \(email)
                                                    userid : \(userId)
                                                    """)
                    print("Check")
                    let authInfo = AuthInfo(
                        isDataAvail: true,
                        name: fullName,
                        email: email,
                        familyName: familyName,
                        givenName: givenName,
                        appleOAuthId: userId
                    )
                    
                    // Return the result through the completion handler
                    authContinuation?.resume(returning: authInfo)
                    onSignInCompletion?(authInfo, nil)
                }
            }
            
        } else {
            // Handle missing credentials
            authContinuation?.resume(throwing: (any Error).self as! Error)
            onSignInCompletion?(nil, NSError(domain: "AppleSignIn", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Credentials not found"]))
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Return the error through the completion handler
        authContinuation?.resume(throwing: error)
        onSignInCompletion?(nil, error)
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
    // Function to perform "logout" or revoke user authorization
    public func appleLogout(completion: @escaping (Bool) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        // Revoke the stored credential using the user identifier
        if let userIdentifier = UserDefaults.standard.string(forKey: "appleUserID") {
            appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
                DispatchQueue.main.async {
                    switch credentialState {
                    case .authorized:
                        // Still authorized, may not be signed out completely
                        completion(false)
                    case .revoked:
                        // User's Apple ID credential is revoked
                        UserDefaults.standard.removeObject(forKey: "appleUserID")
                        completion(true)
                    case .notFound:
                        // Credential not found, user is signed out
                        UserDefaults.standard.removeObject(forKey: "appleUserID")
                        completion(true)
                    default:
                        completion(false)
                    }
                }
            }
        } else {
            completion(false)
        }
    }
}


public class KeychainManager {
    
    static let shared = KeychainManager()
    
    private init(){}
    
    enum KeychainError: Error {
        case duplicateItem
        case unknown(OSStatus)
    }
    
    // Store dictionary in Keychain
    public func storeDictionary(_ dictionary: [String: Any], forAccount account: String) throws {
        // Convert the dictionary into Data using JSON serialization
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Add the item to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // If item exists, update it
            let updateQuery: [String: Any] = [kSecValueData as String: data]
            let searchQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account
            ]
            let updateStatus = SecItemUpdate(searchQuery as CFDictionary, updateQuery as CFDictionary)
            if updateStatus != errSecSuccess {
                throw KeychainError.unknown(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    // Function to retrieve a dictionary from Keychain
    public  func retrieveDictionary(forAccount account: String) throws -> [String: Any]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // Check if the retrieval was successful
        if status == errSecSuccess {
            if let data = item as? Data {
                // Deserialize data to a dictionary
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    return dictionary
                } else {
                    throw KeychainError.unknown(.min)
                }
            } else {
                throw KeychainError.unknown(.min)
            }
        } else if status == errSecItemNotFound {
            throw KeychainError.unknown(status)
        } else {
            throw KeychainError.unknown(status)
        }
    }
    
}

import Foundation

@available(iOS 14.0, *)
public class AuthInfo:ObservableObject{
    
    //MARK: Common
    let isDataAvail : Bool
    let name: String?
    let email: String?
    let imageURL: String?
    let userID: String?
    
    //MARK: Google
    let familyName: String?
    let givenName: String?
    let refreshToken: String?
    let accessToken: String?
    let idToken: String?
    
    //MARK: Facebook
    let birthday: String?
    let gender: String?
    let location: String?
    let hometown: String?
    let friendsCount: String?
    let relationshipStatus: String?
    let profileLink: String?
    
    //MARK: Apple
    let appleOAuthId: String?
    
    //    print("Name: \(userName)")
    //    print("Email: \(userEmail)")
    //    print("Birthday: \(birthday)")
    //    print("Gender: \(gender)")
    //    print("Location: \(location)")
    //    print("Hometown: \(hometown)")
    //    print("Friends Count: \(friendsCount)")
    //    print("Relationship Status: \(relationshipStatus)")
    //    print("Profile Link: \(profileLink)")
    //    print("Picture URL: \(pictureURL)")
    
    init(isDataAvail: Bool,name: String = "", email: String = "", familyName: String = "", givenName: String = "", imageURL: String = "", userID: String = "",
         birthday: String = "", gender: String = "", location: String = "", hometown: String = "", friendsCount: String = "", relationshipStatus: String = "", profileLink: String = "",appleOAuthId:String = "",refreshToken: String? = nil, accessToken: String? = nil, idToken: String? = nil) {
        self.isDataAvail = isDataAvail
        self.name = name
        self.email = email
        self.familyName = familyName
        self.givenName = givenName
        self.imageURL = imageURL
        self.userID = userID
        self.birthday = birthday
        self.gender = gender
        self.location = location
        self.hometown = hometown
        self.friendsCount = friendsCount
        self.relationshipStatus = relationshipStatus
        self.profileLink = profileLink
        self.appleOAuthId = appleOAuthId
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.idToken = idToken
    }
    
}

@available(iOS 14.0, *)
public class JoyBoyLogin : ObservableObject{
    //    static let google = JBGoogleManager.shared
    //    static let facebook = JBFacebookManager.shared
    public static let apple = JBAppleManager.shared
    private init(){}
}
