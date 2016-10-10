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
    
    var albumId:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reload()
        self.pullRefreshInection()
        // Do any additional setup after loading the view.
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
        
        return cell
    }
    
    
    override func reload()
    {
        DBManager.sharedInstance.getLocalTracks(playlist_id: self.albumId) { list in
            self.dataSource = list
            self.tableView.reloadData()
        }
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
