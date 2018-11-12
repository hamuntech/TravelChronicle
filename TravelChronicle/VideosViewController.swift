//
//  VideosViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-11-12.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import Photos
import AVKit
import AVFoundation

class VideosViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //Variables
    var videoController = UIImagePickerController()
    //var assetsLibrary = ALAssetsLibrary()
    //var moviePlayer: MPMoviePlayerViewController?
    
    var videosDestinationName: String!
    var videosSourceType: String!
    var videoURLText: String! //stores the video URL in a text string
    
    
    //Outlets
    @IBOutlet weak var addVideoToLabel: UILabel!
    @IBOutlet weak var addVideoConfirmationMessageLabel: UILabel!
    @IBOutlet weak var addVideoURL: UILabel!
    @IBOutlet weak var addVideoSwitchOutlet: UISwitch!
    @IBOutlet weak var addVideoNOLabel: UILabel!
    @IBOutlet weak var addVideoYESLabel: UILabel!
    
    @IBOutlet weak var takeVideoButtonOutlet: UIButton!
    @IBOutlet weak var viewLibraryButtonOutlet: UIButton!
    @IBOutlet weak var playVideoButtonOutlet: UIButton!
    
    
    
    @IBAction func takeVideoButtonAction(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            videoController.sourceType = .camera
            videoController.mediaTypes = [kUTTypeMovie as String]
            videoController.delegate = self
            //videoController.videoMaximumDuration = 10.0
            
            present(videoController, animated: true, completion: nil)
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                
                if status == .authorized {
                    
                    DispatchQueue.main.async
                    {
                    self.addVideoURL.text = "Save video for " + self.videosDestinationName + "?"
                    self.addVideoURL.textColor = UIColor.blue
                    }
                }
                
            })
            
        } else {
        
        noCamera()
            
        }
    }
    
    func noCamera() {
        
        let alertVC = UIAlertController(title: "No Camera!", message: "Hello, your device does not have a camera", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
        
    }
    
    @IBAction func viewLibraryButtonAction(_ sender: UIButton) {
        
        videoController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        videoController.mediaTypes = [kUTTypeMovie as String]
        videoController.delegate = self
        
        present(videoController, animated: true, completion: nil)
    }
    
    @IBAction func playVideoButtonAction(_ sender: UIButton) {
        
        playVideo()
        
    }
    
    func playVideo() {
        
        //Rewritten from the lecture video "052 Videos Deprecated Code Handling New AVPlayer"
        
        if videoURLText != nil {
            
            let videoURL = NSURL(string: videoURLText!)
            let videoPlayer = AVPlayer(url: videoURL! as URL)
            let videoPlayerViewController = AVPlayerViewController()
            videoPlayerViewController.player = videoPlayer
            self.present(videoPlayerViewController, animated: true) {
                videoPlayerViewController.player!.play()
            }
            addVideoSwitchOutlet.alpha = 1
            addVideoSwitchOutlet.setOn(false, animated: true)
        }
        
    }
    
    @IBAction func addVideoSwitchAction(_ sender: UISwitch) {
        
        let videosAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let videosContext: NSManagedObjectContext = videosAppDel.managedObjectContext
        //let videosEntity =  NSEntityDescription.entity(forEntityName: "Videos", in: videosContext)
        
        let videoURL = NSURL(string: self.videoURLText!)
        let videoURLString = videoURL!.absoluteString
        
        //If ON, store video URL in the Videos coredata entity, otherwise if OFF, delete from coredata (if exists)
        if addVideoSwitchOutlet.isOn {
            //let newVideo = NSManagedObject(entity: videosEntity!, insertInto: videosContext) as! Videos
            let newVideo = NSEntityDescription.insertNewObject(forEntityName: "Videos", into: videosContext) as! Videos
            newVideo.destinationName = videosDestinationName
            newVideo.destinationVideoURL = videoURLString
            do {
                try videosContext.save()
                addVideoConfirmationMessageLabel.alpha = 1
                addVideoConfirmationMessageLabel.textColor = UIColor(displayP3Red: 20/255, green: 180/255, blue: 24/255, alpha: 1.0)
                addVideoConfirmationMessageLabel.text = "Saved Video for: " + videosDestinationName
            } catch _ {
            }
            addVideoToLabel.text = videosDestinationName
            addVideoToLabel.textColor = UIColor.blue
        } //End if switch ON
            
        else {
            let requestVideoDelete = NSFetchRequest<NSFetchRequestResult>(entityName: "Videos")
            requestVideoDelete.returnsObjectsAsFaults = false
            requestVideoDelete.predicate = NSPredicate(format: "destinationName = %@", videosDestinationName)
            requestVideoDelete.predicate = NSPredicate(format: "destinationVideoURL = %@", videoURLString!)
            
            do {
                let videoRecordsToDelete = try videosContext.fetch(requestVideoDelete)
                
                if videoRecordsToDelete.count > 0 {
                    for videoRecordToDelete in videoRecordsToDelete {
                        videosContext.delete(videoRecordToDelete as! Videos)
                    }
                }
                do {
                    try videosContext.save()
                    addVideoConfirmationMessageLabel.textColor = UIColor.red
                    addVideoConfirmationMessageLabel.text = "Removed Video for: " + videosDestinationName
                } catch _ {
                }
            
            } catch {
                print("Could not delete the videos")
            }
            
        } //End switch OFF
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addVideoURL.alpha = 0
        addVideoYESLabel.alpha = 0
        addVideoNOLabel.alpha = 0
        addVideoSwitchOutlet.alpha = 0
        addVideoConfirmationMessageLabel.alpha = 0
        
        
        /*
        
        //Video Buttons
        
        let takeVideoButtonImage: UIImage? = UIImage(named: "video_rec")
        takeVideoButtonOutlet.setImage(takeVideoButtonImage!, for: .normal)
        let takeVideoButtonTitle: String? = "Record New Video"
        takeVideoButtonOutlet.setTitle(takeVideoButtonTitle, for: .normal)
        
        let viewLibraryButtonImage: UIImage? = UIImage(named: "albums")
        viewLibraryButtonOutlet.setImage(viewLibraryButtonImage!, for: .normal)
        let viewLibraryButtonTitle: String? = "Select Video from Libraray"
        viewLibraryButtonOutlet.setTitle(viewLibraryButtonTitle, for: .normal)
        
        let playVideoButtonImage: UIImage? = UIImage(named: "controls_play")
        playVideoButtonOutlet.setImage(playVideoButtonImage!, for: .normal)
        let playVideoButtonTitle: String? = "Play Last Video"
        playVideoButtonOutlet.setTitle(playVideoButtonTitle, for: .normal)
 
         */
        
        //videosDestinationName = "Pendoo Testing videos"
        addVideoToLabel.text = "Destination: " + videosDestinationName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType] as AnyObject
        
        if let type:AnyObject = mediaType {
            if type is String {
                let stringType = type as! String
                if stringType == kUTTypeMovie as String {
                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                    
                    //Rewritten from the lecture video "052 Videos Deprecated Code Handling New AVPlayer"
                    if let url = urlOfVideo {
                        
                        PHPhotoLibrary.shared().performChanges({ () -> Void in
                            _ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url as URL)
                        }, completionHandler: { (success: Bool, error: Error?) -> Void in
                            if success {
                                
                                let urlString = url.absoluteString
                                
                                DispatchQueue.main.async
                                    {
                                self.videoURLText =  urlString
                                self.addVideoURL.text = "Save Video for " + self.videosDestinationName + "?"
                                self.addVideoURL.textColor = UIColor.blue
                                }
                            } else {
                                DispatchQueue.main.async
                                    {
                                self.addVideoURL.text = "Error in saving the Video: " + "\(String(describing: error?.localizedDescription))"
                                }
                            }
                        })
                        
                    }
                     //End of rewritten code from the lecture video
                    
                    
                    /* This code was commented out as it was replaced with the code from the lecture video "052 Videos Deprecated Code Handling New AVPlayer"
                     
                    if let url = urlOfVideo {
                        
                        //start: https://stackoverflow.com/questions/29482738/swift-save-video-from-nsurl-to-user-camera-roll
                        //code was taken from the stackoverflow and modified
                        
                        //Save video to the app user's assets library and it will be persisted under the detination name as a video
                        PHPhotoLibrary.shared().performChanges({
                             PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url as URL)
                        }) { saved, error in
                            if saved {
                                
                                let urlString = url.absoluteString
                                
                                DispatchQueue.main.async
                                {
                                self.videoURLText = urlString
                                self.addVideoURL.text = "Save video for " + self.videosDestinationName + "?"
                                self.addVideoURL.textColor = UIColor.blue
                                }
                                
                            } else {
                                print("Error saving video - \(String(describing: error))")
                                
                                
                            }
                            
                            
                        }
                        
                        //end
                     
                        
                    } */
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        addVideoToLabel.alpha = 1
        addVideoURL.alpha = 1
        addVideoYESLabel.alpha = 1
        addVideoNOLabel.alpha = 1
        addVideoSwitchOutlet.alpha = 1
        addVideoSwitchOutlet.setOn(false, animated: true)
        addVideoConfirmationMessageLabel.alpha = 0
        
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
