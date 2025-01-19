//
//  NewView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2024/12/07.
//

import SwiftUI
import PhotosUI
import Photos
import MapKit

struct RegisteredLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let date: Date
    let image: UIImage?  // MARK: 画像を保持するプロパティ
}

struct NewView: View {
    // MARK: - AudioView用
    @EnvironmentObject var audioRecorder: AudioRecorder
    @State private var showAudioAlertFlag = false
    @State private var audioAlertTitle = ""
    @State private var audioAlertMessage = ""
    @Binding var showAudioOverlayWindow: Bool
    @State private var isAudioSaveEnabled = false
    @State private var isAudioPaused = false
    @State private var audioWaveSamples: [CGFloat] = []
    @State private var audioWaveTimer: Timer?
    @State private var text: String = ""  // MARK: ユーザーが入力するテキストを保持
    @State private var textEditorHeight: CGFloat = 60 // MARK: テキストエディタの高さを初期設定（3行分）
    @State private var showCamera: Bool = false  // MARK: カメラ画面の表示フラグ
    @State private var showPhoto: Bool = false  // MARK: フォトライブラリ画面の表示フラグ
    @State private var showTagSelector: Bool = false  // MARK: タグセレクターの表示フラグ
    @State private var showLocation: Bool = false  // MARK: 位置情報画面の表示フラグ
    @State private var fontSize: CGFloat = 14  // MARK: フォントサイズの初期値
    @State private var fontColor: Color = .black  // MARK: フォントカラーの初期値
    @State private var backgroundColor: Color = .white  // MARK: テキストエディタの背景色
    @State private var textAlignment: TextAlignment = .leading  // MARK: テキストの配置（左寄せ）
    @State private var showFontSettings: Bool = false  // MARK: フォント設定画面の表示フラグ
    @State private var isBold: Bool = false  // MARK: 太字設定のフラグ
    @State private var isItalic: Bool = false  // MARK: 斜体設定のフラグ
    @State private var isUnderline: Bool = false  // MARK: 下線設定のフラグ
    @State private var capturedImages: [UIImage] = []  // MARK: キャプチャした画像の配列
    @State private var showImageEditor: Bool = false  // MARK: 画像編集画面の表示フラグ
    @State private var showDeleteConfirmation: Bool = false  // MARK: 削除確認アラートの表示フラグ
    @State private var selectedImageIndex: Int? = nil  // MARK: 削除対象の画像インデックス
    @State private var showEditMenu: Bool = false  // MARK: 編集メニューを表示するフラグを追加
    @State private var showSaveConfirmation: Bool = false  // MARK: 写真へ保存の確認アラートを表示するフラグを追加
    @State private var editAction: EditAction? = nil  // MARK: 選択された編集アクション
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlertFlag: Bool = false
    // MARK: - 選択された画像をIdentifiableUIImage型に変更
    @State private var selectedImage: IdentifiableUIImage? = nil
    @State private var isDisplayingImage: Bool = false  // MARK: シート表示フラグ
    @State private var registeredLocationArray: [RegisteredLocation] = []  // MARK: 登録された位置情報の配列
    @State private var selectedRegisteredLocation: RegisteredLocation? // MARK: 選択された登録済み地点を保持するプロパティ
    @State private var tapLocation: CGPoint = .zero

    enum EditAction: Identifiable {
        case delete
        case save

