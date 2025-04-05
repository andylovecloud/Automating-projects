from weasyprint import HTML

def html_to_pdf(url, output_file):
    try:
        # Check if the URL starts with "http" or "https"
        if not url.startswith(("http://", "https://")):
            print("Invalid URL! Make sure it starts with 'http://' or 'https://'.")
            return

        print("Fetching webpage...")
        html = HTML(url)
        print("Webpage fetched successfully!")

        html.write_pdf(output_file)
        print(f"PDF saved as {output_file}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    webpage_url = input("Enter the URL of the webpage: ")
    output_file = input("Enter the output PDF file name (e.g., output.pdf): ")
    html_to_pdf(webpage_url, output_file)
