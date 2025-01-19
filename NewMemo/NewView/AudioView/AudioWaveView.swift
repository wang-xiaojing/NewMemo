//
//  AudioWaveView.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2025/01/01.
//
import SwiftUI

// MARK: - 波形用のView
struct AudioWaveView: View {
    let samples: [CGFloat]
    let size: CGSize

    // MARK: - 最小値と最大値を保持するための変数
    @State private var overallMinValue: CGFloat = .greatestFiniteMagnitude
    @State private var overallMaxValue: CGFloat = 0

    var body: some View {
        ZStack {
            Color.blue.opacity(0.05)
            Path { path in
                // MARK: - samples配列が空でないことを確認する。空の場合は処理を中断して戻る。
                guard !samples.isEmpty else { return }
                // MARK: - AppSetting.voiceRecodeSamplePointsから最大カウント数を取得する。
                let maxCount = AppSetting.voiceRecodeSamplePoints
                // MARK: - 波形を描画するためのステップ幅を計算する。
                let step = size.width / CGFloat(maxCount - 1)

                // MARK: - 現在のsamplesの最小値と最大値を取得する
                let currentMinValue = samples.min() ?? .greatestFiniteMagnitude
                let currentMaxValue = samples.max() ?? 0

                // MARK: - 全体の最小値と最大値を更新する
                DispatchQueue.main.async {
                    overallMinValue = min(overallMinValue, currentMinValue)
                    overallMaxValue = max(overallMaxValue, currentMaxValue)
                }

                // MARK: - samples配列の各要素から全体の最小値を引いた新しい配列を作成し、負の値は0にする。
                let adjustedSamples = samples.map { max($0 - overallMinValue, 0) }
                
                // MARK: - adjustedSamples配列の各要素を全体の最大値で割り、0から1の範囲に正規化した新しい配列を作成する。
                let normalizedSamples = adjustedSamples.map { $0 / overallMaxValue }

                for (index, sample) in normalizedSamples.enumerated() {
                    // MARK: - xPosを計算して描画する
                    let xPos = size.width - step * CGFloat(normalizedSamples.count - 1 - index)
                    let yPos = sample * size.height
                    // MARK: - 点線を描画するために指定の間隔で点を描く
                    let pointInterval: CGFloat = 2.0 // 点の間隔を調整
                    var currentYPos = (size.height / 2) - yPos
                    while currentYPos < (size.height / 2) + yPos {
                        path.move(to: CGPoint(x: xPos, y: currentYPos))
                        path.addLine(to: CGPoint(x: xPos, y: currentYPos + pointInterval))
                        currentYPos += 2 * pointInterval // 点と点の間の距離を指定
                    }
                }
            }
            .stroke(Color.red, lineWidth: 1)
        }
        .frame(width: size.width, height: size.height)
    }
}
