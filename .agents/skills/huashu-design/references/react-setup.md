# React + Babel Project Specification

Technical specifications that must be followed when building prototypes with HTML+React+Babel. Failing to follow them will break things.

## Pinned Script Tags (Must Use These Versions)

Place these three script tags in the `<head>` of the HTML, using **pinned versions + integrity hashes**:

```html
<script src="https://unpkg.com/react@18.3.1/umd/react.development.js" integrity="sha384-hD6/rw4ppMLGNu3tX5cjIb+uRZ7UkRJ6BPkLpg4hAu/6onKUg4lLsHAs9EBPT82L" crossorigin="anonymous"></script>
<script src="https://unpkg.com/react-dom@18.3.1/umd/react-dom.development.js" integrity="sha384-u6aeetuaXnQ38mYT8rp6sbXaQe3NL9t+IBXmnYxwkUI2Hw4bsp2Wvmx4yRQF1uAm" crossorigin="anonymous"></script>
<script src="https://unpkg.com/@babel/standalone@7.29.0/babel.min.js" integrity="sha384-m08KidiNqLdpJqLq95G/LEi8Qvjl/xUYll3QILypMoQ65QorJ9Lvtp2RXYGBFj1y" crossorigin="anonymous"></script>
```

**DO NOT** use unpinned versions like `react@18` or `react@latest`—this will lead to version drift/caching issues.

**DO NOT** omit `integrity`—this is your line of defense if the CDN is hijacked or tampered with.

## File Structure

```
ProjectName/
├── index.html               # Main HTML
├── components.jsx           # Component file (loaded via type="text/babel")
├── data.js                  # Data file
└── styles.css               # Extra CSS (optional)
```

Loading method in HTML:

```html
<!-- Load React + Babel first -->
<script src="https://unpkg.com/react@18.3.1/..."></script>
<script src="https://unpkg.com/react-dom@18.3.1/..."></script>
<script src="https://unpkg.com/@babel/standalone@7.29.0/..."></script>

<!-- Then your component files -->
<script type="text/babel" src="components.jsx"></script>
<script type="text/babel" src="pages.jsx"></script>

<!-- Finally, the main entry point -->
<script type="text/babel">
  const root = ReactDOM.createRoot(document.getElementById('root'));
  root.render(<App />);
</script>
```

**DO NOT** use `type="module"`—it will conflict with Babel.

## Three Unbreakable Rules

### Rule 1: The `styles` object must use a unique name

**Incorrect** (will definitely break when there are multiple components):
```jsx
// components.jsx
const styles = { button: {...}, card: {...} };

// pages.jsx  ← Overridden due to duplicate name!
const styles = { container: {...}, header: {...} };
```

**Correct**: Use a unique prefix for the styles in each component file.

```jsx
// terminal.jsx
const terminalStyles = { 
  screen: {...}, 
  line: {...} 
};

// sidebar.jsx
const sidebarStyles = { 
  container: {...}, 
  item: {...} 
};
```

**Or use inline styles** (recommended for small components):
```jsx
<div style={{ padding: 16, background: '#111' }}>...</div>
```

This rule is **non-negotiable**. Every time you write `const styles = {...}`, it must be replaced with a specific name, otherwise the application will throw runtime errors when multiple components are loaded.

### Rule 2: Scope is not shared; manual export is required

**Key Insight**: Each `<script type="text/babel">` is compiled independently by Babel, and they **do not share scope**. The `Terminal` component defined in `components.jsx` is **undefined by default** in `pages.jsx`.

**Solution**: At the end of each component file, export the components/utilities you want to share to `window`:

```jsx
// End of components.jsx
function Terminal(props) { ... }
function Line(props) { ... }
const colors = { green: '#...', red: '#...' };

Object.assign(window, {
  Terminal, Line, colors,
  // List everything you want to use elsewhere here
});
```

Then `pages.jsx` can directly use `<Terminal />`, because JSX will look for it on `window.Terminal`.

### Rule 3: DO NOT use `scrollIntoView`

`scrollIntoView` will push the entire HTML container upwards, breaking the layout of the web harness. **Never use it**.

Alternative solution:
```js
// Scroll to a certain position within the container
container.scrollTop = targetElement.offsetTop;

// Or use element.scrollTo
container.scrollTo({
  top: targetElement.offsetTop - 100,
  behavior: 'smooth'
});
```

## Calling the Claude API (Within HTML)

Some native design-agent environments (such as Claude.ai Artifacts) provide a zero-config `window.claude.complete`, but most agent environments (Claude Code / Codex / Cursor / Trae / etc.) **do not** have it locally.

If your HTML prototype needs to call an LLM for a demo (such as building a chat interface), you have the following options:

### Option A: Do not make real calls, use a mock

Recommended for demo scenarios. Write a mock helper that returns a predefined response:
```jsx
window.claude = {
  async complete(prompt) {
    await new Promise(r => setTimeout(r, 800)); // Simulate delay
    return "This is a mock response. Replace it with the real API when deploying.";
  }
};
```

