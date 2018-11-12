//
//  DestinationSoundsTableViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-11-01.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class DestinationSoundsTableViewController: UITableViewController, UINavigationControllerDelegate, AVAudioPlayerDelegate {
    
    var destinationSoundsArray: [Sounds] = []
    var destinationSoundName: String!
    var hueColorForTable: CGFloat!
    var saturationColorForTable:CGFloat!
    
    var error: NSError? = nil
    var soundPlayer: AVAudioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let destinationSoundsAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let destinationSoundsContext: NSManagedObjectContext = destinationSoundsAppDel.managedObjectContext
        let destinationSoundsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Sounds")
        
        destinationSoundsFetchRequest.predicate = NSPredicate(format: "destinationName = %@", destinationSoundName) //select 1 destination record only
        
        do {
            let destinationSoundsFetchResults = try destinationSoundsContext.fetch(destinationSoundsFetchRequest) as? [Sounds]
            destinationSoundsArray = destinationSoundsFetchResults!
        } catch {
            print("Could not fetch sounds for destination \(error)")
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
        return destinationSoundsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationSoundCell", for: indexPath)

        // Configure the cell...
        
        let destinationSound: Sounds = destinationSoundsArray[indexPath.row] as Sounds
        
        cell.textLabel?.text = destinationSound.destinationSoundTitle! + " (Tap to Play)"
        cell.detailTextLabel?.text = destinationSound.destinationName
        
        let rowCount = CGFloat(tableView.numberOfRows(inSection: indexPath.section))
        let currentRow = CGFloat(indexPath.row)
        let hue = hueColorForTable!
        let saturation = saturationColorForTable! - currentRow / rowCount
        cell.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let destinationSound: Sounds = destinationSoundsArray[indexPath.row] as Sounds
        let destinationSoundURL =  destinationSound.destinationSoundURL
        
        let directoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        
        let audioFileURL = directoryURL!.appendingPathComponent(destinationSoundURL!)
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
        } catch let error1 as NSError {
            error = error1
        }
        soundPlayer.play()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //delete the row from the data source
            let destinationSoundsAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let destinationSoundsContext: NSManagedObjectContext = destinationSoundsAppDel.managedObjectContext
            
            destinationSoundsContext.delete(destinationSoundsArray[indexPath.row] as Sounds) //delete from core data
            
            var error: NSError?
            do {
                try destinationSoundsContext.save()
            } catch let error1 as NSError {
                error = error1
                print("Could not delete \(String(describing: error)), \(String(describing: error?.userInfo))")
            }
            
            destinationSoundsArray.remove(at: indexPath.row) //delete from array
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
