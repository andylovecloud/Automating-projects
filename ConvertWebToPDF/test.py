from weasyprint import HTML
HTML('https://www.hamk.fi/en/student-pages/planning-your-studies/study-guidance/').write_pdf('output.pdf')
