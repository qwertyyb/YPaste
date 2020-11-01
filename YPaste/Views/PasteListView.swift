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

//struct KeyboardEvent: NSViewRepresentable {
//    @Binding private var event: NSEvent
//    init(_ event: Binding<NSEvent>) {
//        self._event = event
//    }
//    class KeyView: NSView {
//        var owner: KeyboardEvent?   // << view holder
//        override var acceptsFirstResponder: Bool { true }
//        override func keyDown(with event: NSEvent) {
//            super.keyDown(with: event)
//            print(">> key \(event)")
//            owner?.event = event
//        }
//    }
//
//    func makeNSView(context: Context) -> NSView {
//        let view = KeyView()
//        view.owner = self
//        DispatchQueue.main.async { // wait till next event cycle
//            view.window?.makeFirstResponder(view)
//        }
//        return view
//    }
//
//    func updateNSView(_ nsView: NSView, context: Context) {
//    }
//}

struct FilteredList<T: NSManagedObject, Content: View>: View {
    var fetchRequest: FetchRequest<T>
    var items: FetchedResults<T> { fetchRequest.wrappedValue }

    let content: (Int, T) -> Content

    var body: some View {
        let list = items.count >= 100 ? items[0...100] : items[0...]
        return List(Array(list.enumerated()), id: \.element) { (index, item) in
            self.content(index, item)
        }
        .delayedAnimation(delay: 0.2, animation: .easeInOut)
        .id(UUID())
    }

    init(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor] = [], @ViewBuilder content: @escaping (Int, T) -> Content) {
        fetchRequest = FetchRequest<T>(entity: T.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
        self.content = content
    }
}

struct SearchView: View {
    @EnvironmentObject private var store: Store
    
    private let placeholderColor = Color.gray
    private let inputColor = Color.primary
    var body: some View {
        let isInput = store.keyword.count > 0
        return VStack(alignment: .center) {
            Text(isInput ? store.keyword : "enter keyword")
                .frame(
                    minWidth: 0,
                    maxWidth: 360,
                    minHeight: 28,
                    maxHeight: 28,
                    alignment: .leading
                )
                .padding(12)
                .foregroundColor(isInput ? inputColor : placeholderColor)
        }
        .frame(
            minWidth: 0,
            minHeight: 28,
            maxHeight: 28,
            alignment: .leading
        )
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray))
    }
}


struct PasteListView: View {
    @State var selectedIndex = 0
    
    @State private var predicate: NSPredicate = NSPredicate(format: "type != 'aaaa'")
    
    @State private var keyword = ""
    
    private let realm = try! Realm()
    
//    @Environment(\.keyPublisher) private var keyEventPublisher
    
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
            
            List(realm.objects(MPasteItem.self).filter(predicate), id: \.self) { (pasteItem) in
                PasteItemView(selected: false, pasteItem: pasteItem)
            }
            
//            FilteredList<PasteItem, PasteItemView>(
//                predicate: predicate,
//                sortDescriptors: [NSSortDescriptor(key: "updated_at", ascending: false)]
//            ) { (index, pasteItem) in
//                PasteItemView(selected: index == selectedIndex, pasteItem: pasteItem)
//            }
//            .onReceive(
//                GlobalPublisher.shared.keywordPublisher
//                    .debounce(for: 0.4, scheduler: DispatchQueue.main)
//                    .removeDuplicates()
//            ) { (keyword) in
//                updatePredicate(keyword)
//            }
        }
        .onReceive(GlobalPublisher.shared.keyEventPublisher) { event in // << listen to events
            keyDown(event)
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
