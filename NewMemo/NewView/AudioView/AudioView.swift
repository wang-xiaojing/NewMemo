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
    
    @Binding var showAlertFlag: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    
    @Binding var isSaveEnabled: Bool
    @Binding var showOverlayWindow: Bool
    @Binding var isPaused: Bool
    
    @Binding var waveSamples: [CGFloat]
    @Binding var waveTimer: Timer?
    
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
            .alert(alertTitle, isPresented: $showAlertFlag) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .overlay(
                // showOverlayWindowがtrueのときに表示されるオーバーレイウィンドウ
                Group {
                    // AudioRecod Window
                    if showOverlayWindow {
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
                                        AudioWaveView(samples: waveSamples, size: geo.size)
                                    }
                                )
                                .padding()
                            // ボタン群
                            HStack {
                                // Cancel: 録音破棄して閉じる
                                Button("Cancel") {
                                    stopWaveformUpdates()
                                    if audioRecorder.isRecording || isPaused {
                                        audioRecorder.stopRecording()
                                        if let lastFile = audioRecorder.audioRecordings.last?.fileName {
                                            audioRecorder.deleteRecording(fileName: lastFile)
                                        }
                                        isPaused = false
                                        isSaveEnabled = false
                                    }
                                    showOverlayWindow = false   // オーバーレイウィンドウを閉じる
                                }
                                Spacer()
                                // 録音/一時停止/再開
                                if audioRecorder.isRecording && !isPaused {
                                    Button(action: {
                                        stopWaveformUpdates()
                                        audioRecorder.pauseRecording(fileName: "")
                                        isPaused = true
                                        isSaveEnabled = true
                                    }) {
                                        Text("Pause").foregroundColor(.red)
                                    }
                                } else if isPaused {
                                    Button(action: {
                                        startWaveformUpdates()
                                        audioRecorder.resumeRecording(fileName: "")
                                        isPaused = false
                                        isSaveEnabled = false
                                    }) {
                                        Text("Resume").foregroundColor(.blue)
                                    }
                                } else {
                                    Button(action: {
                                        audioRecorder.startRecording()
                                        isPaused = false
                                        isSaveEnabled = false
                                        startWaveformUpdates()
                                    }) {
                                        Text("Start").foregroundColor(.green)
                                    }
                                }
                                Spacer()
                                // Complete
                                Button("Complete") {
                                    if isSaveEnabled {
                                        if isPaused {
                                            audioRecorder.stopRecording()
                                            isPaused = false
                                        }
                                        stopWaveformUpdates()
                                        showOverlayWindow = false
                                        isSaveEnabled = false
                                    }
                                }
                                .disabled(!isSaveEnabled)
                                .opacity(isSaveEnabled ? 1.0 : 0.4)
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
        alertTitle = title
        alertMessage = message
        showAlertFlag = true
    }
    
    // 波形更新開始
    func startWaveformUpdates() {
        waveTimer?.invalidate()
        waveTimer = Timer.scheduledTimer(withTimeInterval: AppSetting.voiceRecodeSampleTimeInterval, repeats: true) { _ in
            guard let recorder = audioRecorder.internalRecorder else { return }
            recorder.updateMeters()
            let power = recorder.averagePower(forChannel: 0)
            let normalized = min(max((power + 160) / 160, 0), 1)
            waveSamples.append(CGFloat(normalized))
            if waveSamples.count > AppSetting.voiceRecodeSamplePoints {
                waveSamples.removeFirst()
            }
        }
    }
    
    func stopWaveformUpdates() {
        waveTimer?.invalidate()
        waveTimer = nil
    }
}

