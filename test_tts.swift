import Foundation

let apiKey = "sk-xlaqakltfjnjjiipeffzxkpfgqbcvyvawrtsyjxscpwvbxqq"
let url = URL(string: "https://api.siliconflow.cn/v1/audio/speech")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let body: [String: Any] = [
    "model": "fishaudio/fish-speech-1.5",
    "input": "hello",
    "voice": "fishaudio/fish-speech-1.5:alex",
    "response_format": "wav"
]
request.httpBody = try! JSONSerialization.data(withJSONObject: body)

let semaphore = DispatchSemaphore(value: 0)
let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let data = data {
        let path = "test_output.wav"
        try! data.write(to: URL(fileURLWithPath: path))
        print("Wrote \(data.count) bytes to \(path)")
        
        let header = [UInt8](data.prefix(64))
        print("Header: \(header)")
    } else if let error = error {
        print("Error: \(error)")
    }
    semaphore.signal()
}
task.resume()
semaphore.wait()
