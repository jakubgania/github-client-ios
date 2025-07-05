# from playwright.sync_api import sync_playwright

# def scrape_marketplace_developers():
#   data = []

#   try:
#     with sync_playwright() as playwright:
#       browser = playwright.webkit.launch(headless=True)

#       page = browser.new_page()
#       page.goto("link link")
#       page.wait_for_selector('[data-testid="marketplace-item"]')
      
#       copilotExtensions page.locator('[data-testid="marketplace-item"]')

from playwright.async_api import async_playwright
import asyncio
import json

async def scrape_news():
    async with async_playwright() as playwright:
        print("script start")
        data = []
        browser = await playwright.webkit.launch(headless=False)

        page = await browser.new_page()
        await page.goto("https://www.purepc.pl")
        # data = await page.content()
        # await page.wait_for_selector("section.ln_item header h3 a")
        await page.wait_for_selector("section.ln_item")
        sections = page.locator("section.ln_item")
        count = await sections.count()
        for i in range(count):
            sec = sections.nth(i)
            link = sec.locator("header h3 a")
            title = await link.inner_text()
            print(f"{i+1}. {title.strip()}")
            data.append({
              "title": title
            })
            # print("- - - - - - - - -")
        await browser.close()
        print("script close")
        # print(titles)

        with open("app/storage/news.json", "w") as f:
            f.write(
                json.dumps(data, indent=2, ensure_ascii=False)
            )

        # with open("app/storage/news.json", "w") as f:
        #     f.write(data)

asyncio.run(scrape_news())