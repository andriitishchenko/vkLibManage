//
//  PlaylistController.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/7/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit


class PlaylistController:BaseTableController  {
    let cellId = "PlaylistCell"
    var selectedPlaylist:PlaylistItem? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let play = UIBarButtonItem(title: "Sync", style: .plain, target: self, action: #selector(startSync))
        self.navigationItem.rightBarButtonItems = [play]
        self.reload()
        self.pullRefreshInection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath)
        
        let item:PlaylistItem? = (self.dataSource?[indexPath.row] as? PlaylistItem)
        
        cell.textLabel?.text = item?.title
        
        
        return cell
    }
    
    @IBAction func startSync(sender: UIButton?) {
        SyncManager.sharedInstance.sync {
            self.reload()
        }
    }
    
    
    override func reload()
    {
        DBManager.sharedInstance.getLocalPlaylists { list in
            self.dataSource = list
            self.tableView.reloadData()
        }
        
    }
    
    
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.cellForRow(at: indexPath)
        //        if cell != nil {}

        let item:PlaylistItem? = (self.dataSource?[indexPath.row] as? PlaylistItem)
        selectedPlaylist = item
        self.performSegue(withIdentifier: "SongsListControllerSegue", sender: self)

    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc:SongsListController = segue.destination as! SongsListController
        vc.albumId = (self.selectedPlaylist?.id)!
    }
 

}
