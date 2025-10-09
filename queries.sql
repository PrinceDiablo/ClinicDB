-- =========================================================
-- A SCENARIO: FUSSY CUSTOMER
-- =========================================================

-- A flying customer walks into the pharmacy and buys some OTC medicines.

-- Step 1: Add this customer to "user_details" and "authenticate_users"
INSERT INTO "user_details" ("name", "dob", "gender", "temp_address", "primary_contact_no")
VALUES ('Flying Customer', '1990-01-01', 'Other', 'Local Walk-in', '+91-9090909090');

INSERT INTO "authenticate_users" ("user_id", "email", "password_hash")
VALUES ((SELECT "id" FROM "user_details" WHERE "primary_contact_no" = '9090909090'),
        'j.customer@demo.local', '$2a$10$abcdefghijklmnopqrstuu11');

-- Step 2: Record a new sale made by Worker B (pharmacist) to the flying customer.
-- Example: Vitamin Tablets (₹250) and Cough Syrup (₹200)
INSERT INTO "sales" ("product_id", "pharmacy_id", "buyer_user_id", "sold_by", "quantity", "rate", "sold_at")
VALUES
  (5, 2, (SELECT "id" FROM "user_details" WHERE "primary_contact_no" = '9090909090'),
   (SELECT "id" FROM "user_details" WHERE "name" = 'Worker B'), 2, 250, CURRENT_TIMESTAMP),
  (27, 2, (SELECT "id" FROM "user_details" WHERE "primary_contact_no" = '9090909090'),
   (SELECT "id" FROM "user_details" WHERE "name" = 'Worker B'), 1, 200, CURRENT_TIMESTAMP);

-- Step 3: View the total cost
SELECT SUM("rate") AS "total_price"
  FROM "sales"
 WHERE "primary_contact_no" = '9090909090'
   AND strftime('%d', "sold_at") = strftime('%d', 'now');

-- The customer says they can only pay ₹500 total.
-- Reduce quantity of one product (Vitamin Tablets 2 -> 1) and remove one other item (Cough Syrup).
-- Step 1: Update the quantity
UPDATE "sales"
   SET "quantity" = 1
 WHERE "buyer_user_id" = (SELECT "id" FROM "user_details" WHERE "primary_contact_no" = '9090909090')
   AND "product_id" = 5;

-- Step 2: Delete the other sale item
DELETE FROM "sales"
 WHERE "buyer_user_id" = (SELECT "id" FROM "user_details" WHERE "primary_contact_no" = '9090909090')
   AND "product_id" = 6;

-- Step 3: View the total cost
SELECT SUM("rate") AS "total_price"
  FROM "sales"
 WHERE "primary_contact_no" = '9090909090'
   AND strftime('%d', "sold_at") = strftime('%d', 'now');

-- =========================================================
-- DELETE & SOFT DELETE OF A STAFF
-- =========================================================

-- Step 1: Try deleting a staff member directly (expected to fail due to references or triggers)
DELETE FROM "staff"
 WHERE "id" = 3;

-- Step 2: Use soft delete instead (update status to 'inactive')
UPDATE "staff"
   SET "status" = 'inactive', "cause" = 'resignation'
 WHERE "id" = 3;

-- Step 3: Verify that the staff is now inactive
SELECT "id", "status"
  FROM "staff"
 WHERE "id" = 3;

-- =========================================================
-- DAY-TO-DAY OPERATIONS
-- =========================================================

---- Clinic & Doctor Operations ----

-- List all doctors working at Sunrise Clinic with their specialties and consultation fees.
SELECT ud."name" AS "doctor_name", d."specialty", d."consultation_fees"
  FROM "doctors" AS "d"
  JOIN "user_details" AS "ud"
    ON d."user_id" = ud."id"
  JOIN "entities" AS "e"
    ON d."entity_id" = e."id"
 WHERE e."name" = 'Sunrise Clinic';

-- Show all upcoming appointments with doctor, patient, and date.
SELECT *
  FROM "view_upcoming_appointments";

-- Count total appointments booked per doctor this month.
SELECT ud."name" AS "doctor_name", COUNT(a."id") AS "total_appointments"
  FROM "appointments" AS "a"
  JOIN "doctor_time_slots" AS "ts"
    ON a."doctor_time_slot_id" = ts."id"
  JOIN "doctors" AS "d"
    ON ts."doctor_id" = d."id"
  JOIN "user_details" AS "ud"
    ON d."user_id" = ud."id"
 WHERE strftime('%m', a."appointment_date") = strftime('%m', 'now')
 GROUP BY d."id";

-- List patients who have visited Dr. Worker E (MBBS) more than once.
SELECT up."name" AS "patient_name", COUNT(pr."id") AS "visits"
  FROM "prescriptions" AS "pr"
  JOIN "doctors" AS "d"
    ON pr."doctor_id" = d."id"
  JOIN "user_details" AS "ud"
    ON d."user_id" = ud."id"
  JOIN "patients" AS "p"
    ON pr."patient_id" = p."id"
  JOIN "user_details" AS "up"
    ON p."user_id" = up."id"
 WHERE ud."name" = 'Worker E'
 GROUP BY p."id"
