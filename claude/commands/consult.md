---
description: Get a critical second opinion from Codex on the current discussion
argument-hint: <question or topic to get a second opinion on>
allowed-tools: Bash
---

The user wants to consult an external model (Codex) for a critical second opinion.

**Topic:** $ARGUMENTS

Follow these steps:

1. **Summarize the current conversation context** (max ~800 words):
   - What task is being worked on
   - What approaches/options have been discussed
   - Key decisions, constraints, and tradeoffs identified
   - Current direction or recommendation, if any

2. **Build the consultation prompt** by writing it to a temp file via Bash. The prompt must include:
   - The context summary from step 1
   - The user's specific question/topic
   - Instructions telling Codex to be a critical reviewer (not just agree)

   Use this template for the prompt content:

   ---
   ## Consultation Request

   ### Context
   [your context summary here]

   ### Question
   [user's question here]

   ### Your Role
   You are an independent technical reviewer. Do NOT just agree with the proposed approach. Your job:
   1. Critically evaluate the approach — find weaknesses, edge cases, and risks
   2. Suggest concrete alternative approaches if you see better options
   3. Identify assumptions that may be wrong
   4. Be direct and specific. Vague agreement is useless.
   5. If the approach is actually solid, say so — but explain WHY, don't just affirm
   ---

3. **Call Codex** via Bash:
   ```
   PROMPT_FILE=$(mktemp /tmp/consult_prompt.XXXXXX)
   RESP_FILE=$(mktemp /tmp/consult_resp.XXXXXX)
   # write prompt to PROMPT_FILE, then:
   /opt/homebrew/bin/codex exec -s read-only --ephemeral -o "$RESP_FILE" - < "$PROMPT_FILE"
   cat "$RESP_FILE"
   rm -f "$PROMPT_FILE" "$RESP_FILE"
   ```

4. **Present the response** clearly to the user. Highlight key disagreements or alternative suggestions from Codex.
