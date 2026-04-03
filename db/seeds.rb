Provider.seed!
puts "Seeded #{Provider.count} providers"

LlmProvider.seed!
puts "Seeded #{LlmProvider.count} LLM providers"

# LLM Model seed data — prices per 1M tokens (USD)
llm_models = {
  "anthropic" => [
    { model_name: "Claude Opus 4.6", model_id: "claude-opus-4-6", input_price_per_mtok: 15, output_price_per_mtok: 75, context_window: 200, max_output_tokens: 32_000, supports_vision: true, supports_tool_use: true, supports_extended_thinking: true },
    { model_name: "Claude Sonnet 4.5", model_id: "claude-sonnet-4-5-20250929", input_price_per_mtok: 3, output_price_per_mtok: 15, context_window: 200, max_output_tokens: 16_000, supports_vision: true, supports_tool_use: true, supports_extended_thinking: true },
    { model_name: "Claude Haiku 4.5", model_id: "claude-haiku-4-5-20251001", input_price_per_mtok: 1, output_price_per_mtok: 5, context_window: 200, max_output_tokens: 8_192, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false },
    { model_name: "Claude Sonnet 3.5 v2", model_id: "claude-3-5-sonnet-20241022", input_price_per_mtok: 3, output_price_per_mtok: 15, context_window: 200, max_output_tokens: 8_192, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false }
  ],
  "openai" => [
    { model_name: "GPT-4.1", model_id: "gpt-4.1", input_price_per_mtok: 2, output_price_per_mtok: 8, context_window: 1000, max_output_tokens: 32_768, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false },
    { model_name: "GPT-4.1 Mini", model_id: "gpt-4.1-mini", input_price_per_mtok: 0.4, output_price_per_mtok: 1.6, context_window: 1000, max_output_tokens: 32_768, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false },
    { model_name: "GPT-4.1 Nano", model_id: "gpt-4.1-nano", input_price_per_mtok: 0.1, output_price_per_mtok: 0.4, context_window: 1000, max_output_tokens: 32_768, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false },
    { model_name: "GPT-4o", model_id: "gpt-4o", input_price_per_mtok: 2.5, output_price_per_mtok: 10, context_window: 128, max_output_tokens: 16_384, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false },
    { model_name: "GPT-4o Mini", model_id: "gpt-4o-mini", input_price_per_mtok: 0.15, output_price_per_mtok: 0.6, context_window: 128, max_output_tokens: 16_384, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false },
    { model_name: "o3", model_id: "o3", input_price_per_mtok: 2, output_price_per_mtok: 8, context_window: 200, max_output_tokens: 100_000, supports_vision: true, supports_tool_use: true, supports_extended_thinking: true },
    { model_name: "o3 Mini", model_id: "o3-mini", input_price_per_mtok: 1.1, output_price_per_mtok: 4.4, context_window: 200, max_output_tokens: 100_000, supports_vision: false, supports_tool_use: true, supports_extended_thinking: true },
    { model_name: "o4 Mini", model_id: "o4-mini", input_price_per_mtok: 1.1, output_price_per_mtok: 4.4, context_window: 200, max_output_tokens: 100_000, supports_vision: true, supports_tool_use: true, supports_extended_thinking: true }
  ],
  "google" => [
    { model_name: "Gemini 2.5 Pro", model_id: "gemini-2.5-pro", input_price_per_mtok: 1.25, output_price_per_mtok: 10, context_window: 1000, max_output_tokens: 65_536, supports_vision: true, supports_tool_use: true, supports_extended_thinking: true },
    { model_name: "Gemini 2.5 Flash", model_id: "gemini-2.5-flash", input_price_per_mtok: 0.15, output_price_per_mtok: 0.6, context_window: 1000, max_output_tokens: 65_536, supports_vision: true, supports_tool_use: true, supports_extended_thinking: true },
    { model_name: "Gemini 2.0 Flash", model_id: "gemini-2.0-flash", input_price_per_mtok: 0.1, output_price_per_mtok: 0.4, context_window: 1000, max_output_tokens: 8_192, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false }
  ],
  "meta" => [
    { model_name: "Llama 4 Scout", model_id: "llama-4-scout", input_price_per_mtok: 0.08, output_price_per_mtok: 0.3, context_window: 10_000, max_output_tokens: 128_000, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false },
    { model_name: "Llama 4 Maverick", model_id: "llama-4-maverick", input_price_per_mtok: 0.15, output_price_per_mtok: 0.6, context_window: 1000, max_output_tokens: 128_000, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false }
  ],
  "mistral" => [
    { model_name: "Mistral Large", model_id: "mistral-large-latest", input_price_per_mtok: 2, output_price_per_mtok: 6, context_window: 128, max_output_tokens: 8_192, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false },
    { model_name: "Mistral Small", model_id: "mistral-small-latest", input_price_per_mtok: 0.2, output_price_per_mtok: 0.6, context_window: 128, max_output_tokens: 8_192, supports_vision: true, supports_tool_use: true, supports_extended_thinking: false },
    { model_name: "Codestral", model_id: "codestral-latest", input_price_per_mtok: 0.3, output_price_per_mtok: 0.9, context_window: 256, max_output_tokens: 8_192, supports_vision: false, supports_tool_use: true, supports_extended_thinking: false }
  ]
}

llm_models.each do |slug, models|
  provider = LlmProvider.find_by!(slug: slug)
  models.each do |attrs|
    LlmModel.find_or_create_by!(llm_provider: provider, model_id: attrs[:model_id]) do |m|
      m.assign_attributes(attrs.except(:model_id).merge(llm_provider: provider))
    end
  end
end

puts "Seeded #{LlmModel.count} LLM models"
