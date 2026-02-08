# OpenClaw concept notes

Purpose: Keep a high-level map of how OpenClaw works and where to look for details.

## Source docs
- docs/concepts/architecture.md
- docs/concepts/agent.md
- docs/concepts/agent-loop.md
- docs/concepts/agent-workspace.md
- docs/nodes/index.md

## System overview
- A single Gateway daemon owns all messaging surfaces and exposes a WebSocket API for requests and events.
- Operator clients (mac app, CLI, web UI, automations) connect over WebSocket to issue requests and subscribe to events.
- Nodes connect to the same WebSocket server with role node and declare caps, commands, and permissions.
- The Gateway runs the embedded agent runtime, streams agent and chat events, and sends replies back to channels and clients.
- A Canvas host serves agent-editable HTML and A2UI for node displays.

## Agent runtime and workspace
- OpenClaw embeds a single agent runtime derived from pi-mono; OpenClaw owns session management and tool wiring.
- The workspace is required and is the default cwd for tools; bootstrap files are injected at session start (AGENTS.md, SOUL.md, TOOLS.md, USER.md, IDENTITY.md, BOOTSTRAP.md).
- Skills load from bundled, managed, and workspace directories (workspace wins on conflicts).
- Sessions are stored as JSONL under ~/.openclaw/agents/<agentId>/sessions.
- The workspace is not a hard sandbox; enable sandboxing if isolation is required.

## Agent loop summary
- Entry points: gateway agent RPC or CLI agent command. agent.wait blocks for lifecycle end or error.
- The gateway validates params, resolves session, returns runId, then invokes the embedded agent runtime.
- Runs are serialized per session lane (optionally global lane), which keeps history and tool calls consistent.
- The runtime builds the session, assembles the system prompt, streams assistant and tool deltas, and enforces timeouts.
- Stream events are mapped to OpenClaw lifecycle, assistant, and tool streams; chat finals emit on lifecycle end or error.
- Hooks exist for bootstrap, before_agent_start, before_tool_call, after_tool_call, agent_end, and compaction boundaries.

## Diagrams
- system-diagram.md
- agent-loop-diagram.md
- agent-loop-diagram-detailed.md

## Glossary
- glossary.md
