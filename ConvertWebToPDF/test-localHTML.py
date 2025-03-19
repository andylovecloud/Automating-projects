from weasyprint import HTML

try:
    html = HTML('./How do I apply or register for the studies_ - HAMK.html')
    html.write_pdf('local_test.pdf')
    print("Local HTML converted to PDF successfully!")
except Exception as e:
    print(f"An error occurred: {e}")
