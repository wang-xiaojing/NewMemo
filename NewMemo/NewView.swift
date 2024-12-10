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

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(currentDateTimeString())
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .frame(height: textEditorHeight)
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
                        Text(" ここに入力してください")
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
        }
        .padding()
        .onAppear {
            adjustTextEditorHeight()
        }
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
