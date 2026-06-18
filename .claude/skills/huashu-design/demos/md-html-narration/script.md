---
title: Markdown or HTML, That's a Foolish Question
gap: 0.5
---

## opening
A few days ago, [[cue:thariq]]Thariq from the Claude Code team published a viral post.
The title was just one sentence: "HTML is the new markdown."
He said he barely writes Markdown files anymore; he just has AI generate HTML for him.
Five million views, and X immediately erupted in debate.
One side was the Markdown faction, [[cue:two-camps]]believing Markdown is the source code of the AI era.
The other side believed Thariq was right: HTML is the ultimate answer.

## md-side
The Markdown faction actually has pretty solid arguments.
Look at AGENTS.md published by OpenAI last year; [[cue:agents-md]]it's used by over 60,000 projects, with AWS, Anthropic, Google, Microsoft, and OpenAI—half the AI world—donating it to the Linux Foundation as an open standard.
And Karpathy's llm-wiki is essentially a three-tier Markdown structure; its single CLAUDE.md file alone has 50,000 stars.
Cloudflare once ran some real tests on a blog post: [[cue:token-saving]]the HTML version took 16,000 tokens, but converting it to Markdown took only 3,000.
An 80% savings.
GitHub also famously stated that documentation is no longer just describing code; [[cue:doc-is-code]]documentation *is* code.

## html-side
But the HTML faction isn't wrong either.
I agree with several arguments in Thariq's post.
First is spatial information. [[cue:spatial]]Diffs, call graphs, and architecture diagrams naturally have a spatial dimension. Markdown flattens them into lines of text, whereas HTML lets you compare them side-by-side. The comprehension efficiency is on a completely different level.
Second is the dynamic experience. [[cue:dynamic]]When building a product prototype, describing what color a button turns when clicked or its easing curve in text is useless. HTML lets you see it directly.
Third is structured reading. [[cue:structured]]Collapsible sections, tabbed code blocks, and sidebar glossaries are completely different from linearly piling up the same text.
With Anthropic's current Live Artifacts, HTML has upgraded from static output to an interactive dashboard that pulls real-time data.

## the-real-question
After reading it, I wanted to say: [[cue:reveal]]they are arguing over a foolish question.
Both sides won.
But they won different questions.
The Markdown faction answered: [[cue:question-md]]What do we use to *write*?
The HTML faction answered: [[cue:question-html]]What do we give people to *view*?
These are two different questions.
How could one replace the other?

## the-split
I think the real question is this.
Markdown and HTML are not replacements for each other; [[cue:split]]they represent a division of labor.
In the past, you wrote Markdown and you read Markdown.
You had to compromise, so Markdown won out.
But since the rise of AI, [[cue:ai-changes]]a new situation has emerged for the first time.
The cost of production can be absorbed by AI.
The heavy price of HTML is carried by the AI for you.
You are only responsible for consuming it.
What used to require compromise is now split into extreme optimization on both ends.
The production side needs to be light, fast, and token-efficient, [[cue:md-side-win]]so it uses Markdown.
The consumption side needs to be rich, visual, and shareable, [[cue:html-side-win]]so it uses HTML.
Both peaks are claimed.
No one needs the compromise in the middle anymore.

## activity-proof
The cleanest living proof is Thariq himself.
In March, he published a Skills guide, [[cue:thariq-march]]emphasizing that the core is still Markdown.
In May, he published "HTML is the new markdown."
The same person, [[cue:same-person]]reaching both peaks without any conflict.
The Karpathy and Lex Fridman duo is the same.
The core is a Markdown wiki, [[cue:karpathy-lex]]and the shell is dynamic HTML.
Lex didn't replace Karpathy; he just added a consumption layer on top of Karpathy's base.

## closing
So the next time you want to argue about this, [[cue:final]]ask yourself one question first.
Are you currently facing a "writing" task or a "viewing" task?
Write [[cue:md-final]]with Markdown.
View [[cue:html-final]]with HTML.
The tools will handle the transition for you.
It's time to let go of the arguments.
