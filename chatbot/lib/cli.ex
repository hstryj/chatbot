defmodule Chatbot.CLI do
  def main(args) do
    case args do
      ["--list"] -> list_models()
      ["--model=" <> model, "--prompt=" <> prompt] -> ask_model(model, prompt)
      _ -> IO.puts("Nieprawidłowe argumenty. Użyj --list lub --model=MODEL --prompt=PROMPT.")
    end
  end

  defp list_models do
    case Chatbot.OllamaAPI.list_models() do
      {:ok, models} ->
        IO.puts("Dostępne modele:")
        Enum.each(models, fn model ->
          IO.puts("- #{model["model"]} (#{model["details"]["parameter_size"]}, #{model["details"]["quantization_level"]})")
        end)

      {:error, error} ->
        IO.puts("Błąd: #{error}")
    end
  end

  defp ask_model(model, prompt) do
    case Chatbot.OllamaAPI.ask(model, prompt) do
      {:ok, response} -> IO.puts("Odpowiedź modelu: #{response}")
      {:error, error} -> IO.puts("Błąd: #{error}")
    end
  end
end

