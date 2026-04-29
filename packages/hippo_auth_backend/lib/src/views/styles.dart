part of 'views.dart';

String _pageCss(HippoAuthBackendBranding branding) {
  return '''
:root {
  color-scheme: light;
  --primary: ${branding.primaryColor};
  --bg: ${branding.backgroundColor};
  --surface: ${branding.surfaceColor};
  --text: ${branding.textColor};
  --muted: ${branding.mutedTextColor};
  --border: #d8dee8;
  --success: #047857;
  --error: #b91c1c;
}
* {
  box-sizing: border-box;
}
html, body {
  min-height: 100%;
  margin: 0;
}
body {
  display: grid;
  place-items: center;
  padding: 24px;
  background: var(--bg);
  color: var(--text);
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  line-height: 1.5;
}
.card {
  width: min(100%, 440px);
  padding: 32px;
  border: 1px solid var(--border);
  border-radius: 8px;
  background: var(--surface);
  box-shadow: 0 16px 38px rgba(17, 24, 39, 0.08);
}
header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
}
.logo {
  width: 44px;
  height: 44px;
  border-radius: 8px;
  object-fit: contain;
}
.brand {
  margin: 0;
  color: var(--muted);
  font-size: 0.95rem;
  font-weight: 600;
}
h1 {
  margin: 0;
  font-size: 1.7rem;
  line-height: 1.2;
  letter-spacing: 0;
}
.subtitle {
  margin: 10px 0 22px;
  color: var(--muted);
}
form {
  display: grid;
  gap: 16px;
  margin: 0 0 18px;
}
form[hidden] {
  display: none;
}
.field {
  display: grid;
  gap: 7px;
}
label {
  font-size: 0.92rem;
  font-weight: 650;
}
input {
  width: 100%;
  min-height: 44px;
  padding: 10px 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  background: #fff;
  color: var(--text);
  font: inherit;
}
input:disabled {
  color: var(--muted);
  background: #f5f7fb;
}
.password-wrapper {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: center;
  gap: 8px;
}
.toggle {
  min-width: 56px;
  min-height: 44px;
  border: 1px solid var(--border);
  border-radius: 8px;
  background: #fff;
  color: var(--text);
  font: inherit;
  font-weight: 650;
}
button[type="submit"] {
  min-height: 46px;
  border: 0;
  border-radius: 8px;
  background: var(--primary);
  color: white;
  font: inherit;
  font-weight: 700;
  cursor: pointer;
}
button:disabled {
  cursor: wait;
  opacity: 0.68;
}
.message {
  min-height: 24px;
  margin: 14px 0 0;
  font-weight: 600;
}
.hint {
  color: var(--muted);
}
.success {
  color: var(--success);
}
.error {
  color: var(--error);
}
.spinner {
  display: inline-block;
  width: 16px;
  height: 16px;
  margin-right: 8px;
  border: 2px solid var(--border);
  border-top-color: var(--primary);
  border-radius: 999px;
  vertical-align: -3px;
  animation: hippo-spin 900ms linear infinite;
}
footer {
  margin-top: 26px;
  color: var(--muted);
  font-size: 0.85rem;
}
footer p {
  margin: 8px 0 0;
}
nav {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 10px;
}
a {
  color: var(--primary);
  text-decoration: none;
  font-weight: 650;
}
@keyframes hippo-spin {
  to {
    transform: rotate(360deg);
  }
}
@media (max-width: 480px) {
  body {
    padding: 12px;
  }
  .card {
    padding: 22px;
  }
  .password-wrapper {
    grid-template-columns: 1fr;
  }
  .toggle {
    width: 100%;
  }
}
''';
}
