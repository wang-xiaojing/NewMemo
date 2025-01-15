//
//  Coordinator.swift
//  SearchMap
//
//  Created by Xiaojing Wang on 2025/01/06.
//

import SwiftUI
import MapKit

// MKMapViewDelegateを実装するコーディネータクラス
class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    var onLongTap: () -> Void
    @Binding var justRegisteredFirst: Bool
    @Binding var showAlreadyRegisteredAlertForLongTap: Bool

    init(_ parent: MapView,
         onLongTap: @escaping () -> Void,
         justRegisteredFirst: Binding<Bool>,
         showAlreadyRegisteredAlertForLongTap: Binding<Bool>) {
        self.parent = parent
        self.onLongTap = onLongTap
        self._justRegisteredFirst = justRegisteredFirst
        self._showAlreadyRegisteredAlertForLongTap = showAlreadyRegisteredAlertForLongTap
    }

    // アノテーションビューをカスタマイズするメソッド
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let identifier = "CurrentLocation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.pinTintColor = .red // ピンの色を赤に設定
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    // ロングタップを処理するメソッド
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            if justRegisteredFirst {
                let locationX = gestureRecognizer.location(in: gestureRecognizer.view)
                let coordinateX = (gestureRecognizer.view as! MKMapView)
                    .convert(locationX, toCoordinateFrom: gestureRecognizer.view)

                let alert = UIAlertController(
                    title: "すでに登録した場所が存在します。新しい場所に移動しますか？",
                    message: nil,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.showAlreadyRegisteredAlertForLongTap = false
                    self.justRegisteredFirst = false
                    self.parent.longTapLocation = coordinateX
                    self.onLongTap()
                })

                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(alert, animated: true)
                }
            } else {
                let location = gestureRecognizer.location(in: gestureRecognizer.view)
                let coordinate = (gestureRecognizer.view as! MKMapView)
                    .convert(location, toCoordinateFrom: gestureRecognizer.view)
                parent.longTapLocation = coordinate
                onLongTap()
            }
        }
    }
}