HAVING visits > 1;

-- Show all doctor time slots in HH:MM format.
SELECT ud."name" AS "doctor_name", ts."day",
       (ts."time_slot_start" / 60 || ':' || printf('%02d', ts."time_slot_start" % 60)) AS "start_time",
       (ts."time_slot_end" / 60 || ':' || printf('%02d', ts."time_slot_end" % 60))   AS "end_time"
  FROM "doctor_time_slots" AS "ts"
  JOIN "doctors" AS "d"
    ON ts."doctor_id" = d."id"
  JOIN "user_details" AS "ud"
    ON d."user_id" = ud."id";

---- Patients & Prescriptions ----

-- List all patients registered at Sunrise Clinic.
SELECT u."name" AS "patient_name"
  FROM "patients" AS "p"
  JOIN "user_details" AS "u"
    ON p."user_id" = u."id"
  JOIN "entities" AS "e"
    ON p."clinic_id" = e."id"
 WHERE e."name" = 'Sunrise Clinic';

-- Show each patient’s latest prescription date and doctor.
SELECT up."name" AS "patient_name", MAX(pr."created_at") AS "last_visit", ud."name" AS "doctor_name"
  FROM "prescriptions" AS "pr"
  JOIN "doctors" AS "d"
    ON pr."doctor_id" = d."id"
  JOIN "user_details" AS "ud"
    ON d."user_id" = ud."id"
  JOIN "patients" AS "p"
    ON pr."patient_id" = p."id"
  JOIN "user_details" AS "up"
    ON p."user_id" = up."id"
 GROUP BY p."id";

-- Find all medicines prescribed for "Fever & body ache".
SELECT DISTINCT prod."name"
  FROM "prescriptions" AS "pr"
  JOIN "prescribed_products" AS "pp"
    ON pr."id" = pp."prescription_id"
  JOIN "products" AS "prod"
    ON pp."product_id" = prod."id"
 WHERE pr."note" LIKE '%Fever%';

-- List tests ordered for each patient with current status.
SELECT *
  FROM "view_lab_test_status";

-- Find which labs processed tests for each patient.
SELECT up."name" AS "patient_name", e."name" AS "lab_name", COUNT(tr."id") AS "tests_done"
  FROM "test_records" AS "tr"
  JOIN "prescribed_tests" AS "pt"
    ON tr."prescribed_tests_id" = pt."id"
  JOIN "prescriptions" AS "pr"
    ON pt."prescription_id" = pr."id"
  JOIN "patients" AS "p"
    ON pr."patient_id" = p."id"
  JOIN "user_details" AS "up"
    ON p."user_id" = up."id"
  JOIN "entities" AS "e"
    ON tr."lab_id" = e."id"
 GROUP BY p."id", e."id";

---- Pharmacy & Product Management ----

-- Show all available products with remaining stock quantities.
SELECT e."name" AS "pharmacy", prod."name" AS "product_name", sb."batch_no", sb."quantity"
  FROM "view_stock_by_batch" AS "sb"
  JOIN "entities" AS "e"
    ON sb."pharmacy_id" = e."id"
  JOIN "products" AS "prod"
    ON sb."product_id" = prod."id"
 ORDER BY sb."quantity" DESC;

-- Find products expiring in the next 30 days.
SELECT *
  FROM "view_expiring_batches_30d";

-- List low stock items (<=10 units).
SELECT *
  FROM "view_low_stock";

-- Show top 5 best-selling products (by total quantity sold).
SELECT prod."name" AS "product_name", SUM(s."quantity") AS "total_sold"
  FROM "sales" AS "s"
  JOIN "products" AS "prod"
    ON s."product_id" = prod."id"
 GROUP BY prod."id"
 ORDER BY "total_sold" DESC
 LIMIT 5;

-- List sales done through prescription (Rx) vs over-the-counter (OTC).
SELECT "sale_type", COUNT(*) AS "total_sales"
  FROM "view_sales_party"
 GROUP BY "sale_type";

-- Total revenue generated by the pharmacy this month.
SELECT SUM(s."quantity" * s."rate") AS "total_revenue"
  FROM "sales" AS "s"
 WHERE strftime('%m', s."sold_at") = strftime('%m', 'now');

---- Purchasing & Inventory Flow ----

-- Show recent purchases with distributor and invoice details.
SELECT ph."invoice_no", ph."invoice_date", e."name" AS "distributor_name", COUNT(pl."id") AS "total_items"
  FROM "purchase_headers" AS "ph"
  JOIN "entities" AS "e"
    ON ph."distributor_id" = e."id"
  JOIN "purchase_lines" AS "pl"
    ON ph."id" = pl."header_id"
 GROUP BY ph."id"
 ORDER BY ph."invoice_date" DESC;

