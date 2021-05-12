//
//  PushNextViewController.swift
//  YCPhotoBrowser
//
//  Created by Loveying on 05/11/2021.
//  Copyright (c) 2021 Loveying. All rights reserved.
//

import UIKit
import YCPhotoBrowser

class PushNextViewController: BaseCollectionViewController {

    override var name: String { "带导航栏Push" }
    
    override var remark: String { "让lantern嵌入导航控制器里，Push到下一页" }
    
    override func makeDataSource() -> [ResourceModel] {
        makeLocalDataSource()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.fc.dequeueReusableCell(BaseCollectionViewCell.self, for: indexPath)
        cell.imageView.image = self.dataSource[indexPath.item].localName.flatMap { UIImage(named: $0) }
        return cell
    }
    
    override func openPhotoBrowser(with collectionView: UICollectionView, indexPath: IndexPath) {
        let browser = YCPhotoBrowser()
        browser.numberOfItems = {
            self.dataSource.count
        }
        browser.reloadCellAtIndex = { context in
            guard let photoCell = context.cell as? YCPhotoImageCell else {
                return
            }
            let indexPath = IndexPath(item: context.index, section: indexPath.section)
            photoCell.imageView.image = self.dataSource[indexPath.item].localName.flatMap { UIImage(named: $0) }
            // 添加长按事件
            photoCell.longPressedAction = { cell, _ in
                self.longPress(cell: cell)
            }
        }
        browser.transitionAnimator = YCPhotoZoomAnimator(previousView: { index -> UIView? in
            let path = IndexPath(item: index, section: indexPath.section)
            let cell = collectionView.cellForItem(at: path) as? BaseCollectionViewCell
            return cell?.imageView
        })
        browser.pageIndex = indexPath.item
        // 让lantern嵌入当前的导航控制器里
        browser.show(method: .push(inNC: nil))
    }
    
    private func longPress(cell: YCPhotoImageCell) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "查看详情", style: .destructive, handler: { _ in
            let detail = MoreDetailViewController()
            cell.browser?.navigationController?.pushViewController(detail, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        cell.browser?.present(alert, animated: true, completion: nil)
    }
}
