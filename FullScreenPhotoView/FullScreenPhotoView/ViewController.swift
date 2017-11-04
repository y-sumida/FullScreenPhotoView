//
//  ViewController.swift
//  FullScreenPhotoView
//
//  Created by Yuki Sumida on 2017/11/04.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapGesture(_:)))
            imageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func tapGesture(_ gesture: UITapGestureRecognizer) {
            guard let image = imageView.image else { return }
            let photoView = FullScreenPhotoView(image: image)
            photoView.open()
        }
}

