//
//  NewView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/07.
//

import SwiftUI  // SwiftUIフレームワークをインポート
import PhotosUI  // 写真関連のフレームワークをインポート
import Photos  // 写真関連のフレームワークをインポート

struct NewView: View {
    @State private var text: String = ""  // ユーザーが入力するテキストを保持
    @State private var textEditorHeight: CGFloat = 60 // テキストエディタの高さを初期設定（3行分）
    @State private var showCamera: Bool = false  // カメラ画面の表示フラグ
    @State private var showPhoto: Bool = false  // フォトライブラリ画面の表示フラグ
    @State private var showAudioOverlayWindow: Bool = false  // マイク入力画面の表示フラグ
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
    // MARK: AudioView用
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    @State private var showAudioAlertFlag = false
    @State private var audioAlertTitle = ""
    @State private var audioAlertMessage = ""
    
    @State private var isAudioSaveEnabled = false
    @State private var isAudioPaused = false
    
    @State private var audioWaveSamples: [CGFloat] = []
    @State private var audioWaveTimer: Timer?
    
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
                    // } else if showAudioOverlayWindow {
                    //     VStack {
                    //         Text("showMic")  // マイク入力画面（仮）
                    //         Button(action: {
                    //             showAudioOverlayWindow = false  // マイク入力画面を閉じる
                    //         }) {
                    //             Text("戻る")
                    //         }
                    //     }
                    //     .frame(maxWidth: .infinity, maxHeight: .infinity)
                    //     .background(Color.white.opacity(0.9))
                    //     .edgesIgnoringSafeArea(.all)
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
                    } else if showAudioOverlayWindow {  // showOverlayWindowがtrueのときに表示されるオーバーレイウィンドウ
                        Color.clear.ignoresSafeArea()   // 背景を半透明の黒にして操作をブロック
                        VStack {
                            Text("AudioRecod")
                                .font(.title3)
                                .padding()
                            // 波形表示 (全表示画面高さの1/8)
                            Divider()
                                .frame(height: UIScreen.main.bounds.height / 8)
                                .background(Color.black.opacity(0.1))
                                .overlay(
                                    GeometryReader { geo in
                                        AudioWaveView(samples: audioWaveSamples, size: geo.size)
                                    }
                                )
                                .padding()
                            // ボタン群
                            HStack {
                                // Cancel: 録音破棄して閉じる
                                Button("Cancel") {
                                    stopWaveformUpdates()
                                    if audioRecorder.isRecording || isAudioPaused {
                                        audioRecorder.stopRecording()
                                        if let lastFile = audioRecorder.audioRecordings.last?.fileName {
                                            audioRecorder.deleteRecording(fileName: lastFile)
                                        }
                                        isAudioPaused = false
                                        isAudioSaveEnabled = false
                                    }
                                    showAudioOverlayWindow = false   // オーバーレイウィンドウを閉じる
                                }
                                Spacer()
                                // 録音/一時停止/再開
                                if audioRecorder.isRecording && !isAudioPaused {
                                    Button(action: {
                                        stopWaveformUpdates()
                                        audioRecorder.pauseRecording(fileName: "")
                                        isAudioPaused = true
                                        isAudioSaveEnabled = true
                                    }) {
                                        Text("Pause").foregroundColor(.red)
                                    }
                                } else if isAudioPaused {
                                    Button(action: {
                                        startWaveformUpdates()
                                        audioRecorder.resumeRecording(fileName: "")
                                        isAudioPaused = false
                                        isAudioSaveEnabled = false
                                    }) {
                                        Text("Resume").foregroundColor(.blue)
                                    }
                                } else {
                                    Button(action: {
                                        audioRecorder.startRecording()
                                        isAudioPaused = false
                                        isAudioSaveEnabled = false
                                        startWaveformUpdates()
                                    }) {
                                        Text("Start").foregroundColor(.green)
                                    }
                                }
                                Spacer()
                                // Complete
                                Button("Complete") {
                                    if isAudioSaveEnabled {
                                        if isAudioPaused {
                                            audioRecorder.stopRecording()
                                            isAudioPaused = false
                                        }
                                        stopWaveformUpdates()
                                        showAudioOverlayWindow = false
                                        isAudioSaveEnabled = false
                                    }
                                }
                                .disabled(!isAudioSaveEnabled)
                                .opacity(isAudioSaveEnabled ? 1.0 : 0.4)
                            }
                            .padding()
                        }
                        .frame(
                            width: UIScreen.main.bounds.width * 0.8,
                            height: UIScreen.main.bounds.height * 0.3
                        )
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                        // }
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
        }
    }

    private func stopWaveformUpdates() {
        audioWaveTimer?.invalidate()
        audioWaveTimer = nil
    }

    // 波形更新開始
    private func startWaveformUpdates() {
        audioWaveTimer?.invalidate()
        audioWaveTimer = Timer.scheduledTimer(withTimeInterval: AppSetting.voiceRecodeSampleTimeInterval, repeats: true) { _ in
            guard let recorder = audioRecorder.internalRecorder else { return }
            recorder.updateMeters()
            let power = recorder.averagePower(forChannel: 0)
            let normalized = min(max((power + 160) / 160, 0), 1)
            audioWaveSamples.append(CGFloat(normalized))
            if audioWaveSamples.count > AppSetting.voiceRecodeSamplePoints {
                audioWaveSamples.removeFirst()
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

// ConfirmationDialogビューを作成
struct ConfirmationDialog: View {
    @Environment(\.presentationMode) var presentationMode  // シートの表示状態を管理

    let title: String
    let message: String
    let confirmTitle: String
    let confirmAction: () -> Void
    var isDestructive: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            Text(message)
            HStack {
                Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()  // シートを閉じる
                }
                Spacer()
                Button(confirmTitle) {
                    confirmAction()
                    presentationMode.wrappedValue.dismiss()  // アクション後にシートを閉じる
                }
                .foregroundColor(isDestructive ? .red : .blue)
            }
        }
        .padding()
    }
}

