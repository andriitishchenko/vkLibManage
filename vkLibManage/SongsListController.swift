//
//  SongsListController.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/7/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit

class SongsListController: BaseTableController {
    
    let cellId = "PlaylistItemCell"
    var album:PlaylistItem? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reload()
        self.pullRefreshInection()
        
        let play = UIBarButtonItem(title: "Queue", style: .plain, target: self, action: #selector(show_playlist))
        self.navigationItem.rightBarButtonItems = [play]
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func show_playlist(sender: UIButton?) {
       self.performSegue(withIdentifier: "showActivePlaylistController", sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath)
        
        let item:TrackItem? = (self.dataSource?[indexPath.row] as? TrackItem)
        
        cell.textLabel?.text = item?.title
        cell.detailTextLabel?.text = item?.artist
        
        if item?.status == .Done {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    
    override func reload()
    {
        DBManager.sharedInstance.getLocalTracks(playlist_id: (self.album?.id)!) { list in
            self.dataSource = list
            self.tableView.reloadData()
        }
    }
    
    @IBAction func toolBarClick(sender: UIBarButtonItem?) {
        var item:TrackItem? = nil
        if (self.selectedIndex != nil ) {
           item = (self.dataSource?[(self.selectedIndex?.row)!] as? TrackItem)!
        }
        
        switch (sender?.tag)! {
            case 200: //del
            
            break
            case 100: //download
                SyncManager.sharedInstance.downloadPlaylist(self.album!)
            break
            case 10: //move
            
            break
            case 50: //play
                if let playItem = item {
                    Player.sharedInstance.PlayTrackStandalone(playItem)
                }
                else if let playItem:TrackItem = self.dataSource?[0] as! TrackItem? {
                    Player.sharedInstance.PlayTrackStandalone(playItem)
                }
            break
            case 60: //add to queue
                Player.sharedInstance.addTracksToPlayQueue(self.dataSource as! [TrackItem])
            break
            default:break
            
        }
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //let vc:ActivePlaylistController = segue.destination as! ActivePlaylistController
   
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
