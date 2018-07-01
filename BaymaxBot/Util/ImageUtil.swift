//
//  ImageUtil.swift
//  BaymaxBot
//
//  Created by 石島樹 on 2018/07/01.
//  Copyright © 2018年 石島樹. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resizeImage(resize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(resize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: resize.width, height: resize.height));
        let resizedImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resizedImage;
    }
    
    func scaleImage(scaleSize:CGFloat) -> UIImage {
        let resize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return resizeImage(resize: resize)
    }
}
