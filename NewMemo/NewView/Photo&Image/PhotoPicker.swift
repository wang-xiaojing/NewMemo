//
//  PhotoPicker.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2025/01/02.
//
import SwiftUI
import PhotosUI
import Photos

// MARK: - フォトライブラリから画像を選択するためのビューを定義
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var capturedImages: [UIImage]  // MARK: 取得した画像を追加する配列
    @Binding var isPresented: Bool  // MARK: 画像選択画面を閉じるためのフラグ

    func makeUIViewController(context: Context) -> some UIViewController {
        // フォトライブラリの設定を行う
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0  // MARK: 複数枚選択可能に設定
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator  // MARK: デリゲートを設定
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // MARK: 特に更新処理は不要
    }

    // MARK: - コーディネーターを生成
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        // MARK: - 「キャンセル」または「写真を使用」ボタンが押されたときの処理
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if results.isEmpty {
                // MARK: - 「キャンセル」ボタンが押された場合
                parent.isPresented = false  // 画像選択画面を閉じる
            } else {
                // MARK: - 「写真を使用」ボタンが押された場合
                for result in results {
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                        result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                            if let uiImage = image as? UIImage {
                                DispatchQueue.main.async {
                                    // MARK: - 選択された画像をcapturedImagesに追加
                                    self.parent.capturedImages.append(uiImage)
                                }
                            }
                        }
                    }
                }
                parent.isPresented = false  // MARK: 画像選択画面を閉じる
            }
        }
    }
}

// MARK: - UIImageをラップしてIdentifiableに準拠させる構造体
struct IdentifiableUIImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - DisplayViewを新たに追加し、選択された画像を表示します
struct DisplayView: View {
    var image: UIImage
    // MARK: - シートを閉じるための環境変数を追加
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            // MARK: - 選択された画像を表示
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .navigationTitle("表示画面")
                .navigationBarTitleDisplayMode(.inline)
                // MARK: - 左上に「戻る」ボタンを追加
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("戻る") {
                            // MARK: - 「表示画面」を閉じる処理
                            dismiss()
                        }
                    }
                }
        }
    }
}
