//
//  Untitled.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/12.
//
import SwiftUI
import UIKit

struct AttributedTextEditor: UIViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat
    var fontColor: UIColor
    var isBold: Bool
    var isItalic: Bool
    var isUnderline: Bool
    var textAlignment: NSTextAlignment

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.returnKeyType = .done  // リターンキーを「完了」に設定

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        var traits: UIFontDescriptor.SymbolicTraits = []

        if isBold {
            traits.insert(.traitBold)
        }
        if isItalic {
            traits.insert(.traitItalic)
        }

        let descriptor = fontDescriptor.withSymbolicTraits(traits) ?? fontDescriptor
        let font = UIFont(descriptor: descriptor, size: fontSize)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fontColor,
            .underlineStyle: isUnderline ? NSUnderlineStyle.single.rawValue : 0,
            .paragraphStyle: paragraphStyle
        ]

        uiView.attributedText = NSAttributedString(string: text, attributes: attributes)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AttributedTextEditor

        init(_ parent: AttributedTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {  // リターンキーが押されたとき
                textView.resignFirstResponder()  // キーボードを閉じる
                return false
            }
            return true
        }
    }
}
