//
//  NewView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/07.
//

import SwiftUI  // SwiftUIフレームワークをインポート
import PhotosUI  // 写真関連のフレームワークをインポート

struct NewView: View {
    @State private var text: String = ""  // ユーザーが入力するテキストを保持
    @State private var textEditorHeight: CGFloat = 60 // テキストエディタの高さを初期設定（3行分）
    @State private var showCamera: Bool = false  // カメラ画面の表示フラグ
    @State private var showPhoto: Bool = false  // フォトライブラリ画面の表示フラグ
    @State private var showMic: Bool = false  // マイク入力画面の表示フラグ
    @State private var showTagSelector: Bool = false  // タグセレクターの表示フラグ
    @State private var showLocation: Bool = false  // 位置情報画面の表示フラグ
    
    @State private var fontSize: CGFloat = 14  // フォントサイズの初期値
    @State private var fontColor: Color = .black  // フォントカラーの初期値
    @State private var backgroundColor: Color = .white  // テキストエディタの背景色
    @State private var textAlignment: TextAlignment = .leading  // テキストの配置（左寄せ）
    @State private var showFontSettings: Bool = false  // フォント設定画面の表示フラグ
    
    @State private var isBold: Bool = false  // 太字設定のフラグ
    @State private var isItalic: Bool = false  // 斜体設定のフラグ
    @State private var isUnderline: Bool = false  // 下線設定のフラグ

    @State private var capturedImages: [UIImage] = []  // キャプチャした画像の配列
    @State private var showImageEditor: Bool = false  // 画像編集画面の表示フラグ
    @State private var showDeleteConfirmation: Bool = false  // 削除確認アラートの表示フラグ
    @State private var selectedImageIndex: Int? = nil  // 削除対象の画像インデックス
    
