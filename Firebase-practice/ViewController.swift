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
    var tag: String?
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var articleTitle: UITextField!
    @IBOutlet weak var articleContent: UITextView!
    @IBOutlet weak var postArticleButton: UIButton!
    @IBOutlet weak var friendsEmailText: UITextField!
    @IBOutlet weak var friendsArticles: UIButton!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var tagArticles: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        
        
//        getTagData(byTag: "test")
        //        searchUser(byEmail: "peterlee0466@gmail.com")
        //        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cornerRadius()
    }
    
    @IBAction func createUser(_ sender: Any) {
        createUser()
        
        // Reset user data
        
        userName.text = ""
        userEmail.text = ""
    }
    
    @IBAction func getTagArticles(_ sender: UISegmentedControl) {
        tag = sender.titleForSegment(at: sender.selectedSegmentIndex)
        guard let tag = tag else { return }
        
        getTagData(byTag: tag)
    }
    
    @IBAction func postArticle(_ sender: Any) {
        guard let title = articleTitle.text else { return }
        guard let content = articleContent.text else { return }
        guard let tag = tag else { return }
        
        postArticle(title: title, content: content, tag: tag, time: "20180904")
        
         // Reset article data
    
        articleTitle.text = ""
        articleContent.text = ""
    }
    
    @IBAction func addFriends(_ sender: Any) {
        guard let email = friendsEmailText.text else { return }
        guard let userId = UserManager.shared.getUserId() else { return }
        guard let userEmail = UserManager.shared.getUserEmail() else { return }
        
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
                        print(value)
            guard value != nil else {
                print("No such user!")
                return
            }
            
            guard let valueKey = value?.allKeys[0] as? String else {
                return
            }
            let addContext = [userId: "待接受"] as [String : Any]
            let updates = ["/users/\(valueKey)/contact": addContext]
            
            self.ref.updateChildValues(updates)
            self.ref.updateChildValues(["/users/\(userId)/contact/\(valueKey)": "待邀請"])
            
            //            guard let valueKey = value?.allKeys[0] as? String else { return }
            //            let userValue = value?[valueKey] as? NSDictionary
            //            let dataValue = userValue!["name"]! as? String
        }
    }
    
    @IBAction func showFriendsArticles(_ sender: Any) {
    }
    
    @IBAction func getFriendsTagArticles(_ sender: Any) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//
//        case 1:
//
//        case 2:
//
//        case 3:
//            
//        default: break
//        }
    }
    
    func cornerRadius() {
        createButton.layer.cornerRadius = 5
        articleContent.layer.cornerRadius = 5
        postArticleButton.layer.cornerRadius = 5
        addFriendButton.layer.cornerRadius = 5
        friendsArticles.layer.cornerRadius = 5
        tagArticles.layer.cornerRadius = 5
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
        ref.child("posts").queryOrdered(byChild: "article_tag").queryEqual(toValue: tag).observeSingleEvent(of: .value) { (snapshot) in
        
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
 
    }
    
    // MARK: - Use update to post new article
    
    func postArticle(title: String, content: String, tag: String, time: String) {
        let key = ref.child("posts").childByAutoId().key
        guard let userId = UserManager.shared.getUserId() else { return }
        guard let userName = UserManager.shared.getUserName() else { return }
        
        let createdTime = ServerValue.timestamp()

        let post = ["article_id": key,
                    "article_title": title,
                    "article_content": content,
                    "article_tag": tag,
                    "author_id": userId,
                    "author_name": userName,
                    "created_time": time ] as [String : Any]
        let postUpdates = ["/posts/\(key)": post]
        
        ref.updateChildValues(postUpdates)
    }
    
//    func getTime() {
//        let date = Date()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/* Todo:
 wait for discuss
 1. tage format
 2. add friend function
 3. time format
 
 - Add friends
 - get friends all articles
 - get friends specific tag's articles
 
 - Improve UI layout
 - Placeholder in text view
 - Add showAlert with empty input
*/




