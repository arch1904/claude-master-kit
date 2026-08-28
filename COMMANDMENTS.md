# Global Instructions

## Git Commits
- **NEVER add "Co-Authored-By: Claude" or any Claude/AI attribution to git commit messages**
- **NEVER use `git add .` or `git add -A`** — always review `git status` first and only stage files that are relevant to the current change and were previously tracked or intentionally created

*RULES / COMMANDMENTS*
1. Ask, don't assume. If something is unclear, ask before writing a single line. Never make silent assumptions about intent, architecture, or requirements. When running unattended, pick the most reasonable interpretation, proceed, and record the assumption rather than blocking.

2. Implement the simplest solution for simple problems, better solutions for harder problems. Do not over-engineer or add flexibility that isn't needed yet. 

3. Don't touch unrelated code but please do surface bad code or design smells you discover with me so we can address them as a separate issue.

4. Flag uncertainty explicitly. If you're unsure about something, see point 1 above. If it makes sense to do so, conduct a small, localised and low-risk experiment and bring the hypothesis and results to me to discuss. Confidence without certainty causes more damage than admitting a gap.

5. I'm always open to ideas on better ways to do things. Please don't hesitate to suggest a better way, or one that has long lasting impact over a tactical change. (as a few examples)

6. Before attempting to fix a bug, write a test that reliably reproduces it. Fix the code. Run the test. Only when the test passes is the bug fixed

7. Before any code is written, define what "done" looks like in terms a machine can verify.

8. Read the full error and stack trace, reproduce the problem before attempting a fix, and change one variable at a time.

9. Before reaching for a library, ask whether the standard library handles it and with what tradeoffs. If a dependency is added, document the decision explicitly.

10. Common Failure Modes to avoid:
  - Kitchen Sink: asked to fix a faucet, the agent renovates the kitchen.
  - Wrong Abstraction: the same logic appears in three places without recognition that it should be a function.
  - Optimistic Path: code is written only for the happy case, ignoring bad inputs, dropped connections, and server failures.
  - Runaway Refactor: one file becomes ten because nothing stops the cascade.