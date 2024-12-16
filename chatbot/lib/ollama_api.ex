defmodule Chatbot.OllamaAPI do
  @moduledoc """
  Moduł do komunikacji z API Ollama.
  """

  @base_url "http://localhost:11434"
  @headers [{"Content-Type", "application/json"}]
  @default_recv_timeout 60_000

  # Listowanie modeli
  def list_models do
    url = "#{@base_url}/api/tags"

    case HTTPoison.get(url, @headers, recv_timeout: @default_recv_timeout) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Jason.decode!(body)["models"]}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "Błąd: otrzymano kod HTTP #{code}"}

      {:error, reason} ->
        {:error, "Nie udało się połączyć z API: #{inspect(reason)}"}
    end
  end

  # Funkcja zadawania pytania (bez strumieniowania)
  def ask(model, question) do
    url = "#{@base_url}/api/chat"

    body = %{
      "model" => model,
      "messages" => [
        %{"role" => "system", "content" => "You are a helpful assistant."},
        %{"role" => "user", "content" => question}
      ]
    }

    case HTTPoison.post(url, Jason.encode!(body), @headers, recv_timeout: @default_recv_timeout) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        parse_response(body)

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "Błąd: otrzymano kod HTTP #{code}"}

      {:error, reason} ->
        {:error, "Nie udało się połączyć z API: #{inspect(reason)}"}
    end
  end

  # Funkcja zadawania pytania (strumieniowanie)
  def ask_stream(model, question) do
    url = "#{@base_url}/api/chat"

    body = %{
      "model" => model,
      "messages" => [
        %{"role" => "system", "content" => "You are a helpful assistant."},
        %{"role" => "user", "content" => question}
      ],
      "stream" => true
    }

    case HTTPoison.post(url, Jason.encode!(body), @headers, recv_timeout: @default_recv_timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, stream_response(body)}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "Błąd: otrzymano kod HTTP #{code}"}

      {:error, reason} ->
        {:error, "Nie udało się połączyć z API: #{inspect(reason)}"}
    end
  end

  # Funkcja przetwarzania strumieniowej odpowiedzi
  defp stream_response(response_body) do
    response_body
    |> String.split(~r/}\s*{/, trim: true)
    |> Enum.reduce("", fn fragment, acc ->
      # Doprowadzenie fragmentu do poprawnego formatu JSON
      fragment =
        fragment
        |> String.trim()
        |> String.replace_suffix("\n", "") # Usunięcie końcowego znaku nowej linii
        |> (fn f -> if String.starts_with?(f, "{"), do: f, else: "{" <> f end).()
        |> (fn f -> if String.ends_with?(f, "}"), do: f, else: f <> "}" end).()

      if Chatbot.Application.debug?() do
        IO.puts("Otrzymany fragment JSON: #{fragment}")
      end

      # Dekodowanie fragmentu JSON
      case Jason.decode(fragment) do
        {:ok, %{"message" => %{"content" => content}}} ->
          IO.write(content) # Wyświetlanie fragmentu odpowiedzi w czasie rzeczywistym
          acc <> content

        {:ok, _} ->
          acc

        {:error, reason} ->
          if Chatbot.Application.debug?() do
            IO.puts("Błąd dekodowania fragmentu: #{inspect(reason)}")
          end

          acc
      end
    end)
  end

  # Funkcja przetwarzania standardowej odpowiedzi
  defp parse_response(body) do
    case Jason.decode(body) do
      {:ok, %{"message" => %{"content" => content}}} ->
        {:ok, content}

      {:ok, _} ->
        {:error, "Nieoczekiwany format odpowiedzi."}

      {:error, reason} ->
        {:error, "Nie udało się zdekodować odpowiedzi API: #{inspect(reason)}"}
    end
  end
end

