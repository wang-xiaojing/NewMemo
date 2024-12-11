//
//  NewView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/07.
//

import SwiftUI

struct NewView: View {
    @State private var text: String = ""
    @State private var textEditorHeight: CGFloat = 60 // 3行分の高さ
    @State private var showCamera: Bool = false
    @State private var showPhoto: Bool = false
    @State private var showMic: Bool = false
    @State private var showTagSelector: Bool = false
    @State private var showLocation: Bool = false
    @State private var fontSize: CGFloat = 14
    @State private var fontColor: Color = .black
    @State private var backgroundColor: Color = .white
    @State private var textAlignment: TextAlignment = .leading
    @State private var showFontSettings: Bool = false

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(currentDateTimeString())
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
                GeometryReader { geometry in
                    let buttonCount = 9
                    let buttonWidth: CGFloat = 20
                    let spacing: CGFloat = 10 // ボタン間のスペーシング
                    let totalButtonWidth = (buttonWidth + spacing) * CGFloat(buttonCount)
                    let availableWidth = geometry.size.width
                    // FIXME
                    // ボタンが画面からはみ出す場合に2行に分けて表示する。
                    // iPhone Xs Max 実機では、上記計算が合わないようです。
                    if totalButtonWidth > availableWidth {
                        VStack {
                            HStack {
                                Button(action: {
                                    showCamera = true
                                }) {
                                    Image(systemName: "camera")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonWidth)
                                }
                                Button(action: {
                                    showPhoto = true
                                }) {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonWidth)
                                }
                                Button(action: {
                                    showMic = true
                                }) {
                                    Image(systemName: "music.microphone")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonWidth)
                                }
                                Button(action: {
                                    showTagSelector = true
                                }) {
                                    Image(systemName: "tag")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonWidth)
                                }
                                Button(action: {
                                    showLocation = true
                                }) {
                                    Image(systemName: "globe")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonWidth)
                                }
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                Button(action: {
                                    textAlignment = .leading
                                }) {
                                    Image(systemName: "text.justify.left")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonWidth)
                                }
                                Button(action: {
                                    textAlignment = .center
                                }) {
                                    Image(systemName: "text.aligncenter")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonWidth)
                                }
                                Button(action: {
                                    textAlignment = .trailing
                                }) {
                                    Image(systemName: "text.alignright")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonWidth)
                                }
                                Button(action: {
                                    showFontSettings = true
                                }) {
                                    Image(systemName: "textformat")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonWidth)
                                }
                            }
                        }
                    } else {
                        HStack {
                            Button(action: {
                                showCamera = true
                            }) {
                                Image(systemName: "camera")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonWidth)
                            }
                            Button(action: {
                                showPhoto = true
                            }) {
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonWidth)
                            }
                            Button(action: {
                                showMic = true
                            }) {
                                Image(systemName: "music.microphone")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonWidth)
                            }
                            Button(action: {
                                showTagSelector = true
                            }) {
                                Image(systemName: "tag")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonWidth)
                            }
                            Button(action: {
                                showLocation = true
                            }) {
                                Image(systemName: "globe")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonWidth)
                            }
                            Spacer()
                            Button(action: {
                                textAlignment = .leading
                            }) {
                                Image(systemName: "text.justify.left")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonWidth)
                            }
                            Button(action: {
                                textAlignment = .center
                            }) {
                                Image(systemName: "text.aligncenter")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonWidth)
                            }
                            Button(action: {
                                textAlignment = .trailing
                            }) {
                                Image(systemName: "text.alignright")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonWidth)
                            }
                            Button(action: {
                                showFontSettings = true
                            }) {
                                Image(systemName: "textformat")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonWidth)
                            }
                        }
                    }
                }
                // .frame(height: 80) // ボタンの高さを固定
                // .padding(.top)
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
            }
        }
        .padding()
        .onAppear {
            adjustTextEditorHeight()
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
        let languageCode = Locale.current.language.languageCode
        let regionCode = Locale.current.region?.identifier

        // FIXME
        // 下記言語による表示フォーマットの選択は、未完成です。
        // ここでは、地域コード（言語コードでは無い）でフォーマットを選択しており、誤り発生易い
        // iPhone XS Max / iOS 18.1.1 でデバッグしましたが、
        // 地域：日本 & 言語：日本語優先で　languageCode = en, regionCode = "JP" の結果となり。
        debugPrint("languageCode:\(languageCode ?? "?")")   // "languageCode:en"
        debugPrint("regionCode:\(regionCode ?? "?")")       // "regionCode:JP"
        
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
}

#Preview {
    NewView()
}

