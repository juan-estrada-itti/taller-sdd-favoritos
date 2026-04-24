#!/bin/bash
set -e
INPUT=$(cat)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PAREJA_ID="${PAREJA_ID:-unknown}"
CAPTURE="${PIPELINE_CAPTURE_PROMPTS:-0}"

PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || echo "")

SKILL="null"
if [[ "$PROMPT" =~ ^/([a-zA-Z_-]+) ]]; then
  SKILL="${BASH_REMATCH[1]}"
fi

FASE="unknown"
case "$SKILL" in
  office-hours) FASE="00-discovery" ;;
  create-prd) FASE="01-prd" ;;
  rfc-builder) FASE="02-rfc" ;;
  contract-define) FASE="03-contracts" ;;
  rfc-to-adr) FASE="04-adrs" ;;
  user-story-builder) FASE="05-stories" ;;
  story-to-plan) FASE="06-plans" ;;
  task-dependency-analyzer) FASE="07-dag" ;;
  code-review) FASE="08-reviews" ;;
  sdd-router) FASE="router-query" ;;
  lessons-harvester) FASE="lessons-capture" ;;
esac

EVENT="prompt"
[ "$SKILL" != "null" ] && EVENT="skill_invoke"
[ "$SKILL" == "sdd-router" ] && EVENT="router_query"
[ "$SKILL" == "lessons-harvester" ] && EVENT="lessons_capture"

OUT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}/docs/telemetry"
mkdir -p "$OUT_DIR"
FILE="$OUT_DIR/events-${PAREJA_ID}.jsonl"

if [ "$CAPTURE" == "1" ]; then
  jq -nc --arg ts "$TIMESTAMP" --arg skill "$SKILL" --arg fase "$FASE" \
    --arg pareja "$PAREJA_ID" --arg event "$EVENT" --arg prompt "${PROMPT:0:200}" \
    '{timestamp:$ts,skill:$skill,fase:$fase,pareja_id:$pareja,event_type:$event,prompt:$prompt}' >> "$FILE"
else
  jq -nc --arg ts "$TIMESTAMP" --arg skill "$SKILL" --arg fase "$FASE" \
    --arg pareja "$PAREJA_ID" --arg event "$EVENT" \
    '{timestamp:$ts,skill:$skill,fase:$fase,pareja_id:$pareja,event_type:$event}' >> "$FILE"
fi
exit 0
