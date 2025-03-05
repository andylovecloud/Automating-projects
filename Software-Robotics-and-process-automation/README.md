# Objectives

This folder introduces software robotics (RPA) and process automation by practising RPA development using two different techniques: 
1. **UiPath**:  which is one of the leading RPA applications in the market.
2. **Robot Framework**: used in validating, testing and reporting. 

## Main objectives 

- Understand the applications and requirements of software robotics.
- Apply different techniques to to various use cases.
- Build automated solutions considering business needs.


## Project description

The company receives purchase invoices from various suppliers, which must be verified for accuracy and approved by a staff member to confirm who generated the invoice and ensure its validity. Invoices may arrive either electronically or in paper format. While the company already has an automation system for managing electronic invoices, handling paper invoices remains a challenge. Currently, paper invoices are scanned into PDF files and stored in a designated directory for processing.

This project aims to automate the handling of PDF invoices. The objective is to read the invoices from the directory into a MySQL database while verifying the correctness of the IBAN and reference numbers. Additionally, the system will ensure that the line item amounts match the total amount specified in the header information.

This task will be executed using two RPA techniques. The UiPath process will extract data from the PDF files into a temporary CSV structure, standardizing the necessary information from various invoices. The Robot Framework process will handle the data in the CSV file, validate it, and write the invoice details into the MySQL database.

The database must include a "Status" column for the invoices, indicating whether errors are present, and a "Comments" column to document any findings. This completes the scope of this project. However, it is important to note that another internal process within the company will subsequently retrieve invoices from the MySQL database and forward them for the necessary approvals.


![Process DiagramV1-HighLevel](https://github.com/user-attachments/assets/3bc5eb37-2bd1-4d16-b19c-66175956e13b)


## Project Execution
## 1. Project diagram
To understand the project purposes, I have to analyze and draw the diagrams from data flow, process steps, validation and reporting.

Diagrams are often required in the workplace to facilitate discussions about the different stages of a process and to ensure that all stakeholders have a shared understanding and are discussing the same stages.

The detail of diagrams for this project can find at **[Project diagrams](oftware-Robotics-and-process-automation/RPA-Project-Process-Diagram.drawio-Andy.pdf)**

## 2. UiPath

![uiPath](https://github.com/user-attachments/assets/18511319-8c7b-4ba4-ba75-0ebcebc0c509)


Next step, I learnt and used UiPath Studio to complete the initial implementation step of the project. The robot should follow the process I have designed, which cover below steps:

1. Read all PDF files from the specified directory.
2. Process all files invoice by invoice (there may be more invoices than initially provided).
3. Determine the company (company code) from which each invoice originates.
4. Extract the necessary data from the invoices into variables (data extraction methods may vary by vendor).
5. Add the data from the variables to a DataTable.
6. Once all invoices are processed, write the DataTable data to CSV files.
7. Move the original invoice PDFs to the "processed" directory so they are ready for the next run.

The project flow detail you can find at [**Process-UiPath folder**](Software-Robotics-and-process-automation/Process-UiPath)

## 3. Robot Framework

![robot-framework-log](https://github.com/user-attachments/assets/d479223b-bd51-4c1d-9a50-ae88204be1a9)


The second phase of the project I used Robot Framework and train the robot to follow the process I have designed as below:

1. Create the target database (MySQL).
2. Create a user and assign appropriate permissions.
3. Read the CSV files for processing with Robot Framework.
4. Process the invoices one at a time.
5. Verify the accuracy of the data.
6. Write the invoice details into your created database.
7. Include a **Status** field indicating whether the invoice is error-free and document any issues found with the invoice

The flow of Robot Framework you can find at [**Robot Framework folder**](Software-Robotics-and-process-automation/Robot-Framework)

