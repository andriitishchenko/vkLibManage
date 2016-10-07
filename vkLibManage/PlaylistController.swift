//
//  PlaylistController.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/7/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit


typealias Dic = Dictionary<String,AnyObject>

class PlaylistController:BaseTableController  {
    let cellId = "PlaylistCell"
    var selectedPlaylist:PlaylistItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reload()
        // Do any additional setup after loading the view.
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
    
    
    
    
    func reload()
    {
        let audioReq:VKRequest = VKRequest.init(method: "audio.getAlbums", parameters: [:])
        
        audioReq.execute(resultBlock: { (response) in
            print(response?.json)
            print(response?.parsedModel)
            
            
            
            let k = Playlist.yy_model(withJSON: (response?.json as! Dic))
            
            self.dataSource = k?.items
            
            self.tableView.reloadData()
            
        }) { (err) in
            
            
            if ((err as! NSError).code != Int(VK_API_ERROR)) {
                print("VK TRY REPEAT: %@",err?.localizedDescription)
                (err as! VKError).request.repeat()
            } else {
                print("VK error: %@",err?.localizedDescription)
            }
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
