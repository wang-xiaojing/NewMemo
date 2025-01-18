import SwiftUI
import MapKit

struct RegisterLocationView: View {
    @Binding var locationName: String
    var onCancel: () -> Void
    var onConfirm: () -> Void
    @Binding var isRegisterViewPresented: Bool // 追加: isRegisterViewPresentedをバインディングプロパティとして追加
    @Binding var justRegisteredFirst: Bool // 追加: justRegisteredFirstをバインディングプロパティとして追加
    @State private var showAlreadyRegisteredAlert = false // 追加: アラート表示状態を管理するプロパティ

    @Binding private var hereLocation: CLLocationCoordinate2D?
    @Binding private var searchLocation: CLLocationCoordinate2D?
    @Binding private var longTapLocation: CLLocationCoordinate2D?

    var body: some View {
        VStack {
            Spacer()
            VStack(/*spacing: 20*/) {
                TextField(longTapLocation ?? annotation.title :
                          searchLocation ?? annotation.title :
                          hereLocation ?? annotation.title :
                          "Enter location name", text: $locationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .submitLabel(.done) // キーボードのリターンキーを「Done」に変更
                    .onSubmit {
                        onConfirm() // キーボードのリターンキーが押されたときに登録を行う
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
                        } else {
                            onConfirm()
                        }
                    }) {
                        Text("OK")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
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
