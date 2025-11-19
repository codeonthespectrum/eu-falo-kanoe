# I Speak Kanoe

# Kanoê Language Database: Engineering & Migration Scripts

[![Hugging Face Dataset](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-Dataset-yellow)](https://huggingface.co/datasets/carpenterbb/i-speak-kanoe)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue.svg)](https://www.postgresql.org/)
[![Supabase](https://img.shields.io/badge/Supabase-Enabled-green)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](LICENSE)

## 🏛️ About the Project

This repository hosts the **data engineering pipelines, SQL schemas, and migration scripts** developed to construct the **Digital Database of the Kanoê Language** (ISO 639-3: `kxo`).

The primary goal of this project was to rescue and modernize linguistic data from legacy formats (unstructured CSVs, deprecated SQL Server dumps, and PDF reports) into a robust, normalized, and cloud-native relational architecture.

> **⚠️ Looking for the data?**
> The curated dataset, final CSV files, and the official DOI for citation are hosted on our Hugging Face repository:
>
> 👉 **[Access the Dataset on Hugging Face](https://huggingface.co/datasets/carpenterbb/i-speak-kanoe)**

---

## ⚙️ Technical Architecture

The database was designed using **PostgreSQL** (via Supabase) employing a **Hybrid SQL/NoSQL approach** to handle the complexity and sparsity typical of linguistic fieldwork data.

### Key Engineering Decisions

1.  **Normalized Core (SQL):**
    * We adopted a strict relational model for the core entities: `Lemma` (Headword), `Sense` (Meaning), and `Form` (Pronunciation). This ensures referential integrity—you cannot have a translation without a word, nor an example sentence without a bibliographic source.

2.  **Flexible Metadata (NoSQL/JSONB):**
    * To handle irregular data (e.g., specific cultural notes that only appear in 5% of entries), we utilized PostgreSQL's `JSONB` columns. This allowed us to store semi-structured data without creating dozens of sparse columns.

3.  **Full-Text Search:**
    * Implemented native PL/pgSQL functions to allow accent-insensitive and case-insensitive searching across Kanoê terms, Portuguese translations, and cultural notes simultaneously.

---

## 🧠 Lessons Learned & Challenges

Migrating legacy linguistic data is rarely straightforward. Here are the key takeaways from this engineering journey:

### 1. The "Staging Table" Strategy
Attempting to insert 1,500+ raw rows directly into a normalized schema is error-prone.
* **Solution:** We implemented an **ETL (Extract, Transform, Load)** process using a temporary *Staging Table* (`import_csv_unificado`).
* **Benefit:** This allowed us to dump raw CSV data first, clean it via SQL, and then distribute it to the final tables (`palavra`, `significado`, `frase`) using intelligent scripts that check for duplicates and handle upserts.

### 2. Integrity vs. Flexibility
We initially considered a pure NoSQL document database (like MongoDB) due to the emptiness of many fields in the original dataset.
* **Realization:** Linguistic data relies heavily on citations. If a source is deleted, all associated examples must handled safely.
* **Conclusion:** A relational database with Foreign Keys `ON DELETE CASCADE` was safer for data integrity, while `JSONB` columns provided the necessary flexibility for sparse attributes.

### 3. Source of Truth
Managing duplicate bibliographic entries (e.g., "Cartilha Vol II" vs "Cartilha Vol. 2") was a major challenge.
* **Fix:** We established a strict unique constraint on the `filename/reference` column and used normalization scripts to merge duplicate sources before linking them to the lexical entries.

---

## 🛠️ Repository Structure

* 
    * `01_schema.sql`: DDL to create the tables (`palavra`, `significado`, `bibliografia`...).
    * `02_etl_processing.sql`: The logic used to clean and distribute raw CSV data into the schema.
    * `03_views_and_security.sql`: Creates the user-friendly `view_dicionario_completo` and sets up Row Level Security (RLS).
    * `04_functions.sql`: Custom search functions (`buscar_kanoe`).
* 

---

## 🚀 How to Replicate

If you wish to run a local instance of this database:

1.  Clone this repository.
2.  Set up a PostgreSQL instance (Docker or Supabase).
3.  Run the scripts in the `/sql` folder in numerical order.
4.  Import the CSV data (available on Hugging Face) into the staging table.

---

## 👥 Credits

* **[Gabrielly Gomes]:** Data Engineering, SQL Modeling, Curatorship, and Standardization.
* **[Iago Aragão]:** Data Collection, Transcription, and Quality Assurance.

---

## 📄 License

The SQL code in this repository is available under the **MIT License**.
The linguistic data content is available under **Creative Commons Attribution 4.0 (CC-BY 4.0)**.
