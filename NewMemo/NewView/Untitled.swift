//
//  NewView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/07.
//

import SwiftUI

struct NewView_: View {
    @State private var text: String = ""
    @State private var textEditorHeight: CGFloat = 60 // 3行分の高さ
    @State private var showCamera: Bool = false
    @State private var showPhoto: Bool = false
    @State private var showMic: Bool = false
    @State private var showTagSelector: Bool = false
    @State private var showLocation: Bool = false

    @State private var fontSize: CGFloat = 10
    @State private var fontColor: Color = .black
    @State private var backgroundColor: Color = .white
    @State private var textAlignment: TextAlignment = .leading
    @State private var showFontSettings: Bool = false

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(currentDateTimeString())
                HStack {
                    Spacer()
                    Button(action: {
                        textAlignment = .leading
                    }) {
                        Image(systemName: "text.justify.left")
                    }
                    Button(action: {
                        textAlignment = .center
                    }) {
                        Image(systemName: "text.aligncenter")
                    }
                    Button(action: {
                        textAlignment = .trailing
                    }) {
                        Image(systemName: "text.alignright")
                    }
                    Button(action: {
                        showFontSettings = true
                        hideKeyboard()
                    }) {
                        Image(systemName: "textformat")
                    }
                }
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(height: textEditorHeight)
                        .font(.system(size: fontSize))
                        .foregroundColor(fontColor)
                        .background(backgroundColor)
                        .multilineTextAlignment(textAlignment)
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear {
                                textEditorHeight = geometry.size.height
                            }
                        })
                        .onChange(of: text) {
                            adjustTextEditorHeight()
                        }
                        .onTapGesture {
                            showFontSettings = false
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSetting.cornerRadius)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    if text.isEmpty {
                        // プレースホルダとして表示するTextを表示
                        Text(" Enter text here")
                            .foregroundColor(.gray)
                    }
                }
                HStack {
                    Button(action: {
                        showCamera = true
                    }) {
                        Image(systemName: "camera")
                    }
                    Button(action: {
                        showPhoto = true
                    }) {
                        Image(systemName: "photo")
                    }
                    Button(action: {
                        showMic = true
                    }) {
                        Image(systemName: "music.microphone")
                    }
                    Button(action: {
                        showTagSelector = true
                    }) {
                        Image(systemName: "tag")
                    }
                    Button(action: {
                        showLocation = true
                    }) {
                        Image(systemName: "globe")
                    }
                    Spacer()
                }
            }
            Spacer()
            if showFontSettings {
                VStack {
                    Text("書式設定")
                    HStack {
                        Text("フォントサイズ")
                        Slider(value: $fontSize, in: 10...30, step: 1)
                    }
                    HStack {
                        Text("フォントカラー")
                        ColorPicker("", selection: $fontColor)
                            .labelsHidden()
                    }
                    HStack {
                        Text("背景色")
                        ColorPicker("", selection: $backgroundColor)
                            .labelsHidden()
                    }
                    Button(action: {
                        showFontSettings = false
                    }) {
                        Text("閉じる")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding()
                .onAppear {
                    hideKeyboard()
                }
            }
        }
        .padding()
        .onAppear {
            adjustTextEditorHeight()
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
        .overlay(
            Group {
                if showCamera {
                    VStack {
                        Text("showCamera")
                        Button(action: {
                            showCamera = false
                        }) {
                            Text("戻る")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.9))
                    .edgesIgnoringSafeArea(.all)
                } else if showPhoto {
                    VStack {
                        Text("showPhoto")
                        Button(action: {
                            showPhoto = false
                        }) {
                            Text("戻る")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.9))
                    .edgesIgnoringSafeArea(.all)
                } else if showMic {
                    VStack {
                        Text("showMic")
                        Button(action: {
                            showMic = false
                        }) {
                            Text("戻る")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.9))
                    .edgesIgnoringSafeArea(.all)
                } else if showTagSelector {
                    VStack {
                        Text("showTagSelector")
                        Button(action: {
                            showTagSelector = false
                        }) {
                            Text("戻る")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.9))
                    .edgesIgnoringSafeArea(.all)
                } else if showLocation {
                    VStack {
                        Text("showLocation")
                        Button(action: {
                            showLocation = false
                        }) {
                            Text("戻る")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.9))
                    .edgesIgnoringSafeArea(.all)
                }
            }
        )
    }

    private func adjustTextEditorHeight() {
        let lineHeight = calculateLineHeight()
        let maxLines: CGFloat = 10 + 1
        let minLines: CGFloat = 3 + 1
        let minHeight: CGFloat = lineHeight * minLines
        let maxHeight: CGFloat = lineHeight * maxLines

        let textHeight = (CGFloat(text.split(separator: "\n").count) + 1) * lineHeight
        textEditorHeight = min(max(textHeight, minHeight), maxHeight)
    }

    private func calculateLineHeight() -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .body)
        return font.lineHeight
    }

    private func currentDateTimeString() -> String {
        let formatter = DateFormatter()
        let languageCode = Locale.current.language.languageCode?.identifier
        let regionCode = Locale.current.region?.identifier

        if languageCode == "ja" || regionCode == "JP" {
            formatter.dateFormat = "yyyy年MM月dd日 EEEE HH:mm"
            formatter.locale = Locale(identifier: "ja_JP")
        } else if languageCode == "zh" || regionCode == "CN" || regionCode == "TW" {
            formatter.dateFormat = "yyyy年MM月dd日 EEEE HH:mm"
            formatter.locale = Locale(identifier: "zh_CN")
        } else {
            formatter.dateFormat = "yyyy/MM/dd EEEE HH:mm"
            formatter.locale = Locale(identifier: "en_US")
        }

        return formatter.string(from: Date())
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            showFontSettings = false
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
}

#Preview {
    NewView()
}

