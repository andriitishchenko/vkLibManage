//
//  API.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/7/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import Foundation

class API{
    
    func getUserAlbums(seccess:()->Void, fail:()->Void){
        let audioReq:VKRequest = VKRequest.init(method: "audio.getAlbums", parameters: [:])
        
        audioReq.execute(resultBlock: { (response) in
            print(response?.json)
            
            var a = 1
            
            
            
        }) { (err) in
            
            
            if ((err as! NSError).code != Int(VK_API_ERROR)) {
                print("VK TRY REPEAT: %@",err?.localizedDescription)
                (err as! VKError).request.repeat()
            } else {
                print("VK error: %@",err?.localizedDescription)
            }
        }

    }
}
