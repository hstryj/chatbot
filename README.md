---

# Chatbot

Chatbot is a project written in Elixir that integrates with the Ollama server to process questions and generate responses using large language models.
<img width="547" alt="POC2" src="https://github.com/user-attachments/assets/4f234010-3bd3-4c02-a6eb-1e5bb675c0b6" />



## Requirements

Before running the project, make sure that:

1. **You have the Ollama server installed**  
   The Ollama server can be installed following the [official Ollama documentation](https://ollama.com). Once installed, start the server with the command:
   ```bash
   ollama serve
   ```

2. **You have installed the required dependencies**  
   Fetch all Elixir dependencies by running:
   ```bash
   mix deps.get
   mix escript.build
   ```

3. **You have the required models available on Ollama**  
   To download the models, you can use the following commands:
   ```bash
   ollama pull llama3:latest
   ollama pull mistral:latest
   ```

## Running the Project

To run the application interactively in `iex`, execute:

```bash
iex -S mix
```

Then you can ask questions using the `ask/2` or `ask_stream/2` functions. Examples:

```elixir
Chatbot.OllamaAPI.ask_stream("llama3:latest", "What is the capital of France?")
Chatbot.OllamaAPI.ask_stream("mistral:latest", "What is the capital of France?")
```

---

## Debugging Mode

By default, detailed logs of JSON fragments in responses are disabled. If you want to enable debugging and see the output in real-time, go to the `config/config.exs` file and change the `debug` flag to `true`:

```elixir
config :chatbot, debug: true
```

Save the changes and restart the application.

---

## Planned Improvements

1. **Optimizing Responses:**  
   Work is underway to speed up delivering responses without having to wait for the full generation process in streaming mode (if possible).

2. **Enhanced Model Controls:**  
   Enabling selection of model parameters directly from the application.

3. **Real-Time Output Visibility:**  
   If you want to see the output in real-time while using streaming mode, make sure to enable debugging as described above.

---
