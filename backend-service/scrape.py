from repositories import scrape_repositories
from developers import scrape_developers
from topics import scrape_topics

import asyncio
import json
import os

def run():
  trending_repositories = scrape_repositories()
  trending_developers = scrape_developers()

  save_dir = ""

  with open(os.path.join(save_dir, "repositories.json"), "w") as f:
    f.write(
      json.dumps(trending_repositories, indent=2)
    )

  with open(os.path.join(save_dir, "developers.json"), "w") as f:
    f.write(
      json.dumps(trending_developers, indent=2)
    )

# run()

async def run_async():
    topics = await scrape_topics()

    save_dir = ""

    # with open(os.path.join(save_dir, "topics.json"), "w") as f:
    with open("topics.json", "w") as f:
        f.write(
            json.dumps(topics, indent=2)
        )

asyncio.run(run_async())