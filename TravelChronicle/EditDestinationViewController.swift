//
//  EditDestinationViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-10-09.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import CoreData

class EditDestinationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var editSaveConfirmationLabel: UILabel!
    @IBOutlet weak var destinationNameTextField: UITextField!
    @IBOutlet weak var destinationLatitudeTextField: UITextField!
    @IBOutlet weak var destinationLongitudeTextField: UITextField!
    @IBOutlet weak var destinationNotesTextView: UITextView!
    
    @IBOutlet weak var destinationImageButtonOutlet: UIButton!
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    
    @IBOutlet weak var destinationSoundButtonOutlet: UIButton!
    @IBOutlet weak var numberOfSoundsLabel: UILabel!
    
    @IBOutlet weak var destinationVideoButtonOutlet: UIButton!
    @IBOutlet weak var numberOfVideosLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        destinationNameTextField.text = editSelectedDestinationName
        
        self.destinationNameTextField.delegate = self
        
        let cellLatitudeDouble: Double = (editSelectedDestinationLatitude as Double?)!
        let cellLatitudeString: String = String(format: "%.6f", cellLatitudeDouble)
        
        let cellLongitudeDouble: Double = (editSelectedDestinationLongitude as Double?)!
        let cellLongitudeString: String = String(format: "%.6f", cellLongitudeDouble)
        
        destinationLatitudeTextField.text = cellLatitudeString
        destinationLongitudeTextField.text = cellLongitudeString
        
        destinationNotesTextView.text = editSelectedDestinationNotes
        
        editSaveConfirmationLabel.alpha = 0
        
        let saveRightButton = UIBarButtonSystemItem.save
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: saveRightButton,
            target: self, action: #selector(editSaveButtonAction))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //photos
        
        let photosAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let photosContext: NSManagedObjectContext = photosAppDel.managedObjectContext
        let photosFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
        
        photosFetchRequest.predicate = NSPredicate(format: "destinationName = %@", editSelectedDestinationName)
        
        var photos: [Photos] = []
        
        do {
            let photosFetchResults = try photosContext.fetch(photosFetchRequest) as? [Photos]
            photos = photosFetchResults!
        } catch {
            print("Could not fetch photos for destination \(error)")
        }
        
        numberOfPhotosLabel.text = String(photos.count)
        
        if photos.count == 0 {
            if let image = UIImage(named: "photo_default") {
                destinationImageButtonOutlet.setImage(image, for: .normal)
            }
        } else {
            let photo: Photos = photos[0]
            
            if let thumbnail = UIImage(data: photo.destinationPhoto! as Data) {
                destinationImageButtonOutlet.setImage(thumbnail, for: .normal)
            } else {
                if let image = UIImage(named: "photo_default") {
                    destinationImageButtonOutlet.setImage(image, for: .normal)
                }
            }
        }
        
        //sounds
        
        let soundsAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let soundsContext: NSManagedObjectContext = soundsAppDel.managedObjectContext
        let soundsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Sounds")
        
        soundsFetchRequest.predicate = NSPredicate(format: "destinationName = %@", editSelectedDestinationName)
        
        var sounds: [Sounds] = []
        
        do {
            let soundsFetchResults = try soundsContext.fetch(soundsFetchRequest) as? [Sounds]
            sounds = soundsFetchResults!
        } catch {
            print("Could not fetch sounds for destination \(error)")
        }
        
        numberOfSoundsLabel.text = String(sounds.count)
        
        if sounds.count == 0 {
            if let image = UIImage(named: "vol_mute.png") {
                destinationSoundButtonOutlet.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: "vol_loud.png") {
                destinationSoundButtonOutlet.setImage(image, for: .normal)
            }
        }
        
        //Retrieve the number of videos from the destination Videos entity
        
        let videosAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let videosContext: NSManagedObjectContext = videosAppDel.managedObjectContext
        let videosFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Videos")
        
        videosFetchRequest.predicate = NSPredicate(format: "destinationName = %@", editSelectedDestinationName) //select 1 destination record only
        
        var videos: [Videos] = []
        
        do {
            let videosFetchResults = try videosContext.fetch(videosFetchRequest) as? [Videos]
            videos = videosFetchResults!
        } catch {
            print("Could not fetch videos for destination \(error)")
        }
        
        numberOfVideosLabel.text = String(videos.count)
        
        if videos.count == 0 {
            if let image = UIImage(named: "video_none.png") {
                destinationVideoButtonOutlet.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: "video_play.png") {
                destinationVideoButtonOutlet.setImage(image, for: .normal)
            }
        }
        
    }
    
    @IBAction func editSaveButtonAction(sender: AnyObject) {
    
        
        var destinations = [Destinations]()
        
        let destinationAppDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let destinationContext: NSManagedObjectContext = destinationAppDel.managedObjectContext
        let DestinationFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Destinations")
        do {
            if let destinationFetchedResults = try destinationContext.fetch(DestinationFetchRequest) as? [Destinations] {
                destinations = destinationFetchedResults
            } else {
                print("ELSE if let results = try.. FAILED")
            }
        } catch {
            fatalError("There was an error fetching the list of groups!")
        }
        
        let destination = destinations[editSelectedRow]
        
        destination.destinationName = destinationNameTextField.text!
        destination.destinationLatitude = Double(destinationLatitudeTextField.text!) ?? 0.0
        destination.destinationLongitude = Double(destinationLongitudeTextField.text!) ?? 0.0
        destination.destinationNotes = destinationNotesTextView.text
        
        
        do {
            try destinationContext.save()
            editSaveConfirmationLabel.alpha = 1
            editSaveConfirmationLabel.text = "Saved:" + destinationNameTextField.text!
            print("Saved the destination successfully \(destination.destinationName)")
        } catch {
            editSaveConfirmationLabel.alpha = 1
            editSaveConfirmationLabel.text = "Error:" + destinationNameTextField.text!
            print("Could not save \(error)")
        }
        
        destinationNotesTextView.resignFirstResponder()
        destinationNameTextField.resignFirstResponder()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editToPhotos" {
            let vc = segue.destination as! PhotosViewController
            vc.photosDestinationName = editSelectedDestinationName
            vc.photosSourceType = "Photos"
        }
        
        if segue.identifier == "editToCamera" {
            let vc = segue.destination as! PhotosViewController
            vc.photosDestinationName = editSelectedDestinationName
            vc.photosSourceType = "Camera"
        }
        
        if segue.identifier == "editToSounds" {
            let vc = segue.destination as! SoundsViewController
            vc.soundDestinationName = editSelectedDestinationName
        }
        
        if segue.identifier == "editToDestinationSounds" {
            let vc = segue.destination as! DestinationSoundsTableViewController
            vc.destinationSoundName = editSelectedDestinationName
        }
        
        if segue.identifier == "editToVideos" {
            let vc = segue.destination as! VideosViewController
            vc.videosDestinationName = editSelectedDestinationName
            vc.videosSourceType = "Video"
        }
        
        if segue.identifier == "editToDestinationVideos" {
            let vc = segue.destination as! DestinationVideosTableViewController
            vc.destinationVideosName = editSelectedDestinationName
        }


        
    }
    
    // MARK: - Keyboard control
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        destinationNameTextField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}
