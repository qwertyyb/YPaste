//
//  ListItemView.swift
//  YPaste
//
//  Created by marchyang on 2020/1/20.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Cocoa

class ListItemView: NSView {
    required init?(coder: NSCoder) {
        index = -1
        super.init(coder: coder)
    }
    override init(frame frameRect: NSRect) {
        index = -1
        super.init(frame: frameRect)
    }
    
    override func mouseDown(with event: NSEvent) {
        PasteboardHandler.shared.paste(pasteItem: pasteItem!)
        self.window?.windowController?.close()
    }
    
    private var pasteItem: PasteItem?
    private let titleView = NSTextField(string: "hello")
    
    private let headerView = NSStackView()
    
    private let deleteView = NSButton(image: NSImage(named: "NSStopProgressFreestandingTemplate")!, target: nil, action: #selector(delete))
    
    private let wrapper = NSView()
    
    let index: Int
    
    init(pasteItem: PasteItem, itemIndex: Int, enableActions: Bool = true) {
        index = itemIndex
        super.init(frame: .zero)
        self.pasteItem = pasteItem
        wantsLayer = true
        layer?.borderWidth = 3
        layer?.borderColor = .clear
        layer?.cornerRadius = 10
        
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.wantsLayer = true
        wrapper.layer?.borderColor = .clear
        wrapper.layer?.masksToBounds = true
        wrapper.layer?.cornerRadius = 6
        wrapper.layer?.backgroundColor = .white
        
        addSubview(wrapper)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 328),
            heightAnchor.constraint(equalToConstant: 228),
            wrapper.widthAnchor.constraint(equalToConstant: 320),
            wrapper.heightAnchor.constraint(equalToConstant: 220),
            wrapper.centerXAnchor.constraint(equalTo: centerXAnchor),
            wrapper.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        headerView.orientation = .horizontal
        headerView.wantsLayer = true
        headerView.spacing = 2
        headerView.edgeInsets = NSEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        headerView.layer?.backgroundColor = .init(red: 41/255, green: 128/255, blue: 185/255, alpha: 1)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 48),
            headerView.topAnchor.constraint(equalTo: wrapper.topAnchor),
            headerView.leftAnchor.constraint(equalTo: wrapper.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: wrapper.rightAnchor)
        ])

        let headerLeftView = NSStackView()
        headerLeftView.orientation = .vertical
        headerLeftView.alignment = .left
        headerLeftView.translatesAutoresizingMaskIntoConstraints = false
        headerLeftView.spacing = 0
        headerView.addView(headerLeftView, in: .leading)
        NSLayoutConstraint.activate([
            headerLeftView.widthAnchor.constraint(equalToConstant: 120),
            headerLeftView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        let typeView = NSTextField(string: "文本")
        typeView.backgroundColor = .clear
        typeView.alignment = .left
        typeView.textColor = .white
        typeView.font = .labelFont(ofSize: 14)
        typeView.isEditable = false
        typeView.isBordered = false
        headerLeftView.addView(typeView, in: .top)

        
        titleView.backgroundColor = .clear
        titleView.isBordered = false
        titleView.isEditable = false
        titleView.alignment = .left
        titleView.textColor = NSColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        titleView.font = .labelFont(ofSize: 10)
        titleView.attributedStringValue = NSAttributedString(string: TimeTransformer().transformedValue(self.pasteItem!.updated_at) as! String, attributes: [
            NSAttributedString.Key.baselineOffset: -2
        ])
        headerLeftView.addView(titleView, in: .bottom)
        
        var contentView: NSView?
        let headerBgLayer = CALayer()
        headerBgLayer.contents = NSImage(named: "item-text")
        headerBgLayer.position = .init(x: 310, y: 24)
        headerBgLayer.bounds = .init(x: 0, y: 0, width: 64, height: 64)
        headerView.layer?.addSublayer(headerBgLayer)
        headerView.layer?.masksToBounds = true
        
        typeView.stringValue = "文本"

        if let image = pasteItem.getImage() {
            typeView.stringValue = "图片"
            headerBgLayer.contents = NSImage(named: "item-image")
            let imageView = NSImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.wantsLayer = true
            imageView.shadow = NSShadow()
            imageView.layer?.shadowOpacity = 1.0
            imageView.layer?.shadowColor = NSColor.gray.cgColor
            imageView.layer?.shadowOffset = NSMakeSize(0, 0)
            imageView.layer?.shadowRadius = 12
            contentView = imageView
       } else {
            let textview = NSTextField()
            textview.maximumNumberOfLines = 16
            textview.allowsDefaultTighteningForTruncation = true
            textview.cell?.truncatesLastVisibleLine = true
            textview.attributedStringValue = NSAttributedString(string: SummaryTransformer().transformedValue(pasteItem.value ?? "") as! String)
        
            if let text = pasteItem.value {
                textview.stringValue = text
                headerBgLayer.contents = NSImage(named: "item-text")
                headerView.layer?.addSublayer(headerBgLayer)
                headerView.layer?.backgroundColor = .init(red: 68/255.0, green: 211/255.0, blue: 156/255.0, alpha: 1)
                headerView.layer?.masksToBounds = true
             } else {
                typeView.stringValue = "不支持的类型"
                textview.stringValue = "\(String(describing: pasteItem.type)) 类型暂不支持"
             }

            textview.isEditable = false
            textview.isBordered = false
            textview.backgroundColor = .white
            textview.translatesAutoresizingMaskIntoConstraints = false
            contentView = textview
        }
        wrapper.addSubview(contentView!)
        NSLayoutConstraint.activate([
            contentView!.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            contentView!.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -16),
            contentView!.leftAnchor.constraint(equalTo: wrapper.leftAnchor, constant: 16),
            contentView!.rightAnchor.constraint(equalTo: wrapper.rightAnchor, constant: -16)
        ])
    }
    
    private func addActionView () {
        headerView.setViews([deleteView], in: .trailing)
        
        deleteView.isBordered = false
        deleteView.image?.size = .init(width: 20, height: 20)
        deleteView.toolTip = "删除"
        deleteView.target = self
        
        NSLayoutConstraint.activate([
            deleteView.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -16),
            deleteView.widthAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    @objc func delete() {
        PasteItemsController.shared.deleteItem(pasteItem: pasteItem!)
    }
    
    func active () {
        layer?.borderColor = CGColor(red: 215/255, green: 219/255, blue: 221/255, alpha: 1)
        layer?.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.1)
        layer?.masksToBounds = true
        shadow = NSShadow()
        layer?.shadowOpacity = 1.0
        layer?.shadowColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        layer?.shadowOffset = NSMakeSize(0, 0)
        layer?.shadowRadius = 3
        addActionView()
    }
    func deactive () {
        layer?.borderColor = .clear
        layer?.backgroundColor = .clear
        headerView.setViews([], in: .trailing)
        shadow = nil
    }
}
