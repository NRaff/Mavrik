//
//  ViewController.swift
//  SkiBum
//
//  Created by Nick Raff on 7/22/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//

import UIKit
import CoreLocation
import Realm
import RealmSwift
import Mixpanel

class SessionsViewController: UIViewController {
    
    var mixpanel: Mixpanel!
    var locationStuff = LocationHelper()
    var selectedSession: Session?
    
    override func viewDidLoad() {
//        locationStuff.startLocation()
        mixpanel = Mixpanel.sharedInstance()
        newShredView.hidden = false
        let realm = Realm()
        super.viewDidLoad()
        sessionsTableView.dataSource = self
        sessionsTableView.delegate = self
        
        sessions = realm.objects(Session).sorted("Date", ascending: false)
        
        myNavBar.setTitleVerticalPositionAdjustment(-8, forBarMetrics: .Default)
    }
    
    override func viewDidDisappear(animated: Bool) {
        newShredView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
    let realm = Realm()
    sessions = realm.objects(Session).sorted("Date", ascending: false)
        
    }
    
    @IBOutlet weak var newShredView: UIView!
    @IBOutlet weak var myNavBar: UINavigationBar!
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        let realm = Realm()
        if let identifier = segue.identifier {
            switch identifier {
            case "BackAndSave":
        
                println("I take it \(identifier)")
                
            default:
                //println("No one loves \(identifier)")
                mixpanel.track("Add Session Started", properties: ["Recording": "End without data/saving"])
            }
            
            sessions = realm.objects(Session).sorted("Date", ascending: false) //2
            //println("whats happening?")
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showNewSession") {
            let sessionViewController = segue.destinationViewController as! NewSessionViewController
            if let selectedSession = selectedSession {
                sessionViewController.currentSession = selectedSession
                sessionViewController.isAddSession = false
            }
            else {
                println("session is nil")
            }
        }
        if (segue.identifier == "settings") {
            mixpanel.track("Settings", properties: ["Options": "Opened"])
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var sessionsTableView: UITableView!
    
    var sessions: Results<Session>! {
        didSet {
            // Whenever notes update, update the table view
            sessionsTableView?.reloadData()
        }
    }
 
}

extension SessionsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("sessionCell", forIndexPath: indexPath) as! SessionTableViewCell //1
        
        let row = indexPath.row
        let session = sessions[row] as Session
        cell.session = session

        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sessions?.count < 1 {
          newShredView.hidden = false
        }
        else {
          newShredView.hidden = true
        }
        return Int(sessions?.count ?? 0)
    }
    
}

extension SessionsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedSession = sessions[indexPath.row]      //1
//        mixpanel.track("Old Session", properties: ["Viewing?": "Yes"])
        self.performSegueWithIdentifier("showNewSession", sender: self)     //2
        
    }
    
    // 3
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // 4
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            mixpanel.track("Old Session", properties: ["Viewing?": "Deleted"])
            let session = sessions[indexPath.row] as Object
            
            let realm = Realm()
            
            realm.write() {
                realm.delete(session)
            }
            
            sessions = realm.objects(Session).sorted("Date", ascending: false)
        }
    }
    
    

}