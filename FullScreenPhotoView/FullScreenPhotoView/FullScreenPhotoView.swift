//
//  FullScreenPhotoView.swift
//  FullScreenPhotoView
//
//  Created by Yuki Sumida on 2017/11/04.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit

class FullScreenPhotoView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    // const
    private let screenSize: CGRect = UIScreen.main.bounds
    
    // views
    private var baseView: UIView = UIView()
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!
    private var contentView: UIView = UIView()

    // state
    var startPanPoint: CGPoint!
    var imageViewOrigin: CGPoint!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(image: UIImage) {
        let screenFrame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        super.init(frame: screenFrame)
        initViews(screenFrame: screenFrame, image: image)
    }
    
    private func initViews(screenFrame: CGRect, image: UIImage) {
        baseView.frame = CGRect(x: 0, y: 0, width: screenFrame.size.width, height: screenFrame.size.height)
        self.addSubview(baseView)
        self.sendSubview(toBack: baseView)
        baseView.backgroundColor = UIColor.black
        
        imageView = UIImageView(image:image)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        let x = (screenFrame.width - image.size.width) / 2.0
        let y = (screenFrame.height - image.size.height) / 2.0
        imageViewOrigin = CGPoint(x:x, y: y)
        imageView.frame = CGRect(x: imageViewOrigin.x, y: imageViewOrigin.y, width: image.size.width, height: image.size.height)
        imageView.isUserInteractionEnabled = true

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(FullScreenPhotoView.closeSwipeGesture(_:)))
        panGesture.delegate = self
        imageView.addGestureRecognizer(panGesture)

        contentView.frame = screenFrame
        contentView.addSubview(imageView)
        contentView.addGestureRecognizer(panGesture)

        scrollView = UIScrollView(frame: screenFrame)
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 2
        scrollView.zoomScale = 1
        scrollView.contentSize = imageView.bounds.size
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(contentView)
        self.addSubview(scrollView)
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 縦スワイプ判定
        let panRecog = gestureRecognizer as! UIPanGestureRecognizer
        let direction = panRecog.velocity(in: panRecog.view)
        return abs(direction.y) > abs(direction.x)
    }
    // 上下スワイプで閉じる
    @objc func closeSwipeGesture(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: gesture.view?.superview)

        guard scrollView.zoomScale == 1 else { return }

        switch gesture.state {
        case .began:
            startPanPoint = point
            
        case .changed:
            // 画像を指に追従させる
            let dy = point.y - startPanPoint.y
            imageView.frame.origin = CGPoint(x: imageViewOrigin.x, y: imageViewOrigin.y + dy)
            
            // 移動量に合わせて背景のアルファ値を変更
            let p = screenSize.height / 100
            let alpha = 1 - abs(dy) / p / 200
            baseView.alpha = alpha
            
        case .ended:
            let dy = point.y - startPanPoint.y
            let threshold = screenSize.size.height / 4
            if abs(dy) >= threshold {
                // 移動量が画面の1/4を超えていたら閉じる
                self.close(imageView: imageView, dy: dy)
            } else {
                // ジェスチャーが速かったら閉じる
                let velocityY: CGFloat = gesture.velocity(in: gesture.view).y
                if abs(velocityY) >= 800 {
                    close(imageView: imageView, dy: velocityY)
                } else {
                    // もとに戻す
                    baseView.alpha = 1
                    self.imageViewToOriginAnimation(imageView: imageView)
                }
            }
        default:
            break
        }
    }
    
    func open() {
        self.alpha = 0
        let window = UIApplication.shared.keyWindow!
        window.addSubview(self)
        UIView.animate(withDuration: 0.3, animations: { self.alpha = 1.0 })
    }
    
    private func imageViewToOriginAnimation(imageView: UIView) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                imageView.frame.origin = self.imageViewOrigin
        }) { _ in }
    }
    
    private func close(imageView: UIView? = nil, dy: CGFloat? = nil) {
        if let imageView: UIView = imageView, let dy: CGFloat = dy {
            closeImageViewAnimation(imageView: imageView, dy: dy)
            closeFullScreenPhotoViewAnimation()
        } else {
            closeFullScreenPhotoViewAnimation()
        }
    }
    
    private func closeImageViewAnimation(imageView: UIView, dy: CGFloat) {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                if dy.sign == .plus {
                    imageView.frame.origin = CGPoint(x: 0, y: self.screenSize.height)
                } else {
                    imageView.frame.origin = CGPoint(x: 0, y: -imageView.frame.size.height)
                }
                imageView.alpha = 0
        })
    }
    
    private func closeFullScreenPhotoViewAnimation() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.alpha = 0
        }, completion: { _ in self.removeFromSuperview() })
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let x = (screenSize.width - imageView.frame.size.width) / 2.0
        let y = (screenSize.height - imageView.frame.size.height) / 2.0

        imageView.frame = CGRect(x: x > 0 ? x : 0, y: y > 0 ? y : 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print(scale)
        if scale == 1.0 {
            imageView.frame = CGRect(x: imageViewOrigin.x, y: imageViewOrigin.y, width: imageView.frame.size.width, height: imageView.frame.size.height)
        }
    }
}
