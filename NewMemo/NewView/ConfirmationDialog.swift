//
//  ConfirmationDialog.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2025/01/02.
//
import SwiftUI

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
