import fpdf
from fpdf import FPDF


def all_symptoms():
    all=[]
    while True:
        symptom = translate_english(input("enter symptoms(or type 'done' to finish): ").strip())
        if symptom.lower()== 'done':
            break
        x=ask_severity_questions(symptom)
        final_sym={}
        final_sym["Symptom"]=symptom
        final_sym["severity"]=x['severity']
        final_sym["frequency"]=x['frequency']
        final_sym["duration"]=x['duration']
        final_sym["ongoing medications"]=x['ongoing medications']
        final_sym["family history"]=x['family history']
        all+=[final_sym]
    return all


def generate_report(patient_details, patient_data, filename="patient_report_text_to_text.pdf"):
    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()

    # Set up title
    pdf.set_font("Arial", style='B', size=18)
    pdf.cell(200, 10, "PATIENT SCREENING REPORT", ln=True, align='C')
    pdf.ln(10)  

    # Patient Details Section
    pdf.set_font("Arial", style='B', size=14)
    pdf.cell(200, 10, "Patient Details", ln=True, border='B')
    pdf.set_font("Arial", size=12)
    pdf.ln(5)  

    # Create a table for patient details
    col_width = 95  
    row_height = 10 
    for key, value in patient_details.items():
        pdf.cell(col_width, row_height, key, border=1)
        pdf.cell(col_width, row_height, str(value), border=1, ln=True)
    pdf.ln(10)  

    # Symptoms Summary Section
    pdf.set_font("Arial", style='B', size=14)
    pdf.cell(200, 10, "Symptoms Summary", ln=True, border='B')
    pdf.set_font("Arial", size=12)
    pdf.ln(5) 

    # Define column widths for the symptoms table
    col_widths = [23, 30, 25, 34, 43, 35]  
    headers = ["Symptom", "Frequency", "Severity", "Duration","Ongoing medications","Family history"]
    row_height = 10

    # Add table headers
    for i, header in enumerate(headers):
        pdf.cell(col_widths[i], row_height, header, border=1, align='C')
    pdf.ln(row_height)

    # Add symptom data rows
    for entry in patient_data:
        print(entry)
        pdf.cell(col_widths[0], row_height, entry["Symptom"], border=1)
        pdf.cell(col_widths[1], row_height, entry["frequency"], border=1)
        pdf.cell(col_widths[2], row_height, entry["severity"], border=1)
        pdf.cell(col_widths[3], row_height, entry["duration"], border=1)
        pdf.cell(col_widths[4], row_height, entry["ongoing medications"], border=1)
        pdf.cell(col_widths[5], row_height, entry["family history"], border=1,ln=True)

    # Save the PDF
    pdf.output(filename)
    print(f"Patient report successfully saved as {filename}.")


def summary(func):
    patient_details=patient_demographics()
    symptoms_summary=all_symptoms()
    generate_report(patient_details,symptoms_summary,"patient_report_text_to_text.pdf")

if __name__ == '__main__':
    summary()