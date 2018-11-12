//
//  DestinationVideosTableViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-11-14.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices
import AVKit
import MediaPlayer

class DestinationVideosTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    var destinationVideosArray: [Videos] = [] //array to hold all of the videos for a single destination
    var destinationVideosName: String!
    var error: NSError? = nil
    
    var videoPlayer = AVPlayer()
    var videoPlayerViewController = AVPlayerViewController()
    var hueColorForTable: CGFloat!
    var saturationColorForTable:CGFloat!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let destinationVideosAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let destinationVideosContext: NSManagedObjectContext = destinationVideosAppDel.managedObjectContext
        let destinationVideosFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Videos")
        destinationVideosFetchRequest.predicate = NSPredicate(format: "destinationName = %@", destinationVideosName)
        
        do {
            let destinationVideosFetchResults = try destinationVideosContext.fetch(destinationVideosFetchRequest) as? [Videos]
            destinationVideosArray = destinationVideosFetchResults!
        } catch {
            print("Could not retreive videos for the destination \(error)")
        }
        self.tableView.reloadData()
        
        let userDefaultsHue: Any? = UserDefaults.standard.object(forKey: "userDestinationsTableHue")
        let userDefaultsSaturation: Any? = UserDefaults.standard.object(forKey: "userDestinationsTableSaturation")
        
        hueColorForTable = userDefaultsHue as! CGFloat
        saturationColorForTable = userDefaultsSaturation as! CGFloat
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return destinationVideosArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationVideoCell", for: indexPath)

        let destinationVideo: Videos = destinationVideosArray[indexPath.row] as Videos
        let videoNumber = indexPath.row + 1
        cell.textLabel?.text = "Video " + String(videoNumber) + " (Tap to Play)"
        cell.detailTextLabel?.text = destinationVideo.destinationName
        
        let rowCount = CGFloat(tableView.numberOfRows(inSection: indexPath.section))
        let currentRow = CGFloat(indexPath.row)
        let hue = hueColorForTable!
        let saturation = saturationColorForTable! - currentRow / rowCount
        cell.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let destinationVideo: Videos = destinationVideosArray[indexPath.row] as Videos
        let destinationVideoURL = destinationVideo.destinationVideoURL
        let videoURLText = destinationVideoURL
        
        if videoURLText != nil {
            
            //let videoURL = NSURL(string: videoURLText!) ---Videos were not playable with this after some time
            let videoURL = NSURL.fileURL(withPath: videoURLText!)
            videoPlayer = AVPlayer(url: videoURL as URL)
            videoPlayerViewController = AVPlayerViewController()
            videoPlayerViewController.player = videoPlayer
            self.present(videoPlayerViewController, animated: true) {
                self.videoPlayerViewController.player!.play()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //delete the row from the data source
            let destinationVideosAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let destinationVideosContext: NSManagedObjectContext = destinationVideosAppDel.managedObjectContext
            
            destinationVideosContext.delete(destinationVideosArray[indexPath.row] as Videos) //delete from core data
            
            var error: NSError?
            do {
                try destinationVideosContext.save()
            } catch let error1 as NSError {
                error = error1
                print("Could not delete the video \(String(describing: error)), \(String(describing: error?.userInfo))")
            }
            
            destinationVideosArray.remove(at: indexPath.row) //delete from array
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let videoPlaying = videoPlayerViewController.player {
            videoPlaying.pause()
        }
        
    }

}
