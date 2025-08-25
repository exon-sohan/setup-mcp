# Salesforce MCP Server for Claude Desktop

## Prerequisites

Before you begin, ensure you have the following software installed on your system:

1.  **[Git](https://git-scm.com/downloads)**: For cloning the project repository.
2.  **[Node.js](https://nodejs.org/)**: (LTS version is recommended) To run the server.
3.  **[Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli)**: To execute commands against your orgs. Make sure you are already authenticated to your target orgs (`sf org login web`).
4.  **[Claude Desktop](https://claude.ai/download)** Download the mcp client which will interacting with the sf mcp on behalf of you.

---

## 🚀 Quick Start: Automated Setup

This is the recommended method for all users. The setup script handles everything from downloading the code to configuring Claude Desktop automatically.

### For macOS / Linux Users

1.  Download the `setup-mac.sh` script.
2.  Open your **Terminal** application.
3.  Navigate to the directory where you downloaded the script (e.g., `cd ~/Downloads`).
4.  Run the script with the following command:

    ```bash
    sudo chmod +x setup-mac.sh
    ```

    ```bash
    bash setup-mac.sh
    ```

### For Windows Users

1.  Download the `setup-windows.ps1` script.
2.  Right-click on the script file.
3.  Select **"Run with PowerShell"**.
    - Note: If you encounter an error about execution policies, you may need to open PowerShell as an Administrator and run
    ```bash
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
    ```
    then try again.

## How to Update

To get the latest tools and features, simply **re-run the same setup script** you used for the initial installation. It will automatically pull the latest changes and rebuild the project for you.

## Some Examples

create a object naming Person
it will have few fields naming
Name,age,Id and there will another object Department and where there will be two fields PersonId and Department name and the PersonId should be a foreign key of Id of Person in exonuat org

make a salesforce custom object naming 'property' and the fields will be have named as Property ID – Unique identifier for the listing. Title/Headline – Brief description (e.g., "3BHK Luxury Apartment in Downtown"). Property Type – Apartment, Villa, Plot, Commercial, etc. Status – For Sale, For Rent, Under Construction, Sold, etc. Location – Address, City, State, Zip Code, Landmark. Neighborhood/Society Name – If part of a gated community or complex. Price – Listed price (may include currency). Price per Sq. Ft. – Helps compare property value. do this in exonuat org

make a apex class which will insert 10 example records to the object 'Property\_\_c’ in exonuat org

there is a aura named Customer_WrapperComponent retrieve this class from bcsit and bcuat and make a report what is difference in the code between both the codes if you dont get the exact apex class name then search in manifest file and get the closely related class
