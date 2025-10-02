# Design Document

By Nirupam Mandal

Video overview: <URL HERE>


## Scope

- **Why this database exists**
  - The goal is to build one system that can handle the daily work of a clinic, pharmacy, and lab.  
  - In many places, these systems are split up: one for appointments, another for prescriptions, another for stock.  
  - This design combines all of that into one database so doctors, staff, and patients can all be connected.

- **What’s included**
  - **People**: patients, doctors, staff, and pharmacy buyers.  
  - **Organizations**: clinics, pharmacies, labs, distributors, and companies that make products.  
  - **Workflows**: booking appointments, writing prescriptions, selling and buying medicines, ordering tests, recording results, and tracking staff attendance.  
  - **Extra details**: licences, government IDs, certificates, and bank details.  
  - **Records**: purchases, sales, stock changes, and logs.

- **What’s not included**
  - Insurance or claim systems.  
  - Full accounting like profits, losses, or taxes beyond simple rates.  
  - Hospital in-patient care such as admissions, surgeries, or wards.  
  - Hardware connections like lab machines or biometric scanners.  
  - Video calls, payments, or other telemedicine features.

---

## Functional Requirements

- **Doctors**
  - Add their available time slots for patients.  
  - Make sure no two slots overlap.  
  - Write prescriptions with medicines and tests.  
  - Add reports for tests once results are ready.  

- **Patients**
  - Register in the system.  
  - Book appointments with doctors.  
  - Receive prescriptions.  
  - Buy medicines either with a prescription or over the counter.  
  - Get lab tests done when prescribed.  

- **Staff**
  - Apply for jobs through their user profile.  
  - Work at different entities (clinic, pharmacy, lab).  
  - Check in for attendance.  
  - Have all changes to their records stored in logs for safety.  

- **Pharmacy**
  - Record purchases from suppliers.  
  - Keep details of purchases in headers and line items.  
  - Record sales to patients (linked to prescriptions) or to walk-in buyers.  
  - Keep stock up to date with ledgers and adjustments.  
  - Stop sales if stock is not enough.  

- **Lab**
  - Store a list of available tests.  
  - Record when doctors prescribe a test.  
  - Track the test process from “ordered” to “done.”  
  - Save reports once doctors review them.  

- **Outside the scope**
  - Handling money directly (like payments).  
  - Complicated HR features such as performance reviews.  
  - Big medical research or advanced genetic testing.  

---

## Representation

### Entities
- **Entities**
  - Stores all types of organizations: clinics, pharmacies, labs, distributors, companies.  
  - Each one has a type (`kind`) and details like ownership, address, and licence.  

- **Kinds**
  - Tells what type of entity something is, like “Clinic” or “Pharmacy.”  

- **User details**
  - Stores information about people: name, gender, DOB, phone, etc.  
  - Connected to:
    - `authenticate_users` for logins.  
    - `gov_documents` for IDs.  
    - `education_certificates` for qualifications.  
    - `bank_details` for payment info.  

- **Staff**
  - Links users to entities where they work.  
  - Has role, salary, status, and join date.  
  - Only allows valid roles with a `CHECK`.  

- **Doctors**
  - Special type of user with medical details.  
  - Has specialization, registration number, and consultation fee.  
  - Linked to time slots and appointments.  

- **Patients**
  - Users who register for clinic services.  

- **Products**
  - Medicines and other pharmacy items.  
  - Linked to their active ingredients (compositions).  
  - Appear in prescriptions, sales, purchases, and stock tables.  

- **Tests**
  - Medical investigations (blood test, X-ray, etc.).  
  - Linked to prescribed tests and test records.  

- **Operational tables**
  - **Appointments**: connect patients, doctors, and time slots.  
  - **Prescriptions**: connect doctors and patients, list products and tests.  
  - **Purchases**: bring in products through purchase headers and lines.  
  - **Sales**: products go out, linked to prescriptions or OTC buyers.  
  - **Inventory ledger/adjustments**: record stock changes over time.  

- **Data Types and Constraints** :
  - `INTEGER`  
    - Used for IDs and numeric values such as salary, price, quantity, and tax rate.  
    - Also used for **time values** (like doctor time slots or attendance times) as this makes it easier to compare, sort, and calculate durations.  
  - `TEXT`  
    - Used for names, notes, and other descriptive fields.  
    - Also used for **dates** (like birth dates, appointment dates, and join dates).
  - `CHECK` rules  
    - Enforce controlled values for fields such as gender, staff role, or entity status.  
  - `UNIQUE` rules  
    - Prevent duplicate values in critical places, like licence numbers or doctor + time slot combinations.    
  - **Triggers**  
    - Maintain correctness by automating business rules. 
    - For example, they stop overlapping doctor slots, prevent sales without enough stock, and automatically update the inventory ledger.

### Relationships

![ER Diagram](images\clinic-er-diagram.png)

### Key relationships:

- **Entities ↔ Kinds**  
  - One kind (like “Pharmacy”) can have many entities.  

- **Licences**  
  - Entities can store many licences for legal use.  

- **Users ↔ Roles**  
  - One user can be a patient, staff member, or doctor.  

- **Staff**  
  - Work at entities.  
  - Have attendance records.  
  - All changes get logged for tracking.  

- **Doctors**  
  - Have time slots.  
  - Patients book appointments in those slots.  
  - Doctors issue prescriptions to patients.  

- **Prescriptions**  
  - Can list both medicines and tests.  
  - Medicines connect to stock and sales.  
  - Tests connect to labs and test records.  

- **Pharmacy**  
  - Buys products from suppliers.  
  - Sells products to patients.  
  - Stock auto-updates through triggers.  

- **Labs**  
  - Handle prescribed tests.  
  - Test records connect back to doctors, patients, and labs.  

---

## Optimizations

- **Indexes**
  - Speed up joins on foreign keys.  
  - Stop duplicate time slots with `(doctor_id, slot)`.  
  - Speed up queries on purchases and sales with composite indexes.  

- **Views**
  - `view_doctor_schedule`: shows doctor's weakly schedule.
  - `view_upcoming_appointments`: quick list of all future appointments.
  - `view_patient_prescription_history`: shows every prescription a patient got.
  - `view_stock_by_batch`: shows current inventory.
  - `view_low_stock`: flags items running out.
  - `view_expiring_batches_30d`: warns about expiring products.
  - `view_lab_test_status`: lists all tests and their progress.
  - `view_staff_checked_in_today`: quick view of staff attendance.  

- **Triggers**
  - Auto-log staff changes (insert, update, delete).  
  - Block overlapping doctor slots.  
  - Update inventory automatically when purchases, sales, or adjustments happen.  
  - Stop sales if there is not enough stock.  

---

## Limitations

- **Finance**
  - Only records prices, discounts, and taxes.  
  - No full accounting or multi-currency support.  

- **Roles**
  - Fixed list of roles with a `CHECK`.  
  - No complex job hierarchies.  

- **Billing**
  - Only pharmacy sales tracked.  
  - No hospital billing or insurance integration.  

- **Labs**
  - Only single tests supported.  
  - No grouped panels or advanced result formats.  
  - No lab machine connections.  
  
---
