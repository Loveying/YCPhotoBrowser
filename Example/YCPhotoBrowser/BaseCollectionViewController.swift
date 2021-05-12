//
//  BaseCollectionViewController.swift
//  YCPhotoBrowser
//
//  Created by Loveying on 05/11/2021.
//  Copyright (c) 2021 Loveying. All rights reserved.
//

import UIKit

class BaseCollectionViewController: UICollectionViewController {

    /// 数据源
    var dataSource: [ResourceModel] = []
    
    /// 名称
    var name: String {
        return ""
    }
    
    /// 说明
    var remark: String {
        return ""
    }
    
    let reusedId = "reused"
    
    private var flowLayout: UICollectionViewFlowLayout
    
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        self.flowLayout = flowLayout
        super.init(collectionViewLayout: flowLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = name
        collectionView?.backgroundColor = .black
        collectionView?.fc.registerCell(BaseCollectionViewCell.self)
        dataSource = makeDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let insetValue: CGFloat = 15
        let totalWidth: CGFloat = view.bounds.width - insetValue * 2
        let colCount = 2
        let spacing: CGFloat = 8.0
        let sideLength: CGFloat = (totalWidth - 2 * spacing) / CGFloat(colCount)
        
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.itemSize = CGSize(width: sideLength, height: 200)
        flowLayout.sectionInset = UIEdgeInsets.init(top: insetValue, left: insetValue, bottom: insetValue, right: insetValue)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    // 子类重写
    func makeDataSource() -> [ResourceModel] {
        return []
    }
    
    func makeLocalDataSource() -> [ResourceModel] {
        var result: [ResourceModel] = []
        (0..<6).forEach { index in
            let model = ResourceModel()
            model.localName = "local_\(index)"
            result.append(model)
        }
        return result
    }
    
    func makeNetworkDataSource() -> [ResourceModel] {
        var result: [ResourceModel] = []
        guard let url = Bundle.main.url(forResource: "Photos", withExtension: "plist") else {
            return result
        }
        guard let data = try? Data.init(contentsOf: url) else {
            return result
        }
        let decoder = PropertyListDecoder()
        guard let array = try? decoder.decode([[String]].self, from: data) else {
            return result
        }
        array.forEach { item in
            let model = ResourceModel()
            model.firstLevelUrl = item[0]
            model.secondLevelUrl = item[1]
            result.append(model)
        }
        return result
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        openPhotoBrowser(with: collectionView, indexPath: indexPath)
    }
    
    // 子类重写
    func openPhotoBrowser(with collectionView: UICollectionView, indexPath: IndexPath) {}
}
