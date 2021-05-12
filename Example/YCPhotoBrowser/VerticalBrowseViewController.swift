//
//  VerticalBrowseViewController.swift
//  YCPhotoBrowser
//
//  Created by Loveying on 05/11/2021.
//  Copyright (c) 2021 Loveying. All rights reserved.
//

import UIKit
import YCPhotoBrowser
import AVKit

class VerticalBrowseViewController: BaseCollectionViewController {
    
    override var name: String { "竖向浏览视频" }
    
    override var remark: String { "抖音的浏览方式" }
    
    override func makeDataSource() -> [ResourceModel] {
        var result: [ResourceModel] = []
        (0..<6).forEach { index in
            let model = ResourceModel()
            model.localName = "video_\(index % 3)"
            result.append(model)
        }
        return result
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.fc.dequeueReusableCell(BaseCollectionViewCell.self, for: indexPath)
        if let url = Bundle.main.url(forResource: self.dataSource[indexPath.item].localName, withExtension: "MP4") {
            cell.imageView.image = self.getVideoCropPicture(videoUrl: url)
            cell.playButtonView.isHidden = false
        }
        return cell
    }
    
    override func openPhotoBrowser(with collectionView: UICollectionView, indexPath: IndexPath) {
        let browser = YCPhotoBrowser()
        // 指定滑动方向为垂直
        browser.scrollDirection = .vertical
        browser.numberOfItems = {
            self.dataSource.count
        }
        browser.cellClassAtIndex = { index in
            VideoCell.self
        }
        browser.reloadCellAtIndex = { context in
            YCPhotoBrowserLog.high("reload cell!")
            let resourceName = self.dataSource[context.index].localName!
            let photoCell = context.cell as? VideoCell
            if let url = Bundle.main.url(forResource: resourceName, withExtension: "MP4") {
                photoCell?.player.replaceCurrentItem(with: AVPlayerItem(url: url))
            }
        }
        browser.cellWillAppear = { cell, index in
            YCPhotoBrowserLog.high("开始播放")
            (cell as? VideoCell)?.player.play()
        }
        browser.cellWillDisappear = { cell, index in
            YCPhotoBrowserLog.high("暂停播放")
            (cell as? VideoCell)?.player.pause()
        }
        browser.transitionAnimator = YCPhotoZoomAnimator(previousView: { index -> UIView? in
            let path = IndexPath(item: index, section: indexPath.section)
            let cell = collectionView.cellForItem(at: path) as? BaseCollectionViewCell
            return cell?.imageView
        })
        browser.pageIndex = indexPath.item
        browser.show()
    }
    // MARK: 获取视频预览图
    fileprivate func getVideoCropPicture(videoUrl: URL) -> UIImage? {
        let avAsset = AVURLAsset(url: videoUrl)
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        var actualTime: CMTime = CMTimeMake(value: 0, timescale: 0)
        if let imageP = try? generator.copyCGImage(at: time, actualTime: &actualTime) {
            return UIImage(cgImage: imageP)
        }
        return nil
    }
}