    var body: some View {
        VStack {  // 全体を縦にレイアウト
            VStack(alignment: .leading) {  // 上部のコンテンツを左揃えで縦に配置
                Text(currentDateTimeString())  // 現在の日時を表示
                HStack {  // テキストの配置やフォント設定ボタンを横に並べる
                    Spacer()  // 左側にスペースを追加
                    Button(action: {
                        textAlignment = .leading  // テキストを左揃えに設定
                    }) {
                        Image(systemName: "text.justify.left")  // 左揃えのアイコン
                    }
                    Button(action: {
                        textAlignment = .center  // テキストを中央揃えに設定
                    }) {
                        Image(systemName: "text.aligncenter")  // 中央揃えのアイコン
                    }
                    Button(action: {
                        textAlignment = .trailing  // テキストを右揃えに設定
                    }) {
                        Image(systemName: "text.alignright")  // 右揃えのアイコン
                    }
                    Button(action: {
                        showFontSettings = true  // フォント設定画面を表示
                        hideKeyboard()  // キーボードを非表示に
                    }) {
                        Image(systemName: "textformat")  // フォント設定のアイコン
                    }
                }
                ZStack(alignment: .topLeading) {  // テキストエディタとプレースホルダを重ねて配置
                    AttributedTextEditor(
                        text: $text,  // テキストのバインディング
                        fontSize: fontSize,  // フォントサイズ
                        fontColor: UIColor(fontColor),  // フォントカラー（UIColor型）
                        isBold: isBold,  // 太字設定
                        isItalic: isItalic,  // 斜体設定
                        isUnderline: isUnderline,  // 下線設定
                        textAlignment: convertTextAlignment(textAlignment)  // テキストのアライメント変換
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)  // 最大サイズに設定
                    .frame(height: textEditorHeight)  // テキストエディタの高さを設定
                    .background(backgroundColor)  // 背景色を設定
                    .background(GeometryReader { geometry in  // エディタのサイズを取得
                        Color.clear.onAppear {
                            textEditorHeight = geometry.size.height  // 高さを更新
                        }
                    })
                    .onChange(of: text) {
                        adjustTextEditorHeight()  // テキストの高さを調整
                    }
                    .onTapGesture {
                        showFontSettings = false  // フォント設定画面を非表示に
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSetting.cornerRadius)  // 角丸の長方形をオーバーレイ
                            .stroke(Color.gray, lineWidth: 1)  // 枠線を描画
                    )
                    if text.isEmpty {
                        // プレースホルダとして表示するTextを表示
                        Text(" Enter text here")
                            .foregroundColor(.gray)  // プレースホルダの文字色をグレーに
                    }
                }
                HStack {  // 追加機能のボタンを横に配置
                    Button(action: {
                        showCamera = true  // カメラ画面を表示
                    }) {
                        Image(systemName: "camera")  // カメラのアイコン
                    }
                    Button(action: {
                        showPhoto = true  // フォトライブラリ画面を表示
                    }) {
                        Image(systemName: "photo")  // フォトのアイコン
                    }
                    Button(action: {
                        showMic = true  // マイク入力画面を表示
                    }) {
                        Image(systemName: "music.microphone")  // マイクのアイコン
                    }
                    Button(action: {
                        showTagSelector = true  // タグセレクターを表示
                    }) {
                        Image(systemName: "tag")  // タグのアイコン
                    }
                    Button(action: {
                        showLocation = true  // 位置情報画面を表示
                    }) {
                        Image(systemName: "globe")  // 地球のアイコン
                    }
                    Spacer()  // 右側にスペースを追加
                }
                HStack {  // キャプチャした画像を表示するためのHStackを定義
                    if !capturedImages.isEmpty {  // capturedImagesが空でない場合に処理を実行
                        ScrollView(.horizontal) {  // 横方向にスクロール可能なScrollViewを使用
                            HStack {
                                ForEach(capturedImages.indices, id: \.self) { index in  // 配列のインデックスでループ
                                    ZStack(alignment: .topTrailing) {  // 画像と削除ボタンを重ねて配置
                                        Image(uiImage: capturedImages[index])  // 画像を表示
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 100)
                                            .padding(.trailing, 8)
                                        Button(action: {
                                            // 'x'ボタンが押されたときの処理
                                            selectedImageIndex = index  // 選択された画像のインデックスを保存
                                            showDeleteConfirmation = true  // 削除確認アラートを表示
                                        }) {
                                            Image(systemName: "xmark.circle.fill")  // 'x'のアイコン
                                                .foregroundColor(.red)
                                                .padding(4)
                                        }
                                    }
                                }
                            }
                        }
                        .alert(isPresented: $showDeleteConfirmation) {  // 削除確認アラートを表示
                            Alert(
                                title: Text("画像の削除"),
                                message: Text("この画像を削除しますか？"),
                                primaryButton: .destructive(Text("削除")) {
                                    if let index = selectedImageIndex {
                                        capturedImages.remove(at: index)  // 画像を配列から削除
                                    }
                                },
                                secondaryButton: .cancel(Text("キャンセル"))
                            )
                        }
                    }
                    Spacer()  // 他のビューとの間隔を確保
                }  // HStackの終了
            }
            Spacer()
            if showFontSettings {  // フォント設定画面が表示されている場合
                VStack {
                    HStack {
                        Text("書式設定")  // 設定画面のタイトル
                        Spacer()
                        Button(action: {
                            showFontSettings = false  // フォント設定画面を閉じる
                        }) {
                            Text("閉じる")
                        }
                    }
                    Divider()
                    HStack {
                        Text("フォントサイズ")
                        Slider(value: $fontSize, in: 10...30, step: 1)  // フォントサイズを調整
                    }
                    HStack {
                        // フォントカラーのColorPicker
                        Text("フォントカラー")
                        ColorPicker("", selection: $fontColor)
                            .labelsHidden()  // ラベルを非表示
                        Spacer()
                        // 背景色のColorPicker
                        Text("背景色")
                        ColorPicker("", selection: $backgroundColor)
                            .labelsHidden()  // ラベルを非表示
                    }
                    HStack {
                        Toggle("太字", isOn: $isBold)  // 太字設定のトグル
                        Toggle("斜体", isOn: $isItalic)  // 斜体設定のトグル
                        Toggle("下線", isOn: $isUnderline)  // 下線設定のトグル
                        Spacer()
                    }
                }
                .padding()
                .background(Color.white)  // 背景色を白に設定
                .cornerRadius(AppSetting.cornerRadius)  // 角丸を適用
                .shadow(radius: AppSetting.shadowRadius)  // 影を適用
                .padding()
                .onAppear {
                    hideKeyboard()  // フォント設定画面が表示されたらキーボードを非表示に
                }
            }
        }
        .padding()  // 全体にパディングを適用
        .onAppear {
            adjustTextEditorHeight()  // テキストエディタの高さを調整
            setupKeyboardObservers()  // キーボード表示のオブザーバを設定
        }
        .onDisappear {
            removeKeyboardObservers()  // キーボード表示のオブザーバを削除
        }
        .overlay(
            Group {
                if showPhoto {
                    VStack {
                        Text("showPhoto")  // フォトライブラリ画面（仮）
                        Button(action: {
                            showPhoto = false  // フォトライブラリ画面を閉じる
                        }) {
                            Text("戻る")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.9))  // 半透明の背景
                    .edgesIgnoringSafeArea(.all)
                } else if showMic {
                    VStack {
                        Text("showMic")  // マイク入力画面（仮）
                        Button(action: {
                            showMic = false  // マイク入力画面を閉じる
                        }) {
                            Text("戻る")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.9))
                    .edgesIgnoringSafeArea(.all)
                } else if showTagSelector {
                    VStack {
                        Text("showTagSelector")  // タグセレクター画面（仮）
                        Button(action: {
                            showTagSelector = false  // タグセレクター画面を閉じる
                        }) {
                            Text("戻る")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.9))
                    .edgesIgnoringSafeArea(.all)
                } else if showLocation {
                    VStack {
                        Text("showLocation")  // 位置情報画面（仮）
                        Button(action: {
                            showLocation = false  // 位置情報画面を閉じる
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
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                capturedImages.append(image)  // 取得した画像を配列に追加
                // FIXME: 現時点カメラで撮った画像そのまま採用する。
                // FIXME: 画像編集処理必要な場合、下記を開放
                // showImageEditor = true
            }
        }
        // FIXME: 現時点カメラで撮った画像そのまま採用する。
        // FIXME: 画像編集処理必要な場合、下記を開放
        // .sheet(isPresented: $showImageEditor) {
        //     Text("Edit Picture")
        //     if let image = capturedImage {
        //         ImageEditorView(image: image) { editedImage in
        //             capturedImage = editedImage
        //         }
        //     }
        // }
    }
    
    private func adjustTextEditorHeight() {
        let lineHeight = calculateLineHeight()  // 行の高さを計算
        let maxLines: CGFloat = 10 + 1  // 最大行数を設定
        let minLines: CGFloat = 3 + 1  // 最小行数を設定
        let minHeight: CGFloat = lineHeight * minLines  // 最小高さを計算
        let maxHeight: CGFloat = lineHeight * maxLines  // 最大高さを計算
        
        let textHeight = (CGFloat(text.split(separator: "\n").count) + 1) * lineHeight  // テキストの高さを計算
        textEditorHeight = min(max(textHeight, minHeight), maxHeight)  // エディタの高さを調整
    }
    
    private func calculateLineHeight() -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .body)  // デフォルトのフォントを取得
        return font.lineHeight  // 行の高さを取得
    }
    
    private func currentDateTimeString() -> String {
        let formatter = DateFormatter()
        let languageCode = Locale.current.language.languageCode?.identifier
        let regionCode = Locale.current.region?.identifier
        
        // FIXME: 下記言語による表示フォーマットの選択は、未完成です。
        // FIXME: ここでは、地域コード（言語コードでは無い）でフォーマットを選択しており、誤り発生易い
        // FIXME: iPhone XS Max / iOS 18.1.1 でデバッグしましたが、
        // FIXME: 地域：日本 & 言語：日本語優先で　languageCode = en, regionCode = "JP" の結果となり。
        // FIXME: debugPrint("languageCode:\(languageCode ?? "?")")   // "languageCode:en"
        // FIXME: debugPrint("regionCode:\(regionCode ?? "?")")       // "regionCode:JP"
        
        if languageCode == "ja" || regionCode == "JP" {
            formatter.dateFormat = "yyyy年MM月dd日 EEEE HH:mm"  // 日本語形式の日付フォーマット
            formatter.locale = Locale(identifier: "ja_JP")
        } else if languageCode == "zh" || regionCode == "CN" || regionCode == "TW" {
            formatter.dateFormat = "yyyy年MM月dd日 EEEE HH:mm"  // 中国語形式の日付フォーマット
            formatter.locale = Locale(identifier: "zh_CN")
        } else {
            formatter.dateFormat = "yyyy/MM/dd EEEE HH:mm"  // 英語形式の日付フォーマット
            formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter.string(from: Date())  // 日付を文字列に変換して返す
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)  // キーボードを非表示に
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            showFontSettings = false  // キーボードが表示されたらフォント設定画面を非表示に
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)  // オブザーバを削除
    }
    
    private func convertTextAlignment(_ alignment: TextAlignment) -> NSTextAlignment {
        switch alignment {
        case .leading:
            return .left  // 左揃え
        case .center:
            return .center  // 中央揃え
        case .trailing:
            return .right  // 右揃え
        default:
            return .left  // デフォルトは左揃え
        }
    }
    
}

// プレビューを表示するためのコード
#Preview {
    NewView()
}
