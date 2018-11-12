//
//  SoundsViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-11-01.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class SoundsViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate {
    
    var soundDestinationName: String! //populated from the incoming segue
    var soundURL: String! //used to store in coredata
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var soundDestinationNameLabel: UILabel!
    @IBOutlet weak var soundSaveConfirmationLabel: UILabel!
    @IBOutlet weak var soundTitleTextField: UITextField!
    @IBOutlet weak var soundRecordPlayStatusLabel: UILabel!
    
    @IBOutlet weak var recordButtonOutlet: UIButton!
    @IBOutlet weak var stopButtonOutlet: UIButton!
    @IBOutlet weak var playButtonOutlet: UIButton!
    
    @IBAction func soundSaveButtonAction(_ sender: UIBarButtonItem) {
        
        soundTitleTextField.resignFirstResponder()
        
        let destinationSoundsAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let destinationSoundsContext: NSManagedObjectContext = destinationSoundsAppDel.managedObjectContext
        
        let sound = NSEntityDescription.insertNewObject(forEntityName: "Sounds", into: destinationSoundsContext) as! Sounds
        
        sound.destinationName = soundDestinationName
        sound.destinationSoundURL = soundURL
        sound.destinationSoundTitle = soundTitleTextField.text!
        
        do {
            try destinationSoundsContext.save()
            soundSaveConfirmationLabel.alpha = 1
            soundSaveConfirmationLabel.text = "Saved " + soundTitleTextField.text!
            soundTitleTextField.text = " "
        } catch _ {
            
        }
        
        //allow the audio recorder to be ready to record the next audio recording
        
        setupRecorder()
        
    }
    
    @IBAction func recordButtonAction(_ sender: UIButton) {
        
        //stop the audio player before recording
        
        if let player = audioPlayer {
            if player.isPlaying {
                player.stop()
                playButtonOutlet.isSelected = false
            }
        }
        
        //setup audio session
        
        if let recorder = audioRecorder {
            if (!recorder.isRecording) {
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setActive(true)
                } catch _ {
                    
                }
                
                //start recording
                
                recorder.record()
                
                soundRecordPlayStatusLabel.text = "Recording..."
                stopButtonOutlet.isEnabled = true
                playButtonOutlet.isEnabled = false
                recordButtonOutlet.isSelected = true
            }
            else {
                
                //pause recording
                
                recorder.pause()
                
                soundRecordPlayStatusLabel.text = "Paused!"
                
                stopButtonOutlet.isEnabled = false
                playButtonOutlet.isEnabled = false
                recordButtonOutlet.isSelected = false
            }
            
            
        }
    }
    
    @IBAction func stopButtonAction(_ sender: UIButton) {
        
        soundRecordPlayStatusLabel.text = "Stopped!"
        playButtonOutlet.isEnabled = true
        stopButtonOutlet.isEnabled = false
        recordButtonOutlet.isEnabled = true
        
        recordButtonOutlet.isSelected = false
        playButtonOutlet.isSelected = false
        
        //stop the recoder
        
        if let recorder = audioRecorder {
            if recorder.isRecording {
                audioRecorder?.stop()
                
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setActive(false)
                } catch _ {
                    
                }
            }
        }
        
        //stop audio player if playing
        
        if let player = audioPlayer {
            if player.isPlaying {
                player.stop()
            }
        }
        
    }
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        
        if let recorder = audioRecorder {
            if !recorder.isRecording {
                
                audioPlayer = try? AVAudioPlayer(contentsOf: recorder.url)
                audioPlayer?.delegate =  self
                audioPlayer?.play()
                
                soundRecordPlayStatusLabel.text = "Playing..."
                stopButtonOutlet.isEnabled = true
                
                recordButtonOutlet.isEnabled = false
                playButtonOutlet.isSelected = true
            }
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundDestinationNameLabel.text = soundDestinationName
        soundSaveConfirmationLabel.alpha = 0
        
        //Disable stop.play buttons when the app launces
        stopButtonOutlet.isEnabled = false
        playButtonOutlet.isEnabled = false
        
        self.soundTitleTextField.delegate = self
        
        setupRecorder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Keyboard control
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        soundTitleTextField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //completion of recording
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            
            soundRecordPlayStatusLabel.text = "Recording completed!"
            
            recordButtonOutlet.isEnabled = true
            playButtonOutlet.isEnabled = true
            stopButtonOutlet.isEnabled = false
        }
    }
    
    //completion of playing
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        soundRecordPlayStatusLabel.text = "Finished playing audio!"
        
        playButtonOutlet.isSelected = false
        stopButtonOutlet.isEnabled = false
        recordButtonOutlet.isEnabled = true
    }
    
    func setupRecorder() {
        
        //Set the audio file
        let directoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        
        let audioFileName = NSUUID().uuidString + ".m4a"
        let audioFileURL = directoryURL!.appendingPathComponent(audioFileName)
        soundURL = audioFileName //Sound URL to be saved in coredata
        
        //Setup audio session
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        } catch _ {
            
        }
        
        let recorderSetting = [AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
                               AVSampleRateKey: 44100.00,
                               AVNumberOfChannelsKey: 2]
        
        //Initialize and prepare the recorder
        
        audioRecorder = try? AVAudioRecorder(url: audioFileURL, settings: recorderSetting)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
        
        soundRecordPlayStatusLabel.text = "Ready to record. Tap the Record button"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
