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