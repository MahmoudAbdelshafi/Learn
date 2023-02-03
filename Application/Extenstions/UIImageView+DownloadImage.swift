//
//  UIImageView+DownloadImage.swift
//  Learn
//
//  Created by Mahmoud Abdelshafi on 01/02/2023.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func downloadImage(withUrl urlString : String?) {
        self.image = nil
        let urlString = urlString ?? ""
        guard let url = URL(string: urlString) else {return}
        self.image = nil
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString)  {
            self.image = cachedImage
            return
        }
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .medium)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.center = self.center

        // if not, download image from url
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data ?? Data()) {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                    activityIndicator.removeFromSuperview()
                }
            }
        }).resume()
    }
}

