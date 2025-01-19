import SwiftUI
import MapKit

struct RegisterLocationView: View {
    @Binding var locationName: String
    var onCancel: () -> Void
    var onConfirm: () -> Void
    @Binding var isRegisterViewPresented: Bool // MARK: isRegisterViewPresentedをバインディングプロパティとして追加
    @Binding var justRegisteredFirst: Bool // 追MARK: justRegisteredFirstをバインディングプロパティとして追加
    @State private var showAlreadyRegisteredAlert = false // MARK: アラート表示状態を管理するプロパティ

    @Binding var hereLocation: CLLocationCoordinate2D?
    @Binding var searchLocation: CLLocationCoordinate2D?
    @Binding var longTapLocation: CLLocationCoordinate2D?
    @Binding var annotationTitle: String?

    var body: some View {
        VStack {
            Spacer()
            VStack {
                TextField("Enter location name", text: $locationName)
                    .onAppear {
                        locationName = annotationTitle ?? ""
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .submitLabel(.done) // MARK: キーボードのリターンキーを「Done」に変更
                    .onSubmit {
                        if !locationName.isEmpty {
                            onConfirm() // MARK: キーボードのリターンキーが押されたときに登録を行う
                        }
                    }
                HStack {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
                    
                    Button(action: {
                        if justRegisteredFirst {
                            showAlreadyRegisteredAlert = true
                        } else if !locationName.isEmpty {
                            onConfirm()
                        }
                    }) {
                        Text("OK")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
                    .disabled(locationName.isEmpty) // MARK: locationNameが空の場合はボタンを無効化
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            Spacer()
        }
        .alert(isPresented: $showAlreadyRegisteredAlert) {
            Alert(
                title: Text("すでに登録した場所が存在します。再度登録しますか？"),
                primaryButton: .default(Text("OK")) {
                    isRegisterViewPresented = false
                    justRegisteredFirst = false
                    onConfirm()
                },
                secondaryButton: .cancel()
            )
        }
    }
}
