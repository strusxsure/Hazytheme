const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  // Create a mock wrapper for verification
  const htmlContent = `
    <!DOCTYPE html>
    <html>
      <head>
        <title>HazyTheme Verification</title>
        <style>
          :root { --hazy-primary: #a78bfa; --hazy-bg: #0f172a; --hazy-text: #f8fafc; }
          body { background: var(--hazy-bg); color: var(--hazy-text); font-family: sans-serif; }
          .glass-heavy { background: rgba(15, 23, 42, 0.7); backdrop-filter: blur(16px); border-right: 1px solid rgba(255,255,255,0.1); }
          .hazy-sidebar { width: 260px; height: 100vh; position: fixed; left: 0; top: 0; }
          .hazy-navbar { height: 64px; border-bottom: 1px solid rgba(255,255,255,0.1); margin-left: 260px; display: flex; align-items: center; padding: 0 24px; }
          .hazy-orb { position: fixed; width: 300px; height: 300px; border-radius: 50%; filter: blur(80px); opacity: 0.4; z-index: -1; }
          .primary-btn { background: var(--hazy-primary); padding: 10px 20px; border-radius: 12px; color: white; border: none; font-weight: bold; }
        </style>
      </head>
      <body>
        <div class="hazy-orb" style="background: var(--hazy-primary); top: -50px; right: -50px;"></div>
        <div class="hazy-sidebar glass-heavy">
          <div style="padding: 24px; font-weight: bold; font-size: 20px; color: var(--hazy-primary);">HazyTheme</div>
        </div>
        <div class="hazy-navbar">
          <div style="color: #94a3b8;">Home / Dashboard</div>
        </div>
        <div style="margin-left: 284px; padding: 40px;">
          <h1>Dashboard</h1>
          <button class="primary-btn">Test Button</button>
        </div>
      </body>
    </html>
  `;

  await page.setContent(htmlContent);
  await page.screenshot({ path: 'hazy_preview.png' });
  console.log('HazyTheme preview screenshot saved to hazy_preview.png');

  await browser.close();
})();
