//
//  memo.swift
//  Memory for Develop
//
//  Created by Xiaojing Wang on 2025/01/18.
//
// 2024.01.18
// 目標：
// 既存仕様：新規MapViewContainerを開いてから、
// 　　　　　地点を登録した後依然としてLongTapで新しい位置へ移動可能なります。
// 追加仕様：メモ地点でMapViewContainerを開いてからも、地点を登録した後にLongTapで新しい位置へ移動可能にします。
// 関連キーワード：showAlreadyRegisteredAlertForRemove
//              showAlreadyRegisteredAlertForHere
//              showAlreadyRegisteredAlertForSearch
//              RegisterLocationView -> showAlreadyRegisteredAlert
//              handleLongPress
// 色々テスト：
// Searchで登録後　　Searchで登録：OK
//                 Hereで登録：OK
//                 MovePin：NG -> OK
// 　　　　　　　　　　　　　　　　　　　　moveToPinの中、 Pinが設置されたかを判定の判定は
//                                 if let coordinate = searchLocation ?? hereLocation ?? longTapLocationで行っています。
//                                 意味：searchLocationかhereLocationかlongTapLocationかどうちかnilではなければ …
//                                 改造：memoLocationを加えれば？memoLocationはすでにMapViewContainerのinit初期化されています。
//                                        三箇所：
//                                        （１）MARK: Pinが設置されたかを判定
//                                        （２）MARK: Pinが設置されたかを判定
//                                        （３）func removeAllPins()中にmemoLocation = nil
// (ここでcommit:f9095756e7751535adcc4d2640c65dda1d7a6e98)
//                 LongTapでPin設置：NG（現象として、Pinの表示だけできてないようです）
//                                  -> OK!
// (ここでcommit)
//
//
// MapViewContainerおよび関連の処理 // search, hear,
//
