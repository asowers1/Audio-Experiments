//
//  ViewController.swift
//  AudioExperiments
//
//  Created by Andrew Sowers on 3/20/17.
//  Copyright © 2017 SkyBuds. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UITableViewController {

    let audioFiles = ["VO_heather_SU_8", "bluetooth_connect", "bluetooth_search", "connect_fail", "hang_up", "low_battery", "pickup_call01", "play", "power_down"]
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.reloadData()
    }
    
    func interruped() {
        print("interrupted")
        do {
            try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if self.player!.rate == 0 {
                self.interruped()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    //MARK: - TableView -
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        let sound = URL(fileURLWithPath: Bundle.main.path(forResource: audioFiles[indexPath.row], ofType: "wav")!)
        player = AVPlayer(url: sound)
        
        player?.play()
        player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = audioFiles[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFiles.count
    }

}

