import Foundation

let apiKey = "sk-xlaqakltfjnjjiipeffzxkpfgqbcvyvawrtsyjxscpwvbxqq"
let url = URL(string: "https://api.siliconflow.cn/v1/audio/speech")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let body: [String: Any] = [
    "model": "FunAudioLLM/CosyVoice2-0.5B",
    "input": "こんにちは",
    "voice": "FunAudioLLM/CosyVoice2-0.5B:alex",
    "response_format": "wav"
]
request.httpBody = try! JSONSerialization.data(withJSONObject: body)

let semaphore = DispatchSemaphore(value: 0)
let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let data = data {
        if let httpResp = response as? HTTPURLResponse {
            print("Status: \(httpResp.statusCode)")
            if httpResp.statusCode != 200 {
                if let errStr = String(data: data, encoding: .utf8) {
                    print(errStr)
                }
            } else {
                print("Success")
            }
        }
    }
    semaphore.signal()
}
task.resume()
semaphore.wait()
