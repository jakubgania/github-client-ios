from playwright.sync_api import sync_playwright
import time
import re

def scrape_repositories():
    data = []

    try:
        with sync_playwright() as playwright:
            browser = playwright.webkit.launch(headless=True)

            page = browser.new_page()
            page.goto("https://github.com/trending")

            time.sleep(2)

            elements = page.query_selector_all('article.Box-row')

            for item in elements:
                h2_tag = item.query_selector("h2")
                url = h2_tag.query_selector("a").get_attribute("href")
                title = h2_tag.query_selector("a").inner_text()
                description = item.query_selector("p")

                if description:
                    description = description.inner_text()

                language = item.query_selector('//div[2]/span[1]')
                language_color = language.query_selector('//span[1]')

                language_type = language.query_selector('//span[2]')
                if language_type:
                    language_type = language_type.inner_text()

                language_color_background = ""
                if language_color:
                    language_color_background = page.evaluate(r'''(element) => {
                        const rgb = window.getComputedStyle(element).getPropertyValue("background-color")
                        const [r, g, b] = rgb.match(/\d+/g).map(Number);
                        return "\#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1).toUpperCase();
                    }''', language_color)

                stars = item.query_selector('//div[2]/a[1]').inner_text()
                forks = item.query_selector('//div[2]/a[2]').inner_text()
                
                build_by = item.query_selector('//div[2]/span[2]')
                users = build_by.query_selector_all('a')

                build_by_users = []

                for user in users:
                    user_type = ""
                    avatar = user.query_selector('img')
                    srcClasses = avatar.get_attribute('class')
                    src = avatar.get_attribute("src")

                    if "avatar-user" in srcClasses:
                        user_type = "User"
                    else:
                        user_type = "Organization"

                    build_by_users.append({
                        "type": user_type,
                        "avatar_url": src
                    })

                stars_today = []
                if language_type is None:
                    stars_today = item.query_selector('//div[2]/span[2]').inner_text()
                else:
                    stars_today = item.query_selector('//div[2]/span[3]').inner_text()
                match = re.search(r'(\d+)', stars_today)
                stars_today = match.group(1)

                data.append({
                    "title": title.lstrip(),
                    "url": "https://github.com" + url,
                    "description": description,
                    "language": language_type,
                    "language_color": language_color_background,
                    "stars": stars.lstrip(),
                    "forks": forks.lstrip(),
                    "build_by": build_by_users,
                    "stars_today": stars_today
                })

            browser.close()

            print(data)
            
            return data
    except Exception as e:
        print(f"An unexpected error occured: {e}")
        return []
    
scrape_repositories()