//
//  PlayerControlsView.swift
//  vkLibManage
//
//  Created by Andrii Tiischenko on 11/1/16.
//  Copyright © 2016 Andrii Tiischenko. All rights reserved.
//

import UIKit

class PlayerControlsView: UIView {
  
  @IBOutlet weak var labelArtist: UILabel!
  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var labelTime: UILabel!
  
  @IBOutlet weak var sliderTime: UISlider!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  @IBAction func buttonDidTouch(_ sender: UIButton) {
    switch sender.tag {
    case 10:
        Player.sharedInstance.stop();
        break;
    case 20:
        Player.sharedInstance.playPrev()
        break;
    case 30:
        Player.sharedInstance.play()
        break;
    case 40:
        Player.sharedInstance.playNext()
        break;
    default:break
        
    }
  }

}
