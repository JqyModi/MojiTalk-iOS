## 对话 SSE 流式数据集成 CURL 请求示例：

curl -X POST https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions \
-H "Authorization: Bearer sk-6c772637b2a84fb8a8206e86806a9d66" \
-H "Content-Type: application/json" \
-d '{
    "model": "qwen-plus",
    "messages": [
        {
            "role": "user",
            "content": "你是谁？"
        }
    ]
}'

返回示例：
{"choices":[{"message":{"role":"assistant","content":"你好！我是通义千问（Qwen），阿里巴巴集团旗下的超大规模语言模型。我可以回答问题、创作文字，比如写故事、写公文、写邮件、写剧本、逻辑推理、编程等等，还能表达观点，玩游戏等。如果你有任何问题或需要帮助，欢迎随时告诉我！😊"},"finish_reason":"stop","index":0,"logprobs":null}],"object":"chat.completion","usage":{"prompt_tokens":11,"completion_tokens":65,"total_tokens":76,"prompt_tokens_details":{"cached_tokens":0}},"created":1770285809,"system_fingerprint":null,"model":"qwen-plus","id":"chatcmpl-63414f89-e97d-9449-8f3c-1e72cf1f6e40"}


## TTS 流式数据集成 CURL 请求示例：
curl -X POST 'https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation' \
-H "Authorization: Bearer sk-6c772637b2a84fb8a8206e86806a9d66" \
-H 'Content-Type: application/json' \
-d '{
    "model": "qwen3-tts-flash",
    "input": {
        "text": "那我来给大家推荐一款T恤，这款呢真的是超级好看，这个颜色呢很显气质，而且呢也是搭配的绝佳单品，大家可以闭眼入，真的是非常好看，对身材的包容性也很好，不管啥身材的宝宝呢，穿上去都是很好看的。推荐宝宝们下单哦。",
        "voice": "Cherry",
        "language_type": "Chinese"
    }
}'

返回示例：
{"output":{"audio":{"data":"","expires_at":1770650166,"id":"audio_658ad5f3-32f6-4fdc-aef8-f89535b1110a","url":"http://dashscope-result-bj.oss-cn-beijing.aliyuncs.com/1d/9a/20260208/0d5ce7dd/46197fdd-17a6-4398-b115-663aa32fe11f.wav?Expires=1770650166&OSSAccessKeyId=LTAI5tKPD3TMqf2Lna1fASuh&Signature=LcTVNN%2BOJPWVVKoHTjUoNssIm4E%3D"},"finish_reason":"stop"},"usage":{"characters":195},"request_id":"658ad5f3-32f6-4fdc-aef8-f89535b1110a"}



## 录音文件识别集成 CURL 请求示例：
- 文档介绍：https://bailian.console.aliyun.com/cn-beijing/?tab=api#/api/?type=model&url=2986952
- 请求示例：待补充
- 录音文件识别集成 CURL 响应示例：待补充


## Supabase 项目配置信息（建议保存）：
项目名称：MojiTalk-Auth
Project URL: https://rrzbufeslmqphlboulwi.supabase.co
API Key (Anon): sb_publishable_2evChfbaOKKrx0Z_juvmgg_CEhxnaql