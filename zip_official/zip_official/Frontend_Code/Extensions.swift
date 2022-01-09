//
//  Extensions.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/7/21.
//

import Foundation
import UIKit
import DropDown
import RSKImageCropper


extension UIScrollView {
    func updateContentView(_ buffer: CGFloat = 0) {
        contentSize.height = (subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height) + buffer
    }
}

extension RSKImageCropViewController {
    public func setBackgroundColor(_ color : UIColor){
        view.backgroundColor = color
    }
}


extension Notification.Name {
    /// Notification when user logs in
    static let didLogInNotification = Notification.Name("didLogInNotification")
}


class ResizeSlider: UISlider {
  @IBInspectable var trackHeight: CGFloat = 2

  override func trackRect(forBounds bounds: CGRect) -> CGRect {
    return CGRect(origin: CGPoint(x: 0, y: bounds.midY), size: CGSize(width: bounds.width, height: trackHeight))
  }
}
