//
//  NewView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/07.
//

import SwiftUI
import PhotosUI
import Photos

struct NewView: View {
    // MARK: AudioView用
    @EnvironmentObject var audioRecorder: AudioRecorder
    @State private var showAudioAlertFlag = false
    @State private var audioAlertTitle = ""
    @State private var audioAlertMessage = ""

    @Binding var showAudioOverlayWindow: Bool

    @State private var isAudioSaveEnabled = false
    @State private var isAudioPaused = false
    @State private var audioWaveSamples: [CGFloat] = []
    @State private var audioWaveTimer: Timer?

    @State private var text: String = ""  // ユーザーが入力するテキストを保持
    @State private var textEditorHeight: CGFloat = 60 // テキストエディタの高さを初期設定（3行分）
    @State private var showCamera: Bool = false  // カメラ画面の表示フラグ
    @State private var showPhoto: Bool = false  // フォトライブラリ画面の表示フラグ
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
    @State private var showEditMenu: Bool = false  // 編集メニューを表示するフラグを追加
    @State private var showSaveConfirmation: Bool = false  // 写真へ保存の確認アラートを表示するフラグを追加
    @State private var editAction: EditAction? = nil  // 選択された編集アクション

    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlertFlag: Bool = false

    // 選択された画像をIdentifiableUIImage型に変更
    @State private var selectedImage: IdentifiableUIImage? = nil
    @State private var isDisplayingImage: Bool = false  // シート表示フラグ
    
    enum EditAction: Identifiable {
        case delete
        case save

        var id: Int {
            hashValue
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {  // 全体を縦にレイアウト
                VStack(alignment: .leading) {  // 上部のコンテンツを左揃えで縦に配置
                    Group {
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
                                // MARK: AudioView用
                                showAudioOverlayWindow = true
                                audioWaveSamples.removeAll()     //　波形データを空にする
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
                                            ZStack(alignment: .topTrailing) {  // 画像と編集ボタンを配置
                                                Image(uiImage: capturedImages[index])  // 画像を表示
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: geometry.size.height / 5)
                                                // .padding(.trailing, 8)
                                                // 画像がタップされたときの処理
                                                    .onTapGesture {
                                                        // タップされた画像をIdentifiableUIImageとして保存
                                                        selectedImage = IdentifiableUIImage(image: capturedImages[index])
                                                    }
                                                Button(action: {
                                                    showEditMenu = true  // 編集メニューを表示するフラグを有効化
                                                    selectedImageIndex = index  // 選択された画像のインデックスを保存
                                                }) {
                                                    Image(systemName: "pencil")  // アイコンを'編集'（鉛筆）に変更
                                                        .foregroundColor(.white)
                                                        .background(Color.black)
                                                    // .padding(4)
                                                }
                                            }
                                            // .border(Color.gray, width: 1)
                                        }
                                    }
                                }
                                // 選択された画像を表示するシートを設定します
                                .sheet(item: $selectedImage) { identifiableImage in
                                    // DisplayViewを表示
                                    DisplayView(image: identifiableImage.image)
                                }
                                .confirmationDialog("", isPresented: $showEditMenu, presenting: selectedImageIndex) { index in
                                    // 編集メニューを表示
                                    Button("写真へ保存") {
                                        editAction = .save  // 保存アクションを設定
                                    }
                                    Button("削除", role: .destructive) {
                                        editAction = .delete  // 削除アクションを設定
                                    }
                                }
                                .sheet(item: $editAction) { action in
                                    // 選択されたアクションに応じて処理を実行
                                    switch action {
                                    case .save:
                                        //  を表示
                                        ConfirmationDialog(
                                            title: "写真へ保存",
                                            message: "この画像を写真アプリに保存しますか？",
                                            confirmTitle: "保存",
                                            confirmAction: {
                                                saveImageToPhotos()  // 画像を写真アプリへ保存する処理を実行
                                            }
                                        )
                                        .presentationDetents([.fraction(0.25)])     // 画面高さの 1/4
                                        // .interactiveDismissDisabled(true)        // 画面が消えないように
                                    case .delete:
                                        // 削除の確認ダイアログを表示
                                        ConfirmationDialog(
                                            title: "画像の削除",
                                            message: "この画像を削除しますか？",
                                            confirmTitle: "削除",
                                            confirmAction: {
                                                if let index = selectedImageIndex {
                                                    capturedImages.remove(at: index)  // 画像を配列から削除
                                                }
                                            },
                                            isDestructive: true
                                        )
                                        .presentationDetents([.fraction(0.25)])     // 画面高さの 1/4
                                        // .interactiveDismissDisabled(true)        // 画面が消えないように
                                    }
                                }
                            }
                            Spacer()  // 他のビューとの間隔を確保
                        }  // HStackの終了
                    }
                    .disabled(showAudioOverlayWindow)
                    // MARK: 録音処理
                    AudioView(
                        showAudioAlertFlag: $showAudioAlertFlag,
                        audioAlertTitle: $audioAlertTitle,
                        audioAlertMessage: $audioAlertMessage,
                        isAudioSaveEnabled: $isAudioSaveEnabled,
                        showAudioOverlayWindow: $showAudioOverlayWindow,
                        isAudioPaused: $isAudioPaused,
                        audioWaveSamples: $audioWaveSamples,
                        audioWaveTimer: $audioWaveTimer
                    )
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
                    if showTagSelector {
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
                    } else if showAudioOverlayWindow {  // showOverlayWindowがtrueのときに表示されるオーバーレイウィンドウ
                        AudioOverlayWindow(isAudioSaveEnabled: $isAudioSaveEnabled,
                                           showAudioOverlayWindow: $showAudioOverlayWindow,
                                           isAudioPaused: $isAudioPaused,
                                           audioWaveSamples: $audioWaveSamples,
                                           audioWaveTimer: $audioWaveTimer)
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
            .sheet(isPresented: $showPhoto) {
                // フォトライブラリビューを表示
                PhotoPicker(capturedImages: $capturedImages, isPresented: $showPhoto)
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
            .alert(isPresented: $showAlertFlag) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showLocation) {
                VStack {
                    HStack {
                        Button(action: {
                            showLocation = false  // Cancelボタンが押されたらシートを閉じる
                        }) {
                            Text("Cancel")
                        }
                        Spacer()
                        Text("Map View")  // タイトルを表示
                        Spacer()
                        Button(action: {
                            // 追加ボタンが押された時の処理
                            showLocation = false  // とりあえずシートを閉じる
                        }) {
                            Text("追加")
                        }
                    }
                    .padding()
                    Divider()
                    MapViewContainer()  // MapViewContainerを表示
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.9))
                .edgesIgnoringSafeArea(.all)
            }
        }
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
        // case .trailing:
        //     return .right  // 右揃え
        default:
            return .right  // デフォルトは左揃え
        }
    }
    
    private func saveImageToPhotos() {
        if let index = selectedImageIndex {
            let image = capturedImages[index]
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }, completionHandler: { success, error in
                        DispatchQueue.main.async {
                            if success {
                                // 保存成功時の処理
                                showAlert(title: "成功", message: "画像を写真に保存しました")
                            } else {
                                // 保存失敗時の処理
                                showAlert(title: "エラー", message: "画像の保存に失敗しました: \(error?.localizedDescription ?? "不明なエラー")")
                            }
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        // 許可が得られなかった場合の処理
                        showAlert(title: "エラー", message: "写真へのアクセスが許可されていません")
                    }
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlertFlag = true
    }
}

