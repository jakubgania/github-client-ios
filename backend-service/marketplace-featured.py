from playwright.sync_api import sync_playwright
import time
import pprint

def scrape_marketplace_developers():
  data = []

  try:
    with sync_playwright() as playwright:
      browser = playwright.webkit.launch(headless=False)

      page = browser.new_page()
      page.goto("https://github.com/marketplace")
      page.wait_for_selector('[class*="marketplace-featured-grid"]')

      elements = page.locator('[class*="marketplace-featured-grid"]')
      print(elements.count())

      count = elements.count()

      for i in range(count):
          item = elements.nth(i)

          items = item.locator('> div')
          count = items.count()
          for i in range(count):
            item = items.nth(i)

            # Title
            title = item.locator("h3 a").inner_text()
            print(title)

            # Link (full)
            href = item.locator("h3 a").get_attribute("href")
            link = f"https://github.com{href}" if href.startswith("/") else href
            print(link)

            # Logo (img src)
            logo = item.locator("img").get_attribute("src")
            logo_url = f"https://github.com{logo}" if logo.startswith("/") else logo
            print(logo_url)

            provider = ""
            description = ""

            ps = item.locator("p")
            if ps.count() == 1:
              description = ps.nth(0).inner_text().strip()
            elif ps.count() >= 2:
              provider = ps.nth(0).inner_text().replace("by", "").strip()
              description = ps.nth(1).inner_text().strip()

            data.append({
              "title": title,
              "provider": provider,
              "description": description,
              "link": link,
              "logo": logo_url
            })

      elements2 = page.locator('[data-testid="marketplace-item"]')
      print(elements2.count())
      count2 = elements2.count()

      for i in range(count2):
        item = elements2.nth(i)

        title = item.locator("h3 a").inner_text()
        link = item.locator("h3 a").get_attribute("href")
        full_link = f"https://github.com{link}" if link else ""
        description = item.locator("p").inner_text()
        image = item.locator("img").get_attribute("src")

        print({
            "title": title.strip(),
            "description": description.strip(),
            "link": full_link,
            "thumbnail": image,
        })

      page.locator('button span[data-content="Recently added"]').click()

      elements3 = page.locator('[data-testid="non-featured-item"]')
      print(elements3.count())
      count3 = elements3.count()

      for i in range(count3):
        item = elements3.nth(i)
        # print(item)

        title = item.locator("h3 a").inner_text()
        # link = item.locator("h3 a").get_attribute("href")
        # full_link = f"https://github.com{link}" if link else ""
        # description = item.locator("p").inner_text()
        # image = item.locator("img").get_attribute("src")

        print({
            "title": title.strip(),
        })

      # return data

  except Exception as e:
    return []
  
data = scrape_marketplace_developers()

# for item in data:
#     print(item)
#     print("---------")