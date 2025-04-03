# PsycheMD

**An GenAI-SymAI Hybrid Expert System for Mental Disorder Self-diagnosis**

PsycheMD is an experimental expert system that combines the strengths of Generative AI (GenAI) and Symbolic AI (SymAI) to assist with the self-diagnosis of mental disorders. It leverages Prolog for logical reasoning and Node.js for integration, aiming to provide insightful preliminary assessments.

> **Disclaimer:** This project is intended for educational and informational purposes only. It is not a substitute for professional medical advice or diagnosis. Always consult a qualified healthcare professional for any mental health concerns.

## Features

- **Hybrid AI Approach:** Integrates both GenAI and SymAI methodologies.
- **Expert System Logic:** Implements a Prolog-based reasoning engine.
- **Modern Integration:** Uses JavaScript (Node.js) to manage interactions and system workflow.
- **Visual Workflow:** Includes a flowchart (`flowchart.png`) that outlines the system architecture and process.

## Architecture

The project is structured around two main components:

- **Prolog Module:** 
  - Contains the core logic and knowledge base (located in the `prolog` folder).
- **JavaScript Integration:**
  - Acts as the bridge between the user interface and the Prolog engine (see `index.mjs`).
- **Visualization:**
  - A flowchart image (`flowchart.png`) illustrates the overall system design.

## Installation

To set up PsycheMD on your local machine:

1. **Clone the Repository:**
    ```bash
    git clone https://github.com/SorenEricMent/PsycheMD.git
    cd PsycheMD
    ```

2. **Install Dependencies:**
    Ensure you have [Node.js](https://nodejs.org/) installed, then run:
    ```bash
    npm install
    ```

3. **Configuration:**
    If required, adjust any configuration settings or environment variables as needed (details can be added as the project evolves). Currently you need to set your OPENAI_API_ENV

## Usage

To run the system:

```bash
node index.mjs
