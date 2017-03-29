//
//  RecorderEngine.swift
//  AudioExperiments
//
//  Created by Andrew Sowers on 3/28/17.
//  Copyright © 2017 SkyBuds. All rights reserved.
//

import Foundation
import RxAVFoundation
import RxSwift
import RxCocoa
import AVFoundation
import UserNotifications
import AELog

final class RecorderEngine: NSObject, AVAudioRecorderDelegate {
    
    static let `default` = RecorderEngine()
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    func setupRecorder() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            aelog("setup recorder")
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            aelog("start recording")
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
            aelog("start recording failed")
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        
        if success {
            aelog("finish recording success")
            PlayerEngine.default.play(local: getDocumentsDirectory().appendingPathComponent("recording.m4a"))
        } else {
            print("finish recording failure")
            // recording failed :(
        }
    }
    
    func recordTapped() {
        aelog("recordTapped")
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