-- For each product, calculate total purchased vs total sold quantities.
SELECT prod."name" AS "product_name",
       SUM(CASE WHEN il."source_type" = 'PURCHASE' THEN il."quantity_delta" ELSE 0 END) AS "purchased",
       SUM(CASE WHEN il."source_type" = 'SALE' THEN -il."quantity_delta" ELSE 0 END) AS "sold"
  FROM "inventory_ledger" AS "il"
  JOIN "products" AS "prod"
    ON il."product_id" = prod."id"
 GROUP BY prod."id";

-- Find batches that have negative or zero stock (possible error).
SELECT *
  FROM "view_current_stock"
 WHERE "quantity" <= 0;

-- Total purchase value for the pharmacy.
SELECT SUM(pl."rate" * pl."quantity") AS "total_purchase_value"
  FROM "purchase_lines" AS "pl"
  JOIN "purchase_headers" AS "ph"
    ON pl."header_id" = ph."id"
 WHERE ph."pharmacy_id" = 2;

---- Staff, HR & Logs ----

-- List all active staff and their roles.
SELECT ud."name" AS "staff_name", s."role", e."name" AS "workplace"
  FROM "staff" AS "s"
  JOIN "user_details" AS "ud"
    ON s."user_id" = ud."id"
  JOIN "entities" AS "e"
    ON s."entity_id" = e."id"
 WHERE s."status" = 'active';

-- Show staff attendance records for today.
SELECT *
  FROM "view_staff_checked_in_today";

-- Show all salary expenses per entity.
SELECT e."name" AS "entity_name", SUM(s."salary") AS "total_salary"
  FROM "staff" AS "s"
  JOIN "entities" AS "e"
    ON s."entity_id" = e."id"
 WHERE s."status" = 'active'
 GROUP BY e."id";

-- Find the most recent changes in staff logs (promotions, updates, etc.).
SELECT *
  FROM "staff_and_entity_logs"
 ORDER BY "created_at" DESC
 LIMIT 10;

---- Reports & Analytics ----

-- Show how many prescriptions each doctor wrote.
SELECT ud."name" AS "doctor_name", COUNT(pr."id") AS "total_prescriptions"
  FROM "prescriptions" AS "pr"
  JOIN "doctors" AS "d"
    ON pr."doctor_id" = d."id"
  JOIN "user_details" AS "ud"
    ON d."user_id" = ud."id"
 GROUP BY d."id"
 ORDER BY "total_prescriptions" DESC;

-- Average lab test cost (rate) per patient.
SELECT up."name" AS "patient_name", AVG(tr."rate") AS "avg_test_cost"
  FROM "test_records" AS "tr"
  JOIN "prescribed_tests" AS "pt"
    ON tr."prescribed_tests_id" = pt."id"
  JOIN "prescriptions" AS "pr"
    ON pt."prescription_id" = pr."id"
  JOIN "patients" AS "p"
    ON pr."patient_id" = p."id"
  JOIN "user_details" AS "up"
    ON p."user_id" = up."id"
 GROUP BY p."id";

-- Total number of active entities by type (clinic, lab, pharmacy).
SELECT k."name" AS "kind", COUNT(e."id") AS "total"
  FROM "entities" AS "e"
  JOIN "kinds" AS "k"
    ON e."kind_id" = k."id"
 WHERE e."status" = 'active'
 GROUP BY k."id";

-- Identify patients who purchased medicines OTC (without prescription).
SELECT DISTINCT ud."name" AS "buyer_name"
  FROM "sales" AS "s"
  JOIN "user_details" AS "ud"
    ON s."buyer_user_id" = ud."id"
 WHERE s."prescription_id" IS NULL;

-- Find which companies supply the most products.
SELECT e."name" AS "company_name", COUNT(p."id") AS "total_products"
  FROM "products" AS "p"
  JOIN "entities" AS "e"
    ON p."company_id" = e."id"
 GROUP BY e."id"
 ORDER BY "total_products" DESC;

---- Audit & Integrity Checks ----

-- Check if any prescription references a doctor or patient that no longer exists.
SELECT pr."id"
  FROM "prescriptions" AS "pr"
  LEFT JOIN "doctors" AS "d"
    ON pr."doctor_id" = d."id"
  LEFT JOIN "patients" AS "p"
    ON pr."patient_id" = p."id"
 WHERE d."id" IS NULL OR p."id" IS NULL;

-- Verify that all sales entries exist in inventory ledger.
SELECT s."id" AS "sale_id"
  FROM "sales" AS "s"
  LEFT JOIN "inventory_ledger" AS "il"
    ON il."source_id" = s."id" AND il."source_type" = 'SALE'
 WHERE il."id" IS NULL;

-- Detect prescriptions missing either medicines or tests.
SELECT pr."id" AS "prescription_id", up."name" AS "patient_name"
  FROM "prescriptions" AS "pr"
  JOIN "patients" AS "p"
    ON pr."patient_id" = p."id"
  JOIN "user_details" AS "up"
    ON p."user_id" = up."id"
 WHERE pr."id" NOT IN (SELECT "prescription_id" FROM "prescribed_products")
    OR pr."id" NOT IN (SELECT "prescription_id" FROM "prescribed_tests");