//
//  PlayerEngine.swift
//  AudioExperiments
//
//  Created by Andrew Sowers on 3/27/17.
//  Copyright © 2017 SkyBuds. All rights reserved.
//

import Foundation
import RxAVFoundation
import RxSwift
import RxCocoa
import AVFoundation

final public class PlayerEngine: NSObject {
    
    static let `default` = PlayerEngine()
    
    let player = AVPlayer()
    let disposeBag = DisposeBag()
    
    func interruped() {
        print("interrupted")
        do {
            try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
    }
    
    func play(local fileURL: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        let sound = AVPlayerItem(url: fileURL)
        
        player.replaceCurrentItem(with: sound)
        
        setupProgressObservation(item: sound)
        
        // TODO: Build out this example by hiding loading indicator and pausing
        // adding a gesture recognizer to pause/resume playback etc.
        
        player.rx.status
            .filter { $0 == .readyToPlay }
            .subscribe(onNext: { [unowned self] status in
                print("item ready to play")
                self.player.play()
            }).addDisposableTo(disposeBag)
    }
    
    func play(sandbox fileString: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        let sound = AVPlayerItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: fileString, ofType: "wav")!))
        
        player.replaceCurrentItem(with: sound)
        
        setupProgressObservation(item: sound)
        
        // TODO: Build out this example by hiding loading indicator and pausing
        // adding a gesture recognizer to pause/resume playback etc.
        
        player.rx.status
            .filter { $0 == .readyToPlay }
            .subscribe(onNext: { [unowned self] status in
                print("item ready to play")
                self.player.play()
            }).addDisposableTo(disposeBag)

    }
    
    private func setupProgressObservation(item: AVPlayerItem) {
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.rx.periodicTimeObserver(interval: interval)
            .map { [unowned self] in self.progress(currentTime: $0, duration: item.duration) }
            .subscribe(onNext: { [unowned self] (event: Float) in
                print("time: \(event)")
                if event == 1.0 {
                    self.player.pause()
                    do {
                        try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
                    } catch {
                        print(error)
                    }
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    private func progress(currentTime: CMTime, duration: CMTime) -> Float {
        if !duration.isValid || !currentTime.isValid {
            return 0
        }
        
        let totalSeconds = duration.seconds
        let currentSeconds = currentTime.seconds
        
        if !totalSeconds.isFinite || !currentSeconds.isFinite {
            return 0
        }
        
        let p = Float(min(currentSeconds/totalSeconds, 1))
        return p
    }
}
