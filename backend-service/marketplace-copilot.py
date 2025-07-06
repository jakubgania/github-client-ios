from playwright.sync_api import sync_playwright

def scrape_marketplace_developers():
  data = []

  try:
    with sync_playwright() as playwright:
      browser = playwright.webkit.launch(headless=False)

      page = browser.new_page()
      page.goto("https://github.com/marketplace?type=apps&copilot_app=true")
      page.wait_for_selector('[data-testid="marketplace-item"]')
      
      copilotExtensions = page.locator('[data-testid="marketplace-item"]')
      count = copilotExtensions.count()

      for i in range(count):
        item = copilotExtensions.nth(i)
        title = item.locator("h3 a").inner_text()
        print({
            "title": title.strip(),
        })

      browser.close()
  except Exception as e:
    return []
  


scrape_marketplace_developers()