# Reflection – Week 2

**Matthew Bardi**

Week 2 of the DevOps Micro Internship with Agentic AI gave me a much clearer understanding of how AI agents can support real technical work. Before this week, I mainly viewed Claude Code as a tool that could answer questions or generate code. Through the assignments, I learned that it can also work as a structured agent that follows project instructions, uses reusable skills, delegates tasks to subagents, connects to external systems, and remembers important project rules.

One of the most useful topics for me was **Skills**. I learned how to create reusable commands that can perform repeatable tasks, such as scaffolding Terraform files or running validation. This helped me understand how automation can be organized into clear, reusable building blocks instead of repeatedly typing the same instructions.

I also worked with **Subagents**. I created specialized agents for tasks such as security review, cost optimization, and Terraform writing. This showed me that one agent does not need to handle every responsibility. Different agents can be given focused roles, similar to how members of a technical team have different areas of expertise.

Another important topic was **MCP**, which allowed Claude Code to connect to GitHub and retrieve repository information. This helped me understand how agentic tools can interact with external platforms rather than working only with local files.

The most challenging assignment involved **Hooks and Permissions**. I configured controls that block destructive requests and dangerous commands such as `terraform destroy`. I also added logging for selected Terraform operations. This taught me that AI agents need strong safety controls, especially when they can interact with infrastructure.

I also tested **persistent memory**. I saved project rules, closed Claude Code completely, opened a fresh session, and confirmed that it still remembered the hero section colors and the rule that JavaScript must not be used. This was one of the clearest demonstrations of how an agent can maintain project knowledge across sessions.

The main habit I plan to implement is to document project rules before starting work and verify every AI-generated action before accepting it. This week taught me that AI can improve productivity, but human review, clear instructions, and safety controls remain essential.