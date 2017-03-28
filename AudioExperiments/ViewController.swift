//
//  ViewController.swift
//  AudioExperiments
//
//  Created by Andrew Sowers on 3/20/17.
//  Copyright © 2017 SkyBuds. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

class ViewController: UITableViewController {

    let actions = ["schedule news", "schedule recording"]
    var player: AVPlayer?
    
    var isGrantedNotificationAccess:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.reloadData()
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
        }
        )
    }
    
    func postLocalNewsNotifciation() {
        let content = UNMutableNotificationContent()
        content.title = "News Demo"
        content.subtitle = "From Skybuds"
        content.body = "Breaking news update"
        content.categoryIdentifier = "NEWSUPDATEAVAILABLE"
        content.sound = UNNotificationSound(named: "BLE_connect04.caf")
    
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5.0,
            repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "com.skybuds.notifications.news",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func postLocalStartRecordingNotifciation() {
        let content = UNMutableNotificationContent()
        content.title = "Command Demo"
        content.subtitle = "From Skybuds"
        content.body = "Record a command"
        content.categoryIdentifier = "STARTRECORDING"
        content.sound = UNNotificationSound(named: "BLE_connect04.caf")
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5.0,
            repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "com.skybuds.notifications.start",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    //MARK: - TableView -
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        let action = actions[indexPath.row]
        
        switch action {
        case "schedule news":
            self.postLocalNewsNotifciation()
        case "schedule recording":
            self.postLocalStartRecordingNotifciation()
        default:
            let alert = UIAlertController(title: "Not found", message: "there was no function found called \(action)", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = actions[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

}