### Option B: Make real calls to the Anthropic API

This requires an API key, and users must enter their own key in the HTML to run it. **Never hardcode the key in the HTML**.

```html
<input id="api-key" placeholder="Paste your Anthropic API key" />
<script>
window.claude = {
  async complete(prompt) {
    const key = document.getElementById('api-key').value;
    const res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': key,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5',
        max_tokens: 1024,
        messages: [{ role: 'user', content: prompt }]
      })
    });
    const data = await res.json();
    return data.content[0].text;
  }
};
</script>
```

**Note**: Direct calls to the Anthropic API from the browser will encounter CORS issues. If the preview environment provided by the user does not support CORS bypass, this approach will not work. In that case, use the Option A mock, or inform the user that a proxy backend is required.

### Option C: Use the agent-side LLM capabilities to generate mock data

If this is only for local demonstration, you can temporarily call the current agent's LLM capabilities (or a multi-modal skill installed by the user) within the current agent session to generate mock response data first, and then hardcode it into the HTML. This way, the HTML is completely independent of any API at runtime.

## Typical HTML Starter Template

Copy this template as the skeleton for your React prototype:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Your Prototype Name</title>

  <!-- React + Babel pinned -->
  <script src="https://unpkg.com/react@18.3.1/umd/react.development.js" integrity="sha384-hD6/rw4ppMLGNu3tX5cjIb+uRZ7UkRJ6BPkLpg4hAu/6onKUg4lLsHAs9EBPT82L" crossorigin="anonymous"></script>
  <script src="https://unpkg.com/react-dom@18.3.1/umd/react-dom.development.js" integrity="sha384-u6aeetuaXnQ38mYT8rp6sbXaQe3NL9t+IBXmnYxwkUI2Hw4bsp2Wvmx4yRQF1uAm" crossorigin="anonymous"></script>
  <script src="https://unpkg.com/@babel/standalone@7.29.0/babel.min.js" integrity="sha384-m08KidiNqLdpJqLq95G/LEi8Qvjl/xUYll3QILypMoQ65QorJ9Lvtp2RXYGBFj1y" crossorigin="anonymous"></script>

  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { height: 100%; width: 100%; }
    body { 
      font-family: -apple-system, 'SF Pro Text', sans-serif;
      background: #FAFAFA;
      color: #1A1A1A;
    }
    #root { min-height: 100vh; }
  </style>
</head>
<body>
  <div id="root"></div>

  <!-- Your component files -->
  <script type="text/babel" src="components.jsx"></script>

  <!-- Main entry point -->
  <script type="text/babel">
    const { useState, useEffect } = React;

    function App() {
      return (
        <div style={{padding: 40}}>
          <h1>Hello</h1>
        </div>
      );
    }

    const root = ReactDOM.createRoot(document.getElementById('root'));
    root.render(<App />);
  </script>
</body>
</html>
```

## Common Errors and Troubleshooting

**`styles is not defined` or `Cannot read property 'button' of undefined`**
→ You defined `const styles` in one file, and another file overwrote it. Change each to a specific name.

**`Terminal is not defined`**
→ Scope is not shared across files. Add `Object.assign(window, {Terminal})` at the end of the file where `Terminal` is defined.

**Blank page with no console errors**
→ This is likely due to a JSX syntax error that Babel did not report in the console. Temporarily replace `babel.min.js` with the uncompressed `babel.js` for clearer error messages.

**ReactDOM.createRoot is not a function**
→ Incorrect version. Verify that you are using `react-dom@18.3.1` (instead of `17` or other versions).

**`Objects are not valid as a React child`**
→ You rendered an object instead of JSX/string. This usually happens when `{someObj}` is written instead of `{someObj.name}`.

## How to Split Files in Large Projects

A **single file with >1000 lines** is hard to maintain. Here is a structure for splitting it:

```
Project/
├── index.html
├── src/
│   ├── primitives.jsx      # Basic elements: Button, Card, Badge...
│   ├── components.jsx      # Business components: UserCard, PostList...
│   ├── pages/
│   │   ├── home.jsx        # Home page
│   │   ├── detail.jsx      # Detail page
│   │   └── settings.jsx    # Settings page
│   ├── router.jsx          # Simple routing (React state switching)
│   └── app.jsx             # Entry component
└── data.js                 # mock data
```

Load them in sequence in HTML:
```html
<script type="text/babel" src="src/primitives.jsx"></script>
<script type="text/babel" src="src/components.jsx"></script>
<script type="text/babel" src="src/pages/home.jsx"></script>
<script type="text/babel" src="src/pages/detail.jsx"></script>
<script type="text/babel" src="src/pages/settings.jsx"></script>
<script type="text/babel" src="src/router.jsx"></script>
<script type="text/babel" src="src/app.jsx"></script>
```

**At the end of each file**, use `Object.assign(window, {...})` to export the things that need to be shared.
