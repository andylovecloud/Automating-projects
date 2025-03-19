import os
import requests
from bs4 import BeautifulSoup
from weasyprint import HTML
from urllib.parse import urljoin, urlparse

def get_all_links(base_url):
    visited = set()
    to_visit = [base_url]

    while to_visit:
        current_url = to_visit.pop(0)

        if current_url in visited:
            continue

        try:
            response = requests.get(current_url)
            response.raise_for_status()
        except (requests.exceptions.RequestException, requests.exceptions.HTTPError):
            print(f"Failed to access {current_url}")
            continue

        visited.add(current_url)
        soup = BeautifulSoup(response.text, 'html.parser')

        for link in soup.find_all('a', href=True):
            full_url = urljoin(base_url, link['href'])

            # Filter only internal links (same domain)
            if base_url in full_url and full_url not in visited:
                parsed_base = urlparse(base_url)
                parsed_link = urlparse(full_url)

                # Ensure the same domain and skip query parameters/anchors
                if parsed_base.netloc == parsed_link.netloc and "?" not in full_url and "#" not in full_url:
                    to_visit.append(full_url)

    return list(visited)

def save_as_pdf(url, output_folder):
    try:
        file_name = urlparse(url).path.strip('/').replace('/', '_') or 'index'
        output_file = os.path.join(output_folder, f"{file_name}.pdf")
        HTML(url).write_pdf(output_file)
        print(f"Saved {url} as {output_file}")
    except Exception as e:
        print(f"Failed to convert {url} to PDF: {e}")

def main():
    base_url = input("Enter the base URL of the website (e.g., https://example.com): ").strip()
    output_folder = input("Enter the output folder to save PDFs: ").strip()

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    print("Crawling website and fetching links...")
    all_links = get_all_links(base_url)

    print(f"Found {len(all_links)} pages. Converting to PDF...")
    for link in all_links:
        save_as_pdf(link, output_folder)

    print("All pages have been converted to PDFs!")

if __name__ == "__main__":
    main()
