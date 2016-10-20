//
//  Utils.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 10/20/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit

class Utils: NSObject {

}

extension FileManager {
    static func isFileExistForID(_ id:Int) -> Bool{
        let filepath = FileManager.makeFilePathForID(id)
        let url : URL = URL(fileURLWithPath: filepath as String)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    static func makeFilePathForID(_ id:Int)->String{
        let fname = FileManager.makeFileNameForID(id);
        return MZUtility.baseFilePath.appending(fname)
    }
    
    static func makeFileNameForID(_ id:Int)->String{
        return String(id).appending(".mp3")
    }
}
