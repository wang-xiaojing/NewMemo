//
//  AudioOverlayWindow.swift
//  NewMemo
//
//  Created by Xiaojing Wang on 2025/01/02.
//

import SwiftUI

struct AudioOverlayWindow: View {
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    @Binding var isAudioSaveEnabled: Bool
    @Binding var showAudioOverlayWindow: Bool
    @Binding var isAudioPaused: Bool
    
    @Binding var audioWaveSamples: [CGFloat]
    @Binding var audioWaveTimer: Timer?

    var body: some View {
        VStack {
            Text("AudioRecod")
                .font(.title3)
                .padding()
            // MARK: - 波形表示 (全表示画面高さの1/8)
            Divider()
                .frame(height: UIScreen.main.bounds.height / 8)
                .background(Color.black.opacity(0.1))
                .overlay(
                    GeometryReader { geo in
                        AudioWaveView(samples: audioWaveSamples, size: geo.size)
                    }
                )
                .padding()
            // MARK: - ボタン群
            HStack {
                // MARK: - Cancel: 録音破棄して閉じる
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
                // MARK: - 録音/一時停止/再開
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
                // MARK: - Complete
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
            width: UIScreen.main.bounds.width * 0.8
        )
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }

    private func stopWaveformUpdates() {
        audioWaveTimer?.invalidate()
        audioWaveTimer = nil
    }

    // MARK: - 波形更新開始
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

}
