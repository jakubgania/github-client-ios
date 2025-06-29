from playwright.sync_api import sync_playwright
import time
import pprint

def scrape_marketplace_developers():
  data = []

  try:
    with sync_playwright() as playwright:
      browser = playwright.webkit.launch(headless=True)

      page = browser.new_page()
      page.goto("https://github.com/marketplace")

      time.sleep(2)

      elements = page.locator('[class*="marketplace-featured-grid"]')
      # print(elements.count())

      items = page.locator('[class*="marketplace-featured-grid"] > div')
      count = items.count()

      for i in range(count):
          item = items.nth(i)

          # Title
          title = item.locator("h3 a").inner_text()

          # Link (full)
          href = item.locator("h3 a").get_attribute("href")
          link = f"https://github.com{href}" if href.startswith("/") else href

          # Provider
          provider = item.locator("p").nth(0).inner_text().replace("by ", "").strip()

          # Description
          description = item.locator("p").nth(1).inner_text().strip()

          # Logo (img src)
          logo = item.locator("img").get_attribute("src")
          logo_url = f"https://github.com{logo}" if logo.startswith("/") else logo

          model_info = {
              "title": title,
              "provider": provider,
              "description": description,
              "link": link,
              "logo": logo_url
          }

          print(model_info)
          print("-----")
          data.append(model_info)

      return data

  except Exception as e:
    return []
  
scrape_marketplace_developers()