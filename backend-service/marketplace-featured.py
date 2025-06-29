from playwright.sync_api import sync_playwright
import time

def scrape_marketplace_developers():
  data = []

  try:
    with sync_playwright() as playwright:
      browser = playwright.webkit.launch(headless=True)

      page = browser.new_page()
      page.goto("https://github.com/marketplace")

      time.sleep(2)

      elements = page.locator('[class*="marketplace-featured-grid"]')
      print(elements.count())

      count = elements.count()
      
      for i in range(count):
        item = elements.nth(i)

        titles = item.locator("h3 a")
        title_count = titles.count()

        for j in range(title_count):
            title = titles.nth(j).inner_text()
            print(f"Title: {title}")
            data.append(title)

  except Exception as e:
    return []
  
scrape_marketplace_developers()