// フォトライブラリから画像を選択するためのビューを定義
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var capturedImages: [UIImage]  // 取得した画像を追加する配列
    @Binding var isPresented: Bool  // 画像選択画面を閉じるためのフラグ

    func makeUIViewController(context: Context) -> some UIViewController {
        // フォトライブラリの設定を行う
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0  // 複数枚選択可能に設定
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator  // デリゲートを設定
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // 特に更新処理は不要
    }

    func makeCoordinator() -> Coordinator {
        // コーディネーターを生成
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        // 「キャンセル」または「写真を使用」ボタンが押されたときの処理
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if results.isEmpty {
                // 「キャンセル」ボタンが押された場合
                parent.isPresented = false  // 画像選択画面を閉じる
            } else {
                // 「写真を使用」ボタンが押された場合
                for result in results {
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                        result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                            if let uiImage = image as? UIImage {
                                DispatchQueue.main.async {
                                    // 選択された画像をcapturedImagesに追加
                                    self.parent.capturedImages.append(uiImage)
                                }
                            }
                        }
                    }
                }
                parent.isPresented = false  // 画像選択画面を閉じる
            }
        }
    }
}

// UIImageをラップしてIdentifiableに準拠させる構造体
struct IdentifiableUIImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// DisplayViewを新たに追加し、選択された画像を表示します
struct DisplayView: View {
    var image: UIImage
    // シートを閉じるための環境変数を追加
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            // 選択された画像を表示
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .navigationTitle("表示画面")
                .navigationBarTitleDisplayMode(.inline)
                // 左上に「戻る」ボタンを追加
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("戻る") {
                            // 「表示画面」を閉じる処理
                            dismiss()
                        }
                    }
                }
        }
    }
}

// プレビューを表示するためのコード
#Preview {
    NewView()
}
