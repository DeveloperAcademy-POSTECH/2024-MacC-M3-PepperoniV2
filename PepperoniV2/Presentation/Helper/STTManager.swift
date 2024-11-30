//
//  STTManager.swift
//  PepperoniV2
//
//  Created by 변준섭 on 11/20/24.
//

import Speech
import AVFoundation
import Combine

class STTManager: ObservableObject {
    var isRecording = false
    @Published var recognizedText = ""
    @Published var startTime: Double?
    @Published var endTime: Double?
    @Published var voicingTime: Double?
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioRecorder: AVAudioRecorder?
    
    func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognizer is not available.")
            return
        }

        recognizedText = ""
        isRecording = true

        // STT 및 Audio 설정
        do {
            try setupSTT()
        } catch {
            print("Failed to set up STT: \(error.localizedDescription)")
            return
        }

        // 오디오 엔진 시작
        audioEngine.prepare()
        try? audioEngine.start()

        // 녹음 파일 설정 및 시작
        startAudioRecorder()
    }

    func resumeRecording() async {
        guard !isRecording else {
            print("Recording is already in progress.")
            return
        }

        print("Resuming recording and STT")

        // 오디오 세션 활성화
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            print("Failed to activate audio session: \(error.localizedDescription)")
            return
        }

        // STT 및 Audio 설정
        do {
            try setupSTT()
        } catch {
            print("Failed to set up STT: \(error.localizedDescription)")
            return
        }

        // 오디오 엔진 재개
        if !audioEngine.isRunning {
            try? audioEngine.start()
        }

        // 녹음 재개
        audioRecorder?.record()
        isRecording = true
    }
    
    private func setupSTT() throws {
        // STT 초기화
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest, let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw NSError(domain: "STTManagerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer is not available."])
        }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0) // 기존의 Tap 제거
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self?.recognizedText = result.bestTranscription.formattedString
                    print("Recognized Text: \(self?.recognizedText ?? "")")
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                Task { [weak self] in
                    await self?.stopRecording()
                }
            }
        }
    }
    
    func stopRecording() async {
        guard isRecording else { return } // 변경: 이미 녹음 중이 아닐 경우 함수 종료
        print("stop 실행")
        
        isRecording = false
        self.recognitionTask?.finish()
        audioRecorder?.stop()
        
        // 녹음을 정지했을때 시간 측정 함수를 실행합니다.
        if let audioFileURL = audioRecorder?.url {
            let voicingTime = processAudioFile(at: audioFileURL)
            DispatchQueue.main.async {
                self.voicingTime = voicingTime
                print("음성 시간: \(voicingTime)초") // 디버깅용
            }
        }
        
        cleanup()
    }

    func pauseRecording() async {
        guard isRecording else { return }
        print("Pausing recording...")

        isRecording = false

        // 비동기로 작업 일시 정지
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.audioRecorder?.pause()
                self.audioEngine.pause()
                self.recognitionTask?.cancel()
                continuation.resume()
            }
        }

        print("Recording paused.")
    }
    
    private func cleanup() {
        print("cleanup !")
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
    }
    
//    func pauseRecording() async {
//        guard isRecording else { return }
//        print("Pausing recording and STT")
//        
//        // 녹음 및 STT 중지
//        audioRecorder?.pause() // 녹음 일시 중지
//        recognitionTask?.finish() // STT 일시 정지
//        audioEngine.pause() // 오디오 엔진 일시 정지
//    }
    
    /// 사용자의 음성을 저장합니다.
    private func startAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        print("사용자 음성 녹음 시작")
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            
            let recordingSettings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: getFileURL(), settings: recordingSettings)
            audioRecorder?.record()
        } catch {
            print("Recording setup failed: \(error.localizedDescription)")
        }
    }
    
    func getFileURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory.appendingPathComponent("recording.m4a")
    }
    
    /// 시간 측정 함수
    /// 사용자가 음성을 말한 시점부터 종료시점까지 측정합니다.
    private func processAudioFile(at url: URL) -> Double {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))!
            try audioFile.read(into: buffer)
            
            let audioData = buffer.floatChannelData![0]
            let frameCount = Int(buffer.frameLength)
            let sampleRate = audioFile.fileFormat.sampleRate
            
            var startFrame: Int?
            var endFrame: Int?
            
            // 음성 시작과 끝을 찾기
            for frame in 0..<frameCount {
                if audioData[frame] > 0.03 { // 임계값 설정 필요
                    if startFrame == nil {
                        startFrame = frame
                    }
                    endFrame = frame
                }
            }
            
            if let start = startFrame, let end = endFrame {
                self.startTime = Double(start) / sampleRate
                self.endTime = Double(end) / sampleRate
            } else {
                self.startTime = nil
                self.endTime = nil
                print("음성이 발견되지 않았습니다.")
            }
            
            let voicingTime = (endTime ?? 0) - (startTime ?? 0)
            return voicingTime
            
        } catch {
            print("Audio file processing failed: \(error.localizedDescription)")
            return 0.0
        }
    }
}