        var id: Int {
            hashValue
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {  // MARK: 全体を縦にレイアウト
                    VStack(alignment: .leading) {  // MARK: 上部のコンテンツを左揃えで縦に配置
                        Group {
                            Text(currentDateTimeString())  // MARK: 現在の日時を表示
                            HStack {  // MARK: テキストの配置やフォント設定ボタンを横に並べる
                                Spacer()  // MARK: 左側にスペースを追加
                                Button(action: {
                                    textAlignment = .leading  // MARK: テキストを左揃えに設定
                                }) {
                                    Image(systemName: "text.justify.left")  // MARK: 左揃えのアイコン
                                }
                                Button(action: {
                                    textAlignment = .center  // MARK: テキストを中央揃えに設定
                                }) {
                                    Image(systemName: "text.aligncenter")  // MARK: 中央揃えのアイコン
                                }
                                Button(action: {
                                    textAlignment = .trailing  // MARK: テキストを右揃えに設定
                                }) {
                                    Image(systemName: "text.alignright")  // MARK: 右揃えのアイコン
                                }
                                Button(action: {
                                    showFontSettings = true  // MARK: フォント設定画面を表示
                                    hideKeyboard()  // MARK: キーボードを非表示に
                                }) {
                                    Image(systemName: "textformat")  // フォント設定のアイコン
                                }
                            }
                            ScrollView {
                                ZStack(alignment: .topLeading) {  // MARK: テキストエディタとプレースホルダを重ねて配置
                                    AttributedTextEditor(
                                        text: $text,  // MARK: テキストのバインディング
                                        fontSize: fontSize,  // MARK: フォントサイズ
                                        fontColor: UIColor(fontColor),  // MARK: フォントカラー（UIColor型）
                                        isBold: isBold,  // MARK: 太字設定
                                        isItalic: isItalic,  // MARK: 斜体設定
                                        isUnderline: isUnderline,  // MARK: 下線設定
                                        textAlignment: convertTextAlignment(textAlignment)  // MARK: テキストのアライメント変換
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)  // MARK: 最大サイズに設定
                                    .frame(height: textEditorHeight)  // MARK: テキストエディタの高さを設定
                                    .background(backgroundColor)  // MARK: 背景色を設定
                                    .background(GeometryReader { geometry in  // MARK: エディタのサイズを取得
                                        Color.clear.onAppear {
                                            textEditorHeight = geometry.size.height  // MARK: 高さを更新
                                        }
                                    })
                                    // MARK: - テキストの高さを調整
                                    .onChange(of: text) {
                                        adjustTextEditorHeight()
                                    }
                                    .onTapGesture {
                                        showFontSettings = false  // MARK: フォント設定画面を非表示に
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppSetting.cornerRadius)  // MARK: 角丸の長方形をオーバーレイ
                                            .stroke(Color.gray, lineWidth: 1)  // MARK: 枠線を描画
                                    )
                                    if text.isEmpty {
                                        // MARK: - プレースホルダとして表示するTextを表示
                                        Text(" Enter text here")
                                            .foregroundColor(.gray)  // MARK: プレースホルダの文字色をグレーに
                                    }
                                }
                            }
                            HStack {  // MARK: 追加機能のボタンを横に配置
                                Button(action: {
                                    showCamera = true  // MARK: カメラ画面を表示
                                }) {
                                    Image(systemName: "camera")  // MARK: カメラのアイコン
                                }
                                Button(action: {
                                    showPhoto = true  // MARK: フォトライブラリ画面を表示
                                }) {
                                    Image(systemName: "photo")  // MARK: フォトのアイコン
                                }
                                Button(action: {
                                    // MARK: - AudioView用
                                    showAudioOverlayWindow = true
                                    audioWaveSamples.removeAll()     //　MARK: 波形データを空にする
                                }) {
                                    Image(systemName: "music.microphone")  // MARK: マイクのアイコン
                                }
                                Button(action: {
                                    showTagSelector = true  // MARK: タグセレクターを表示
                                }) {
                                    Image(systemName: "tag")  // MARK: タグのアイコン
                                }
                                Button(action: {    // MARK: globe Button
                                    showLocation = true  // MARK: 位置情報画面を表示
                                    selectedRegisteredLocation = nil    // MARK: 選択された登録済み地点を保持するプロパティ
                                }) {
                                    Image(systemName: "globe")  // MARK: 地球のアイコン
                                }
                                Spacer()  // MARK: 右側にスペースを追加
                            }
                            HStack {  // MARK: キャプチャした画像を表示するためのHStackを定義
                                if !capturedImages.isEmpty {  // MARK: capturedImagesが空でない場合に処理を実行
                                    ScrollView(.horizontal) {  // MARK: 横方向にスクロール可能なScrollViewを使用
                                        HStack {
                                            ForEach(capturedImages.indices, id: \.self) { index in  // MARK: 配列のインデックスでループ
                                                ZStack(alignment: .topTrailing) {  // MARK: 画像と編集ボタンを配置
                                                    Image(uiImage: capturedImages[index])  // MARK: 画像を表示
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: geometry.size.height / 5)
                                                    // MARK: - 画像がタップされたときの処理
                                                        .onTapGesture {
                                                            // MARK: - タップされた画像をIdentifiableUIImageとして保存
                                                            selectedImage = IdentifiableUIImage(image: capturedImages[index])
                                                        }
                                                    Button(action: {
                                                        showEditMenu = true  // MARK: 編集メニューを表示するフラグを有効化
                                                        selectedImageIndex = index  // MARK: 選択された画像のインデックスを保存
                                                    }) {
                                                        Image(systemName: "pencil")  // MARK: アイコンを'編集'（鉛筆）に変更
                                                            .foregroundColor(.white)
                                                            .background(Color.black)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    // MARK: - 選択された画像を表示するシートを設定します
                                    .sheet(item: $selectedImage) { identifiableImage in
                                        // MARK: - DisplayViewを表示
                                        DisplayView(image: identifiableImage.image)
                                    }
                                    .confirmationDialog("", isPresented: $showEditMenu, presenting: selectedImageIndex) { index in
                                        // MARK: - 編集メニューを表示
                                        Button("写真へ保存") {
                                            editAction = .save  // MARK: 保存アクションを設定
                                        }
                                        Button("削除", role: .destructive) {
                                            editAction = .delete  // MARK: 削除アクションを設定
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
                                                    saveImageToPhotos()  // MARK: 画像を写真アプリへ保存する処理を実行
                                                }
                                            )
                                            .presentationDetents([.fraction(0.25)])     // MARK: 画面高さの 1/4
                                        case .delete:
                                            // MARK: - 削除の確認ダイアログを表示
                                            ConfirmationDialog(
                                                title: "画像の削除",
                                                message: "この画像を削除しますか？",
                                                confirmTitle: "削除",
                                                confirmAction: {
                                                    if let index = selectedImageIndex {
                                                        capturedImages.remove(at: index)  // MARK: 画像を配列から削除
                                                    }
                                                },
                                                isDestructive: true
                                            )
                                            .presentationDetents([.fraction(0.25)])     // MARK: 画面高さの 1/4
                                        }
                                    }
                                }
                                Spacer()  // MARK: 他のビューとの間隔を確保
                            }
                            HStack {    // MARK: memoした地点のキャプチャを表示する
                                if !registeredLocationArray.isEmpty {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            // FIXME: 順番調整禁止！
                                            ForEach(registeredLocationArray.indices, id: \.self) { index in
                                                let location = registeredLocationArray[index]
                                                if let image = location.image {
                                                    Button(action: {
                                                        selectedRegisteredLocation = registeredLocationArray[index]
                                                        showLocation = true
                                                    }) {
                                                        VStack(spacing: 5) {
                                                            Image(uiImage: image)
                                                                .padding()
                                                                .offset(y: -25)
                                                                .clipped()
                                                                .frame(width: 150, height: 150)
                                                                .border(Color.clear, width: 0)
                                                                .background(Color.clear)
                                                            Text("\(location.name)")
                                                                .font(.caption)
                                                                .fontWeight(.light)
                                                                .foregroundColor(.black)
                                                                .lineLimit(1)
                                                                .frame(maxWidth: 150)
                                                                .background(Color.white)
                                                        }
                                                    }
                                                    .cornerRadius(1)
                                                }
                                            }
                                            // FIXME: 順番調整禁止！
                                        }
                                    }
                                }
                            }
                        }
                        .disabled(showAudioOverlayWindow)
                        // MARK: - 録音処理
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
                    if showFontSettings {  // MARK: フォント設定画面が表示されている場合
                        VStack {
                            HStack {
                                Text("書式設定")  // MARK: 設定画面のタイトル
                                Spacer()
                                Button(action: {
                                    showFontSettings = false  // MARK: フォント設定画面を閉じる
                                }) {
                                    Text("閉じる")
                                }
                            }
                            Divider()
                            HStack {
                                Text("フォントサイズ")
                                Slider(value: $fontSize, in: 10...30, step: 1)  // MARK: フォントサイズを調整
                            }
                            HStack {
                                // MARK: - フォントカラーのColorPicker
                                Text("フォントカラー")
                                ColorPicker("", selection: $fontColor)
                                    .labelsHidden()  // MARK: ラベルを非表示
                                Spacer()
                                // 背景色のColorPicker
                                Text("背景色")
                                ColorPicker("", selection: $backgroundColor)
                                    .labelsHidden()  // MARK: ラベルを非表示
                            }
                            HStack {
                                Toggle("太字", isOn: $isBold)  // MARK: 太字設定のトグル
                                Toggle("斜体", isOn: $isItalic)  // MARK: 斜体設定のトグル
                                Toggle("下線", isOn: $isUnderline)  // MARK: 下線設定のトグル
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.white)  // MARK: 背景色を白に設定
                        .cornerRadius(AppSetting.cornerRadius)  // MARK: 角丸を適用
                        .shadow(radius: AppSetting.shadowRadius)  // MARK: 影を適用
                        .padding()
                        .onAppear {
                            hideKeyboard()  // MARK: フォント設定画面が表示されたらキーボードを非表示に
                        }
                    }
                }
                .padding()  // MARK: 全体にパディングを適用
                // MARK: - テキストの高さを調整
                .onAppear {
                    adjustTextEditorHeight()  // MARK: テキストエディタの高さを調整
                    setupKeyboardObservers()  // MARK: キーボード表示のオブザーバを設定
                }
                .onDisappear {
                    removeKeyboardObservers()  // MARK: キーボード表示のオブザーバを削除
                }
                .overlay(
                    Group {
                        if showTagSelector {
                            VStack {
                                Text("showTagSelector")  // MARK: タグセレクター画面（仮）
                                Button(action: {
                                    showTagSelector = false  // MARK: タグセレクター画面を閉じる
                                }) {
                                    Text("戻る")
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.9))
                            .edgesIgnoringSafeArea(.all)
                        } else if showAudioOverlayWindow {  // MARK: showOverlayWindowがtrueのときに表示されるオーバーレイウィンドウ
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
                        // TODO: - 現時点カメラで撮った画像そのまま採用する。
                        // TODO: - 画像編集処理必要な場合、下記を開放
                        // showImageEditor = true
                    }
                }
                .sheet(isPresented: $showPhoto) {
                    // MARK: - フォトライブラリビューを表示
                    PhotoPicker(capturedImages: $capturedImages, isPresented: $showPhoto)
                }
                // TODO: 現時点カメラで撮った画像そのまま採用する。
                // TODO: 画像編集処理必要な場合、下記を開放
                // .sheet(isPresented: $showImageEditor) {
                //     Text("Edit Picture")
                //     if let image = capturedImage {
                //         ImageEditorView(image: image) { editedImage in
                //             capturedImage = editedImage
                //         }
                //     }
                // }
                .sheet(isPresented: $showLocation) {
                    if let selectedLocation = selectedRegisteredLocation {
                        MapViewContainer(
                            showLocation: $showLocation,
                            registeredLocationArray: $registeredLocationArray,
                            selectedRegisteredLocation: selectedLocation
                        )
                    } else {
                        MapViewContainer(
                            showLocation: $showLocation,
                            registeredLocationArray: $registeredLocationArray
                        )
                    }
                }
                .alert(isPresented: $showAlertFlag) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    private func adjustTextEditorHeight() {
        let lineHeight = calculateLineHeight()  // MARK: 行の高さを計算
        let maxLines: CGFloat = 10 + 1  // MARK: 最大行数を設定
        let minLines: CGFloat = 3 + 1  // MARK: 最小行数を設定
        let minHeight: CGFloat = lineHeight * minLines  // MARK: 最小高さを計算
        let maxHeight: CGFloat = lineHeight * maxLines  // MARK: 最大高さを計算
        let textHeight = (CGFloat(text.split(separator: "\n").count) + 1) * lineHeight  // MARK: テキストの高さを計算
        textEditorHeight = min(max(textHeight, minHeight), maxHeight)  // MARK: エディタの高さを調整
    }
    
    private func calculateLineHeight() -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .body)  // MARK: デフォルトのフォントを取得
        return font.lineHeight  // MARK: 行の高さを取得
    }
    
    private func currentDateTimeString() -> String {
        let formatter = DateFormatter()
        let languageCode = Locale.current.language.languageCode?.identifier
        let regionCode = Locale.current.region?.identifier
        
        // TODO: 下記言語による表示フォーマットの選択は、未完成です。
        //       ここでは、地域コード（言語コードでは無い）でフォーマットを選択しており、誤り発生易い
        //       iPhone XS Max / iOS 18.1.1 でデバッグしましたが、
        //       地域：日本 & 言語：日本語優先で　languageCode = en, regionCode = "JP" の結果となり。
        //       debugPrint("languageCode:\(languageCode ?? "?")")   // MARK: "languageCode:en"
        //       debugPrint("regionCode:\(regionCode ?? "?")")       // MARK: "regionCode:JP"
        
        if languageCode == "ja" || regionCode == "JP" {
            formatter.dateFormat = "yyyy年MM月dd日 EEEE HH:mm"  // MARK: 日本語形式の日付フォーマット
            formatter.locale = Locale(identifier: "ja_JP")
        } else if languageCode == "zh" || regionCode == "CN" || regionCode == "TW" {
            formatter.dateFormat = "yyyy年MM月dd日 EEEE HH:mm"  // MARK: 中国語形式の日付フォーマット
            formatter.locale = Locale(identifier: "zh_CN")
        } else {
            formatter.dateFormat = "yyyy/MM/dd EEEE HH:mm"  // MARK: 英語形式の日付フォーマット
            formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter.string(from: Date())  // MARK: 日付を文字列に変換して返す
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)  // MARK: キーボードを非表示に
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            showFontSettings = false  // MARK: キーボードが表示されたらフォント設定画面を非表示に
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)  // オブザーバを削除
    }
    
    private func convertTextAlignment(_ alignment: TextAlignment) -> NSTextAlignment {
        switch alignment {
        case .leading:
            return .left  // MARK: 左揃え
        case .center:
            return .center  // MARK: 中央揃え
        // case .trailing:
        //     return .right  // MARK: 右揃え
        default:
            return .right  // MARK: デフォルトは左揃え
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
                            if (success) {
                                // MARK: - 保存成功時の処理
                                showAlert(title: "成功", message: "画像を写真に保存しました")
                            } else {
                                // MARK: - 保存失敗時の処理
                                showAlert(title: "エラー", message: "画像の保存に失敗しました: \(error?.localizedDescription ?? "不明なエラー")")
                            }
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        // MARK: - 許可が得られなかった場合の処理
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

