# Glossary

## Agent loop
The full run that turns a message into actions and a reply. It includes context assembly, model inference, tool calls, streaming, and persistence.

## Agent runtime
The embedded pi-mono derived runtime OpenClaw uses for model inference and tool orchestration. OpenClaw owns session management and tool wiring.

## Bootstrap files
User-editable files injected into the system prompt at session start. Examples include AGENTS.md, SOUL.md, TOOLS.md, USER.md, IDENTITY.md, and BOOTSTRAP.md.

## Canvas host
A lightweight server that hosts agent-editable HTML and A2UI for node displays.

## Compaction
A process that trims or summarizes session history to stay within model context limits, with optional retries.

## Gateway
The long-lived daemon that owns messaging provider connections, exposes the WebSocket API, and runs the agent loop.

## Hooks
Lifecycle interception points to inject context or inspect results. Examples include before_agent_start, before_tool_call, after_tool_call, and agent_end.

## Node
A companion device that connects to the Gateway with role node and exposes commands like camera, canvas, or system.run.

## Queue lane
Per-session serialization that ensures only one agent run writes to a session at a time. Optional global lanes can add stricter ordering.

## Reply shaping
Post-processing that assembles the final outputs, filters NO_REPLY, and deduplicates tool confirmations before a final reply is sent.

## Run ID
A unique identifier returned when a run is accepted. It lets clients track streaming events and final status.

## Session
A persisted conversation state stored as JSONL under ~/.openclaw/agents/<agentId>/sessions. Sessions are keyed by channel and routing.

## Session key
A derived identifier that maps incoming messages to a session. Used for routing and queue lane selection.

## Skills
Scripted capabilities loaded from bundled, managed, or workspace locations. Workspace skills override others on name conflicts.

## Streaming
Live emission of assistant deltas, tool events, and lifecycle events as the run progresses.

## Tools
Callable functions that let the model act on the system, such as exec, messaging, or node commands.

## Workspace
The required working directory for tools and context. It is the default cwd and stores bootstrap files and optional skills.
