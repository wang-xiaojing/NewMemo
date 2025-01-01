//
//  AudioView.swift
//  VoicApp
//
//  Created by Xiaojing Wang on 2025/01/01.
//
import SwiftUI

// 新しい AudioView
struct AudioView: View {
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    @Binding var showAudioAlertFlag: Bool
    @Binding var audioAlertTitle: String
    @Binding var audioAlertMessage: String
    
    @Binding var isAudioSaveEnabled: Bool
    @Binding var showAudioOverlayWindow: Bool
    @Binding var isAudioPaused: Bool
    
    @Binding var audioWaveSamples: [CGFloat]
    @Binding var audioWaveTimer: Timer?
    
    var body: some View {
        NavigationView {
            VStack {
                // 録音一覧
                List {
                    ForEach(audioRecorder.audioRecordings) { recording in
                        VStack {
                            HStack(spacing: 5) {
                                Text(recording.fileName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                // 停止ボタン
                                if recording.isPlaying {
                                    Button(action: {
                                        print("[Button 6]stopRecording FileName: \(recording.fileName)")
                                        audioRecorder.stopPlay(fileName: recording.fileName)
                                    }) {
                                        Image(systemName: "stop.fill")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                            .foregroundColor(.black)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                    Spacer()
                                    
                                }
                                // 再生ボタン
                                Button(action: {
                                    if recording.isPlaying {
                                        if recording.isPaused {
                                            print("[Button 4]resumeRecording FileName: \(recording.fileName)")
                                            audioRecorder.resumeRecording(fileName: recording.fileName)
                                        } else {
                                            print("[Button 5]pauseRecording  FileName: \(recording.fileName)")
                                            audioRecorder.pauseRecording(fileName: recording.fileName)
                                        }
                                    } else {
                                        print("[Button 3]playRecording FileName: \(recording.fileName)")
                                        audioRecorder.playRecording(fileName: recording.fileName)
                                    }
                                }) {
                                    Image(systemName: recording.isPlaying
                                          ? (recording.isPaused ? "play.fill" : "pause.fill")
                                          : "play.circle")
                                    .resizable()
                                    .frame(width: recording.isPlaying ? 18 : 20, height: recording.isPlaying ? 18 : 20)
                                    .foregroundColor(.blue)
                                    .opacity(audioRecorder.audioRecordings.contains { $0.isPlaying && $0.fileName != recording.fileName } ? 0.5 : 1.0)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(audioRecorder.audioRecordings.contains { $0.isPlaying && $0.fileName != recording.fileName })
                                
                                Spacer()
                                
                                // 削除
                                Button(action: {
                                    if recording.isPlaying {
                                        showAlert(title: "削除不可", message: "再生中のため削除できません。")
                                    } else {
                                        audioRecorder.deleteRecording(fileName: recording.fileName)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.red)
                                        .opacity(audioRecorder.audioRecordings.contains { $0.isPlaying && $0.fileName != recording.fileName } ? 0.5 : 1.0)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(audioRecorder.audioRecordings.contains { $0.isPlaying && $0.fileName != recording.fileName })
                            }
                            // 再生の進捗バー
                            ProgressView(value: recording.progress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .onAppear {
                audioRecorder.fetchRecordings()
            }
            .alert(audioAlertTitle, isPresented: $showAudioAlertFlag) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(audioAlertMessage)
            }
            .overlay(
                Group {
                    if showAudioOverlayWindow {  // showOverlayWindowがtrueのときに表示されるオーバーレイウィンドウ
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
        }
    }
    
    private func showAlert(title: String, message: String) {
        audioAlertTitle = title
        audioAlertMessage = message
        showAudioAlertFlag = true
    }
    
    // 波形更新開始
    func startWaveformUpdates() {
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
    
    func stopWaveformUpdates() {
        audioWaveTimer?.invalidate()
        audioWaveTimer = nil
    }
}

