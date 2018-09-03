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
}


