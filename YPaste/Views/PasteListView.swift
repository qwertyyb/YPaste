//
//  PasteListView.swift
//  YPaste
//
//  Created by 虚幻 on 2020/10/31.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import SwiftUI
import Combine
import Carbon
import RealmSwift

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

// Environment key to hold even publisher
struct keyEventPublisherKey: EnvironmentKey {
    static let defaultValue: PassthroughSubject<NSEvent, Never> = PassthroughSubject<NSEvent, Never>() // just default stub
}


// Environment value for keyPublisher access
extension EnvironmentValues {
    var keyPublisher: PassthroughSubject<NSEvent, Never> {
        get { self[keyEventPublisherKey.self] }
        set { self[keyEventPublisherKey.self] = newValue }
    }
}
struct DelayedAnimation: ViewModifier {
  var delay: Double
  var animation: Animation

  @State private var animating = false

  func delayAnimation() {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      self.animating = true
    }
  }

  func body(content: Content) -> some View {
    content
      .animation(animating ? animation : nil)
      .onAppear(perform: delayAnimation)
  }
}

extension View {
  func delayedAnimation(delay: Double = 1.0, animation: Animation = .default) -> some View {
    self.modifier(DelayedAnimation(delay: delay, animation: animation))
  }
}

final class PasteItemListSource: ObservableObject {
    @Published var list: [MPasteItem] = []

    private var cancellable: AnyCancellable?
    init() {
        cancellable = try! Realm().objects(MPasteItem.self).sorted(byKeyPath: "updated_at", ascending: false)
            .collectionPublisher
//            .subscribe(on: DispatchQueue(label: "background queue"))
            .freeze()
            .map { pasteItems in
//                print(pasteItems)
                return Array(pasteItems)
//                Dictionary(grouping: dogs, by: { $0.age }).map { DogGroup(label: "\($0)", dogs: $1) }
            }
            .receive(on: DispatchQueue.main)
            .assertNoFailure()
            .assign(to: \.list, on: self)
    }
    deinit {
        cancellable?.cancel()
    }
}


struct PasteListView: View {
    @State var selectedIndex = 0
    
    @State private var predicate: NSPredicate = NSPredicate(format: "type != 'aaaa'")
    
    @State private var keyword = ""
    
    private var filteredList: Results<MPasteItem> {
        try! Realm().objects(MPasteItem.self).filter(predicate).sorted(byKeyPath: "updated_at", ascending: false)
    }
    
//    @EnvironmentObject private var store: Store

    // MARK: Core Data性能太差，后面建议弃用
    var body: some View {
        VStack {
            Spacer()
            TextField("enter keyword", text: $keyword, onCommit: {
                updatePredicate()
            })
            .textFieldStyle(PlainTextFieldStyle())
            .padding([.leading, .trailing], 12)
            .padding([.top, .bottom], 8)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray))
            .padding([.leading, .trailing], 24)
            
            // MARK: 大数组性能太差，后面应该使用lazyVStack
            List(
                filteredList.prefix(15),
                id: \.self
            ) { (pasteItem) in
                PasteItemView(selected: false, pasteItem: pasteItem)
            }
            .onReceive(GlobalPublisher.shared.keyEventPublisher) { event in // << listen to events
                keyDown(event)
            }
            .id(UUID())
        }
        .background(Color.white)
    }
    
    func updatePredicate() {
        predicate = self.keyword.count > 0
            ? NSPredicate(format: "value contains[cd] %@", self.keyword)
            : NSPredicate(format: "type != 'aaaaa'")
    }
    
    func keyDown(_ event: NSEvent) {
        print(event)
        switch (Int(event.keyCode)) {
        case kVK_DownArrow:
            selectedIndex += 1
            break
        case kVK_UpArrow:
            selectedIndex = selectedIndex <= 0 ? 0 : selectedIndex - 1
            break
        case kVK_Return:
            print("paste item")
        default:
            print(event)
        }
    }
}

struct PasteListView_Previews: PreviewProvider {
    static var previews: some View {
        PasteListView()
    }
}
