from playwright.sync_api import sync_playwright
import time

def scrape_developers():
  data = []

  try:
    with sync_playwright() as playwright:
      browser = playwright.webkit.launch(headless=True)
      
      page = browser.new_page()
      page.goto("https://github.com/trending/developers")
      
      time.sleep(2)

      elements = page.query_selector_all('article.Box-row')

      for item in elements:
        avatar = item.query_selector('//div[1]/a/img')
        avatar_src = avatar.get_attribute('src')

        name = item.query_selector('//div[2]/div/div/h1/a').inner_text()
        url = item.query_selector('//div[2]/div/div/h1/a').get_attribute("href")

        login = item.query_selector('//div[2]/div/div/p')

        if login:
          login = login.inner_text()

        repo_url = item.query_selector('//div[2]/div/div[2]/div/article/h1/a')

        if repo_url:
            repo_url = "https://github.com" + repo_url.get_attribute('href')

        repository = item.query_selector('//div[2]/div/div[2]/div/article/h1/a')

        if repository:
            repository = repository.inner_text()

        description = item.query_selector('//div[2]/div/div[2]/div/article/div[2]')

        if description:
            description = description.inner_text()
        
        dev_at_company = item.query_selector('//div[2]/div/div[2]/div/p/span[2]')
            
        if dev_at_company:
            dev_at_company = dev_at_company.inner_text()

        data.append({
           "avatar_url": avatar_src,
            "name": name,
            "login": login,
            "html_url": "https://github.com" + url,
            "dev_at_company": dev_at_company,
            "popular_repo": {
                "title": repository,
                "repo_url": repo_url,
                "description": description
            }
          })
        
      browser.close()

      print(data)
      return data
  except Exception as e:
    print(f"An unexcepted error occured: {e}")
    return []
  
scrape_developers()