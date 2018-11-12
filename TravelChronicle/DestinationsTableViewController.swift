//
//  DestinationsTableViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-09-26.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import CoreData

var viewSelectedDestinationName: String = ""
var viewSelectedDestinationLatitude: Double = 0.0
var viewSelectedDestinationLongitude: Double = 0.0
var viewSelectedDestinationNotes: String = ""

var editSelectedRow: Int = 0
var editSelectedDestinationName: String = ""
var editSelectedDestinationLatitude: Double = 0.0
var editSelectedDestinationLongitude: Double = 0.0
var editSelectedDestinationNotes: String = ""

class DestinationsTableViewController: UITableViewController {
    
    var destinations = [Destinations]()
    var hueColorForTable: CGFloat!
    var saturationColorForTable:CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let destinationAppDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let destinationContext: NSManagedObjectContext = destinationAppDel.managedObjectContext
        let DestinationFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Destinations")
        //Following line was changed to the line below it as per https://stackoverflow.com/questions/49653525/bad-access-when-creating-nspredicate-instance
        //DestinationFetchRequest.predicate = NSPredicate(format: "destinationShow = %@", true as CVarArg)
        DestinationFetchRequest.predicate = NSPredicate(format: "destinationShow = true")
        let sortDescriptor = NSSortDescriptor(key: "destinationName", ascending: true)
        DestinationFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let destinationFetchedResults = try destinationContext.fetch(DestinationFetchRequest) as? [Destinations] {
                destinations = destinationFetchedResults
            } else {
                print("ELSE if let results = try.. FAILED")
            }
        } catch {
            fatalError("There was an error fetching the list of groups!")
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
        return destinations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationsCell", for: indexPath)

        // Configure the cell...
        
        let destination = destinations[indexPath.row]
        cell.textLabel?.text = destination.destinationName
        
        let cellLatitudeDouble: Double = (destination.destinationLatitude as Double?)!
        let cellLatitudeString: String = String(format: "%.6f", cellLatitudeDouble)
        
        let cellLongitudeDouble: Double = (destination.destinationLongitude as Double?)!
        let cellLongitudeString: String = String(format: "%.6f", cellLongitudeDouble)
        
        cell.detailTextLabel?.text = "Lat: " + cellLatitudeString + " Lon: " + cellLongitudeString
        
        let rowCount = CGFloat(tableView.numberOfRows(inSection: indexPath.section))
        let currentRow = CGFloat(indexPath.row)
        let hue = hueColorForTable!
        let saturation = saturationColorForTable! - currentRow / rowCount
        cell.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)

        return cell
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let destinationAppDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let destinationContext: NSManagedObjectContext = destinationAppDel.managedObjectContext
            
            let toBeDeletedDestination = destinations[indexPath.row] as Destinations
            let deleteSelectedDestinationName = toBeDeletedDestination.destinationName
            
            destinationContext.delete(destinations[indexPath.row] as Destinations) //delete from the core data
            
            do {
                try destinationContext.save()
            } catch {
                print("Could not delete the destination \(error)")
            }
            
            destinations.remove(at: indexPath.row) //delete from the array
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //Delete all related destination photos, sounds and videos from the respective coredata entities

            //1. Delete photos
            
            let photosAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let photosContext: NSManagedObjectContext = photosAppDel.managedObjectContext
            let requestDeleteAllPhotos = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
            requestDeleteAllPhotos.returnsObjectsAsFaults = false
            requestDeleteAllPhotos.predicate = NSPredicate(format: "destinationName = %@", deleteSelectedDestinationName)
            
            do {
            let photoRecordsToDelete = try photosContext.fetch(requestDeleteAllPhotos)
            if photoRecordsToDelete.count > 0 {
                for recordToDelete in photoRecordsToDelete {
                    photosContext.delete(recordToDelete as! Photos)
                    do {
                        try photosContext.save()
                    } catch _ {
                    }
                }
                }
            } catch {
                print("Could not delete the photos")
            }
            
            //2. Delete sounds
            
            let soundsAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let soundsContext: NSManagedObjectContext = soundsAppDel.managedObjectContext
            let requestDeleteAllSounds = NSFetchRequest<NSFetchRequestResult>(entityName: "Sounds")
            requestDeleteAllSounds.returnsObjectsAsFaults = false
            requestDeleteAllSounds.predicate = NSPredicate(format: "destinationName = %@", deleteSelectedDestinationName)
            
            do {
                let soundRecordsToDelete = try soundsContext.fetch(requestDeleteAllSounds)
                if soundRecordsToDelete.count > 0 {
                    for recordToDelete in soundRecordsToDelete {
                        soundsContext.delete(recordToDelete as! Sounds)
                        do {
                            try soundsContext.save()
                        } catch _ {
                        }
                    }
                }
            } catch {
                print("Could not delete the sounds")
            }
            
            //3. Delete videos
            
            let videosAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let videosContext: NSManagedObjectContext = videosAppDel.managedObjectContext
            let requestDeleteAllVideos = NSFetchRequest<NSFetchRequestResult>(entityName: "Videos")
            requestDeleteAllVideos.returnsObjectsAsFaults = false
            requestDeleteAllVideos.predicate = NSPredicate(format: "destinationName = %@", deleteSelectedDestinationName)
            
            do {
                let videoRecordsToDelete = try videosContext.fetch(requestDeleteAllVideos)
                if videoRecordsToDelete.count > 0 {
                    for recordToDelete in videoRecordsToDelete {
                        videosContext.delete(recordToDelete as! Videos)
                        do {
                            try videosContext.save()
                        } catch _ {
                        }
                    }
                }
            } catch {
                print("Could not delete the videos")
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = destinations[indexPath.row]
        
        viewSelectedDestinationName = destination.destinationName
        viewSelectedDestinationLatitude = destination.destinationLatitude as Double
        viewSelectedDestinationLongitude = destination.destinationLongitude as Double
        viewSelectedDestinationNotes = destination.destinationNotes
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let destination = destinations[indexPath.row]
        
        editSelectedRow = indexPath.row
        editSelectedDestinationName = destination.destinationName
        editSelectedDestinationLatitude = destination.destinationLatitude as Double
        editSelectedDestinationLongitude = destination.destinationLongitude as Double
        editSelectedDestinationNotes = destination.destinationNotes
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
