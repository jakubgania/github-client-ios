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
        link = item.locator("h3 a")
        href = link.get_attribute("href")
        title = item.locator("h3 a").inner_text()
        has_verification = item.locator("h3 svg").count() > 0
        description = item.locator("p").inner_text()

        logo_img = item.locator('[data-testid="logo"] img')
        logo_url = logo_img.get_attribute("src")

        print({
          "href": href,
          "logo": logo_url,
          "title": title.strip(),
          "verified": has_verification,
          "description": description,
        })

      # next_btn = page.locator('a[rel="next"]')
      # if next_btn.count() > 0:
      #     next_btn.click()
      #     page.wait_for_load_state('networkidle')
      # else:
        # propably last page
        

      browser.close()
  except Exception as e:
    return []
  


scrape_marketplace_developers()