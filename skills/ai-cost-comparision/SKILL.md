---
name: AI Cost Comparison
description: Compare LLM provider pricing, estimate project costs, and optimize token usage to minimize API spend.
triggers:
  - ai cost
  - llm pricing
  - which model
  - token cost
  - compare models
  - model pricing
  - api cost estimate
---

# AI Cost Comparison

Compare LLM provider pricing and make cost-aware model selection decisions.

## When to Use

- Choosing a model for a new feature or product
- Estimating monthly API costs before building
- Auditing an existing integration for cost reduction
- Deciding between self-hosted and API-hosted models

## Provider Pricing

**Always fetch live pricing first** — use the `duckduckgo-search` skill to query each provider's current pricing page before doing any cost math. Static tables go stale within weeks of model releases.

Fetch order:
1. Search `"Anthropic API pricing"` → anthropic.com/pricing
2. Search `"OpenAI API pricing"` → openai.com/api/pricing
3. Search `"Google Gemini API pricing"` → ai.google.dev/pricing

Extract: model name, input price per 1M tokens, output price per 1M tokens, context window, any batch/cache discounts.

**Fallback table** (use only if search is unavailable):

| Provider | Model | Input ($/1M tokens) | Output ($/1M tokens) | Notes |
|---|---|---|---|---|
| Anthropic | claude-opus-4-7 | ~$15 | ~$75 | Highest capability |
| Anthropic | claude-sonnet-4-6 | ~$3 | ~$15 | Best balance |
| Anthropic | claude-haiku-4-5 | ~$0.80 | ~$4 | Speed + cost |
| OpenAI | gpt-4o | ~$2.50 | ~$10 | Strong multimodal |
| OpenAI | gpt-4o-mini | ~$0.15 | ~$0.60 | High-volume tasks |
| Google | gemini-2.5-pro | ~$1.25 | ~$10 | Long context |
| Google | gemini-2.0-flash | ~$0.10 | ~$0.40 | Fastest/cheapest |

## Cost Estimation Process

1. Estimate average prompt tokens (system prompt + context + user message)
2. Estimate average completion tokens
3. Multiply by expected request volume
4. Apply cache hit rate reduction if using prompt caching (Anthropic: 90% discount on cache reads)
5. Factor in batch API discounts (Anthropic/OpenAI: ~50% for async batch)

**Formula:** `monthly_cost = ((input_tokens * input_rate) + (output_tokens * output_rate)) * requests_per_month / 1_000_000`

## Model Selection Decision Tree

- **Need best reasoning / complex tasks?** → Opus or GPT-4o
- **Production feature, balanced cost/quality?** → Sonnet or GPT-4o-mini
- **High-volume classification / extraction?** → Haiku, Gemini Flash, or GPT-4o-mini
- **Very long documents (>100k tokens)?** → Gemini 2.5 Pro (2M context)
- **Need structured JSON output?** → Any model with tool use / JSON mode

## Cost Reduction Strategies

- **Prompt caching** — cache static system prompts; Anthropic charges 10% of base rate on cache hits
- **Batch API** — async processing at ~50% cost; use for non-real-time workloads
- **Model routing** — use cheap model for simple tasks, expensive for complex; route by complexity score
- **Output compression** — instruct model to be concise; shorter completions = lower cost
- **Context pruning** — trim conversation history; don't send full history for every turn
- **Self-hosted** — Llama 3, Mistral, Qwen via Ollama or cloud GPU for high-volume predictable loads

## Output

Produce a cost estimate summary:

```
Model: claude-sonnet-4-6
Avg input tokens: 1,200
Avg output tokens: 400
Monthly requests: 50,000
Cache hit rate: 70%

Uncached cost:  $10.50/mo
Cached cost:    $3.75/mo
Batch (if applicable): $1.87/mo

Recommendation: enable prompt caching on system prompt; route simple queries to haiku.
```

## Anti-Patterns

- Defaulting to the most capable model without cost analysis
- Not accounting for prompt caching when estimating Anthropic costs
- Ignoring batch API for async use cases
- Using output token estimates from dev/test (prod prompts are usually longer)
