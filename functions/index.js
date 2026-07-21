const functions = require("firebase-functions");
const { OpenAI } = require("openai");

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY, // Set via Firebase Secret Manager
});

// ─── Default Persona Definitions ─────────────────────────────────────────────
const DEFAULT_PERSONAS = [
  {
    id: "persona_public",
    name: "Public Broadcaster",
    bias: "Neutral, civic-minded, focuses on public interest and democratic accountability.",
    ethics: "Very high. Strict fact-checking, no sensationalism, balanced perspectives required.",
    clickbaitThreshold: 15,
  },
  {
    id: "persona_tabloid",
    name: "Commercial Tabloid",
    bias: "Sensationalist. Heavily favors high emotional impact, celebrity gossip, crime, and scandal.",
    ethics: "Low. Will publish unverified rumors if engaging enough. Prioritizes clicks over truth.",
    clickbaitThreshold: 85,
  },
  {
    id: "persona_independent",
    name: "Independent",
    bias: "Progressive, anti-establishment. Prioritizes underreported stories, activism, and systemic issues.",
    ethics: "High on principles, but may take a strong editorial stance. Avoids corporate-friendly narratives.",
    clickbaitThreshold: 40,
  },
];

// ─── Cloud Function ───────────────────────────────────────────────────────────
exports.generateAINewspapers = functions
  .runWith({
    timeoutSeconds: 120,
    memory: "512MB",
    secrets: ["OPENAI_API_KEY"],
  })
  .https.onCall(async (data, context) => {
    const { newsItems } = data;

    if (!newsItems || !Array.isArray(newsItems) || newsItems.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "newsItems must be a non-empty array."
      );
    }

    // ── Build the batch prompt ────────────────────────────────────────────────
    const newsJson = JSON.stringify(
      newsItems.map((n) => ({
        id: n.id,
        headline: n.headline,
        summary: n.summary,
        category: n.category,
        sensationalismScore: n.sensationalismScore,
        biasIndex: n.biasIndex,
        tags: n.tags,
      })),
      null,
      2
    );

    const personasJson = JSON.stringify(DEFAULT_PERSONAS, null, 2);

    const systemPrompt = `You are the simulation engine for "GateKeeper", an educational game about news selection bias (Gatekeeping Theory by Kurt Lewin & David Manning White).

CONTEXT:
You will receive a pool of news items and 3 editor personas. Each persona has distinct values, ethics, and a clickbaitThreshold (0–100, where 100 = will publish any sensational content, 0 = only calm factual pieces).

TASK:
Simulate each of the 3 editor personas independently reviewing the provided news pool.
For EACH persona:
1. SELECT between 3 and 6 news items to publish, based STRICTLY on their bias, ethics, and clickbaitThreshold. Do NOT select fewer than 3 or more than 6.
2. REJECT all remaining items.
3. Write a brief, 1-sentence "Justification Log" for EVERY item in the pool (both selected and rejected), written in the first-person voice of THAT persona's character. Examples:
   - Public Broadcaster on a celebrity scandal: "This story lacks public interest value and would undermine our credibility."
   - Tabloid on the same story: "This is pure gold — our readers live for this kind of drama."
   - Independent on a corporate tax story: "This exposes systemic inequality that our mainstream competitors won't touch."

CRITICAL RULES:
- Your output MUST be valid JSON only, no markdown, no preamble, no explanation.
- Justifications MUST cover ALL items in the pool for each persona.
- Do NOT let personas select the same set of articles; their choices should reflect their distinct biases.

OUTPUT FORMAT (strict JSON):
{
  "persona_public": {
    "selected": ["news_id_1", "news_id_3"],
    "justifications": {
      "news_id_1": "justification string from this persona's voice",
      "news_id_2": "justification string from this persona's voice"
    }
  },
  "persona_tabloid": { ... },
  "persona_independent": { ... }
}`;

    const userPrompt = `NEWS POOL (${newsItems.length} items):
${newsJson}

EDITOR PERSONAS (3 personas):
${personasJson}

Generate the three distinct newspapers now.`;

    try {
      const completion = await openai.chat.completions.create({
        model: "gpt-4o",
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ],
        temperature: 0.85,
        max_tokens: 4000,
      });

      const responseText = completion.choices[0].message.content;
      const result = JSON.parse(responseText);

      // Validate structure
      const expectedPersonas = ["persona_public", "persona_tabloid", "persona_independent"];
      for (const pid of expectedPersonas) {
        if (!result[pid] || !result[pid].selected || !result[pid].justifications) {
          throw new Error(`Invalid structure for persona: ${pid}`);
        }
        if (result[pid].selected.length < 3 || result[pid].selected.length > 6) {
          throw new Error(
            `${pid} selected ${result[pid].selected.length} articles, expected 3–6`
          );
        }
      }

      return result;
    } catch (error) {
      console.error("OpenAI API error:", error);
      throw new functions.https.HttpsError(
        "internal",
        `Failed to generate AI newspapers: ${error.message}`
      );
    }
  });
