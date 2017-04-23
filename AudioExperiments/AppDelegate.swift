//
//  AppDelegate.swift
//  AudioExperiments
//
//  Created by Andrew Sowers on 3/20/17.
//  Copyright © 2017 SkyBuds. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications
import AEConsole
import AELog
import AVFoundation
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        AEConsole.launch(with: self)
        
        INPreferences.requestSiriAuthorization( { status in
            print(status)
        })
        
        
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                self.registerCategory()
            }
        }

        return true
    }
    
    func registerCategory() -> Void{
        
        let listenNow = UNNotificationAction(identifier: Identifiers.listen, title: "Listen now", options: [])
        let dismiss = UNNotificationAction(identifier: Identifiers.dismiss, title: "Dismiss", options: [])
        let listenNowCategory = UNNotificationCategory(identifier: Identifiers.newsUpdateAvailableCategory, actions: [listenNow, dismiss], intentIdentifiers: [], options: [])
        
        let stopNow = UNNotificationAction(identifier: Identifiers.stop, title: "Stop Recording", options: [])
        let stopRecordingCategory = UNNotificationCategory(identifier: Identifiers.stopRecordingCategory, actions: [stopNow, dismiss], intentIdentifiers: [], options: [])
        
        let startNow = UNNotificationAction(identifier: Identifiers.start, title: "Start Recording", options: [])
        let startRecordingCategory = UNNotificationCategory(identifier: Identifiers.startRecordingCategory, actions: [startNow, dismiss], intentIdentifiers: [], options: [])
        
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([listenNowCategory, stopRecordingCategory, startRecordingCategory])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        aelog("didReceive")
        switch response.actionIdentifier {
        case Identifiers.start:
            RecorderEngine.default.setupRecorder()
        case Identifiers.stop:
            RecorderEngine.default.finishRecording(success: true)
        case Identifiers.listen:
            PlayerEngine.default.play(sandbox: "VO_heather_SU_8")
//            let synthesizer = AVSpeechSynthesizer()
//            let utterance = AVSpeechUtterance(string: "Here's your weather update: Today's weather is partly cloudy with highs of 75 degrees")
//            synthesizer.speak(utterance)
        default:
            break
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        aelog("willPresent")
        completionHandler([.badge, .alert, .sound])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

