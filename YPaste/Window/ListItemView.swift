//
//  ListItemView.swift
//  YPaste
//
//  Created by marchyang on 2020/1/20.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Cocoa

class ListItemView: NSStackView, NSStackViewDelegate {
    required init?(coder: NSCoder) {
        index = -1
        super.init(coder: coder)
    }
    override init(frame frameRect: NSRect) {
        index = -1
        super.init(frame: frameRect)
    }
    
    override func mouseDown(with event: NSEvent) {
//        PasteboardHandler.shared.paste(pasteItem: pasteItem!)
        self.window?.windowController?.close()
    }
    
    private var pasteItem: PasteItem?
    private let titleView = NSTextField(string: "hello")
    
    private let topView = NSStackView()
    
    private let favoriteView = NSButton(image: NSImage(named: "favoriteOff")!, target: nil, action: #selector(favorite))
    private let deleteView = NSButton(image: NSImage(named: "delete")!, target: nil, action: #selector(delete))
    
    let index: Int
    init(pasteItem: PasteItem, itemIndex: Int, enableActions: Bool = true) {
        index = itemIndex
        super.init(frame: .zero)
    
        orientation = .vertical
        alignment = .left
        spacing = 0
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.cornerRadius = 4
        delegate = self
        
        self.pasteItem = pasteItem
        
        
        NSLayoutConstraint.activate([
            topView.heightAnchor.constraint(equalToConstant: 24),
            topView.widthAnchor.constraint(equalToConstant: (self.window?.frame.width ?? 400) - 48)
        ])
        
        topView.orientation = .horizontal
        topView.wantsLayer = true
        topView.spacing = 2
        topView.layer?.backgroundColor = .init(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        addView(topView, in: .leading)
        
        titleView.backgroundColor = .clear
        titleView.isBordered = false
        titleView.isEditable = false
        titleView.textColor = .init(red: 0, green: 0, blue: 0, alpha: 0.4)
        titleView.attributedStringValue = NSAttributedString(string: TimeTransformer().transformedValue(self.pasteItem!.updated_at) as! String, attributes: [
            NSAttributedString.Key.baselineOffset: -2
        ])
        topView.addView(titleView, in: .leading)
        
        let textview = NSTextField()
        textview.maximumNumberOfLines = 2
        textview.allowsDefaultTighteningForTruncation = true
        textview.cell?.truncatesLastVisibleLine = true
        textview.attributedStringValue = NSAttributedString(string: SummaryTransformer().transformedValue(pasteItem.value ?? "") as! String)
        
        textview.isEditable = false
        textview.isBordered = false
        textview.backgroundColor = .white
        addView(textview, in: .trailing)
        NSLayoutConstraint.activate([
            textview.widthAnchor.constraint(equalTo: topView.widthAnchor),
            textview.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        if enableActions {
            addActionView()
        }
    }
    
    private func addActionView () {
        topView.setViews([favoriteView, deleteView], in: .trailing)
        
        deleteView.isBordered = false
        deleteView.image?.size = .init(width: 16, height: 16)
        deleteView.toolTip = "删除"
        deleteView.target = self
        
        favoriteView.isBordered = false
        favoriteView.image?.size = .init(width: 16, height: 16)
        favoriteView.toolTip = "收藏"
        favoriteView.target = self
        
        NSLayoutConstraint.activate([
            deleteView.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -4),
            deleteView.widthAnchor.constraint(equalToConstant: 18)
        ])
        NSLayoutConstraint.activate([
            favoriteView.widthAnchor.constraint(equalToConstant: 18),
        ])
        
        if pasteItem?.favorite == true {
            favoriteView.image = NSImage(named: "favoriteOn")
        }
    }
    
    @objc func favorite() {
        PasteItemsController.shared.favoriteItem(pasteItem: pasteItem!, favorite: !pasteItem!.favorite)
        favoriteView.image = pasteItem?.favorite == true ? NSImage(named: "favoriteOn") : NSImage(named: "favoriteOff")
    }
    
    @objc func delete() {
        PasteItemsController.shared.deleteItem(pasteItem: pasteItem!)
    }
    
    func active () {
        topView.layer?.backgroundColor = .init(red: 0.11, green: 0.56, blue: 1, alpha: 1)
        titleView.textColor = .white
    }
    func deactive () {
        titleView.textColor = .init(red: 0, green: 0, blue: 0, alpha: 0.4)
        topView.layer?.backgroundColor = .init(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
    }
    
    override func viewWillDraw() {
        
    }
}
