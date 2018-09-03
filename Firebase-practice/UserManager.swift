//
//  UserManager.swift
//  Firebase-practice
//
//  Created by TaiHsinLee on 2018/9/3.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    func getUserId() -> String? {
        let userId = UserDefaults.standard.string(forKey: "userId")
        return userId
    }
    
    func getUserName() -> String? {
        let userName = UserDefaults.standard.string(forKey: "userName")
        return userName
    }
    
    func getUserEmail() -> String? {
        let userEmail = UserDefaults.standard.string(forKey: "userEmail")
        return userEmail
    }
}


