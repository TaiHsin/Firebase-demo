//
//  ViewController.swift
//  Firebase-practice
//
//  Created by TaiHsinLee on 2018/9/3.
//  Copyright © 2018年 TaiHsinLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var articleTitle: UITextField!
    @IBOutlet weak var articleContent: UITextView!
    @IBOutlet weak var postArticleButton: UIButton!
    @IBOutlet weak var friendsEmail: UITextField!
    @IBOutlet weak var friendsArticles: UIButton!
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBAction func switchTag(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            getTagData(byTag: "表特")
        case 1:
            getTagData(byTag: "八卦")
        case 2:
            getTagData(byTag: "就可")
        case 3:
            getTagData(byTag: "生活")
        default: break
        }
    }
    
    @IBAction func postArticle(_ sender: Any) {
        guard let title = articleTitle.text else { return }
        guard let content = articleContent.text else { return }
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            postArticle(title: title, content: content, tag: "表特", time: "20180904")
        case 1:
            postArticle(title: title, content: content, tag: "八卦", time: "20180904")
        case 2:
            postArticle(title: title, content: content, tag: "就可", time: "20180904")
        case 3:
            postArticle(title: title, content: content, tag: "生活", time: "20180904")
        default: break
        }
        
        // Reset article data
    
        articleTitle.text = ""
        articleContent.text = ""
    }
    
    @IBAction func addFriends(_ sender: Any) {
    }
    
    @IBAction func showFriendsArticles(_ sender: Any) {
    }
    
    @IBAction func createUser(_ sender: Any) {
        createUser()
        
        // Reset user data
        
        userName.text = ""
        userEmail.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
//        searchUser(byEmail: "peterlee0466@gmail.com")
//        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cornerRadius()
    }
    
    func cornerRadius() {
        createButton.layer.cornerRadius = 5
        articleContent.layer.cornerRadius = 5
        postArticleButton.layer.cornerRadius = 5
        addFriendButton.layer.cornerRadius = 5
        friendsArticles.layer.cornerRadius = 5
    }
    
    // MARK: - Create user data
    
    func createUser() {
        let uid = ref.child("users").childByAutoId().key
        self.ref.child("users").child(uid).setValue(["email": userEmail.text , "name": userName.text])
        
        // Save userdata to singleton
        
        UserDefaults.standard.set(uid, forKey: "userId")
        UserDefaults.standard.set(userName.text, forKey: "userName")
        UserDefaults.standard.set(userEmail.text, forKey: "userEmail")
    }
    
    // MARK: - Search tag articles
    
    func getTagData(byTag tag: String) {
        ref.child("posts").queryOrdered(byChild: "tag").queryEqual(toValue: tag).observeSingleEvent(of: .value) { (snapshot) in
        
            let value = snapshot.value as? NSDictionary
            print(value)
        }
    }
    
    // MARK: - Read data at certain child
    
    func readData() {
        ref.child("users").child("Nia").observeSingleEvent(of: .value) { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let userName = value?["name"] as? String
            print(userName!)
            let userEmail = value?["email"] as? String
            print(userEmail!)
        }
    }
    
    // MARK: - Search data by some value or child key
    
    func searchUser(byEmail email: String) {
        ref.child("posts").queryOrdered(byChild: "email").queryEqual(toValue: true).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            //            guard let valueKey = value?.allKeys[0] as? String else { return }
            //            let userValue = value?[valueKey] as? NSDictionary
            //            let dataValue = userValue!["name"]! as? String
            print(value)
        }
    }
    
    // MARK: - Use update to post new article
    
    func postArticle(title title: String, content content: String, tag tag: String, time time: String) {
        let key = ref.child("posts").childByAutoId().key
        guard let userId = UserManager.shared.getUserId() else { return }
        guard let userName = UserManager.shared.getUserName() else { return }
        
        let createdTime = ServerValue.timestamp()
//        print(createdTime)
        let post = ["title": title,
                    "content": content,
                    "tag": tag,
                    "author_id": userId,
                    "author_name": userName,
                    "created_time": time ] as [String : Any]
        let postUpdates = ["/posts/\(key)": post]
        
        ref.updateChildValues(postUpdates)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

