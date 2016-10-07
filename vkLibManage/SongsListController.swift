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
    
    
    func reload()
    {
        if albumId == 0 {
            return
        }
        let audioReq:VKRequest = VKRequest.init(method: "audio.get", parameters: ["album_id":albumId])
        audioReq.execute(resultBlock: { (response) in
            print(response?.json)
            let k = TracksList.yy_model(withJSON: (response?.json as! Dic))
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
