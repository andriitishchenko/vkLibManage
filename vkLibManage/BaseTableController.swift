//
//  BaseTableController.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/7/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//  http://stackoverflow.com/questions/38204703/notificationcenter-issue-on-swift-3

import UIKit

class BaseTableController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var refreshControl:UIRefreshControl!
    var dataSource:Array? = []
    var selectedIndex:IndexPath? = nil
    @IBOutlet weak var tableView: UITableView!
    
    func pullRefreshInection (){
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing ...")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func reload(){}
    
    func refresh(_ sender:AnyObject) {
        DispatchQueue.global(qos: .userInitiated).async {
            print("refreshing")
            DispatchQueue.main.async {
                self.reload()
                self.refreshControl.endRefreshing()
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(progressBarUpdate(_:)), name: .AppNotificationsDownloadProgress , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(progressBarUpdate(_:)), name: .AppNotificationsDownloadCompleted , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(progressSyncUpdate(_:)), name: .AppNotificationsSyncProgress , object: nil)
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func progressSyncUpdate(_ notification: NSNotification){
        
        let param:ProgressType? = notification.object as? ProgressType
        if (param != nil){
            self.navigationItem.prompt = param?.toString()
        }
        else
        {
            self.navigationItem.prompt = nil
        }
    }
    
    func progressBarUpdate(_ notification: NSNotification){
        
        let param:NSNumber? = notification.object as? NSNumber
        if ((param?.intValue)! > 0){
            self.navigationItem.prompt = "Downloaded:" + (param?.stringValue)!
        }
        else
        {
            self.navigationItem.prompt = nil
        }
    }
    
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource!.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
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
