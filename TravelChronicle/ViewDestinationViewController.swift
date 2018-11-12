//
//  ViewDestinationViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-10-05.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewDestinationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var destinationNameLabel: UILabel!
    @IBOutlet weak var destinationLatitudeLabel: UILabel!
    @IBOutlet weak var destinationLongitudeLabel: UILabel!
    @IBOutlet weak var destinationNotesTextView: UITextView!
    @IBOutlet weak var destinationMapView: MKMapView!
    @IBOutlet weak var destinationImageButtonOutlet: UIButton!
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    @IBOutlet weak var destinationSoundButtonOutlet: UIButton!
    @IBOutlet weak var numberOfSoundsLabel: UILabel!
    @IBOutlet weak var destinationVideoButtonOutlet: UIButton!
    @IBOutlet weak var numberOfVideosLabel: UILabel!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        destinationNameLabel.text = viewSelectedDestinationName
        
        let cellLatitudeDouble: Double = (viewSelectedDestinationLatitude as Double?)!
        let cellLatitudeString: String = String(format: "%.6f", cellLatitudeDouble)
        
        let cellLongitudeDouble: Double = (viewSelectedDestinationLongitude as Double?)!
        let cellLongitudeString: String = String(format: "%.6f", cellLongitudeDouble)
        
        destinationLatitudeLabel.text = cellLatitudeString
        destinationLongitudeLabel.text = cellLongitudeString
        
        destinationNotesTextView.text = viewSelectedDestinationNotes
        
        //Mapview config
        
        let latitude: CLLocationDegrees = viewSelectedDestinationLatitude
        let longitude: CLLocationDegrees = viewSelectedDestinationLongitude
        
        let deltaLatitude: CLLocationDegrees = 0.01
        let deltaLongitude: CLLocationDegrees = 0.01
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(deltaLatitude, deltaLongitude)
        
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        destinationMapView.setRegion(region, animated: true)
        
        //Map annotations
        
        let destinationAnotation = MKPointAnnotation()
        destinationAnotation.coordinate = location
        destinationAnotation.title = viewSelectedDestinationName
        
        destinationMapView.addAnnotation(destinationAnotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let photosAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let photosContext: NSManagedObjectContext = photosAppDel.managedObjectContext
        let photosFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
        
        photosFetchRequest.predicate = NSPredicate(format: "destinationName = %@", viewSelectedDestinationName)
        
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
        
        
        //Retrieve the number of sounds from the destination Sounds entity
        
        let soundsAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let soundsContext: NSManagedObjectContext = soundsAppDel.managedObjectContext
        let soundsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Sounds")
        
        soundsFetchRequest.predicate = NSPredicate(format: "destinationName = %@", viewSelectedDestinationName) //select 1 destination record only
        
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
        
        videosFetchRequest.predicate = NSPredicate(format: "destinationName = %@", viewSelectedDestinationName) //select 1 destination record only
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "viewToDestinationSounds" {
            
            let vc = segue.destination as! DestinationSoundsTableViewController
            vc.destinationSoundName = viewSelectedDestinationName
        }
        
        if segue.identifier == "viewToDestinationVideos" {
            
            let vc = segue.destination as! DestinationVideosTableViewController
            vc.destinationVideosName = viewSelectedDestinationName
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
