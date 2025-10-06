
------------------------------------------------------------------
-- SIMPLE EXPLICIT-ID DEMO DATA (No subqueries as requested)
-- WARNING: Run on a fresh empty database or after deleting existing rows,
--          because explicit IDs are assumed to start at 1 and be contiguous.
-- Order of insertion preserves FK integrity.
-- Schema reference: see `schema.sql`.
------------------------------------------------------------------
-- 1. Kinds (IDs 1..5)
INSERT INTO "kinds"("id","name") VALUES
  (1,'clinic'),
  (2,'pharmacy'),
  (3,'lab'),
  (4,'distributor'),
  (5,'company');

-- 2. Entities (IDs 1..11)
INSERT INTO "entities"("id","name","kind_id","ownership","address","contact_no") VALUES
  (1,'Sunrise Clinic',1,'owned','Mumbai','9000000001'),
  (2,'HealthPlus Pharmacy',2,'owned','Mumbai','9000000002'),
  (3,'Accurate Diagnostics Lab',3,'owned','Mumbai','9000000003'),
  (4,'MedSupplies Distributors',4,'outsourced','Pune','9000000004'),
  (5,'PharmaHub Distributors',4,'outsourced','Delhi','9000000005'),
  (6,'Allied Health Distributors',4,'outsourced','Bangalore','9000000006'),
  (7,'Acme Pharma Ltd',5,'outsourced','Hyderabad','9000000007'),
  (8,'Zenith Labs Pvt Ltd',5,'outsourced','Ahmedabad','9000000008'),
  (9,'VitalCare Remedies',5,'outsourced','Chennai','9000000009'),
  (10,'GreenLeaf Biotech',5,'outsourced','Kolkata','9000000010'),
  (11,'HealWell Pharma',5,'outsourced','Indore','9000000011');

-- 3. Licences
INSERT INTO "licences"("entity_id","name","licence_no","issue_date","expiry_date") VALUES
  (2,'Trade Licence','TL-15472025','2025-04-01','2026-04-03'),
  (2,'Drug Licence','DL-578/5/2547','2024-04-01','2027-04-01'),
  (2,'GST','ID2548445Z','2024-04-01','2029-03-31'),
  (1,'Trade Licence','TL-54782365','2025-04-01','2026-04-03'),
  (1,'Health Licence','HL-487632','2024-04-01','2027-04-01'),
  (3,'Trade Licence','TL-54748547','2025-04-01','2026-04-03'),
  (3,'Lab Licence','LAB-7488-657','2024-04-01','2027-04-03'),
  (3,'GST','ID2548446Z','2024-04-01','2029-03-31');

-- 4. User Details (IDs 1..10)
INSERT INTO "user_details"("id","name","dob","gender","permanent_address","temp_address","primary_contact_no","secondary_contact_no") VALUES
  (1,'Worker A','2000-01-01','male','Mumbai, India','Bangalore, India','8657988452',NULL),
  (2,'Worker B','1998-05-12','female','Chennai, India','Hyderabad, India','7896541230','9823456710'),
  (3,'Worker C','1995-11-23','male','Pune, India',NULL,'9123456701',NULL),
  (4,'Worker D','1989-07-09','other','Delhi, India','Gurgaon, India','7300567812','7001122233'),
  (5,'Worker E','1986-03-15','male','Jaipur, India',NULL,'7766554432',NULL),
  (6,'Worker F','1984-11-25','female','Lucknow, India','Noida, India','8445566778','9332211456'),
  (7,'Worker G','1999-08-20','male','Indore, India',NULL,'9556677889',NULL),
  (8,'Worker H','1997-02-05','female','Bhopal, India','Nagpur, India','8667001345','7999000112'),
  (9,'Worker I','1990-10-20','prefer_not_to_say','Kolkata, India',NULL,'9012673456',NULL),
  (10,'Worker J','1994-04-27','male','Ahmedabad, India',NULL,'8899001122',NULL);

-- 5. Authenticate Users
INSERT INTO "authenticate_users"("user_id","email","password_hash") VALUES
  (1,'a.reception@demo.local','$2a$10$abcdefghijklmnopqrstuu1'),
  (2,'b.pharmacist@demo.local','$2a$10$abcdefghijklmnopqrstuu2'),
  (3,'c.helper@demo.local','$2a$10$abcdefghijklmnopqrstuu3'),
  (4,'d.labtech@demo.local','$2a$10$abcdefghijklmnopqrstuu4'),
  (5,'e.doctor@demo.local','$2a$10$abcdefghijklmnopqrstuu5'),
  (6,'f.doctor@demo.local','$2a$10$abcdefghijklmnopqrstuu6');

-- 6. Government Documents
INSERT INTO "gov_documents"("user_id","card_name","card_number","card_photo") VALUES
  (1,'Aadhaar','AADH-0001',NULL),
  (1,'Passport','PASS-A0001',NULL),
  (2,'Aadhaar','AADH-0002',NULL),
  (2,'Passport','PASS-B0002',NULL),
  (3,'Aadhaar','AADH-0003',NULL),
  (4,'Aadhaar','AADH-0004',NULL),
  (4,'Passport','PASS-D0004',NULL),
  (5,'Aadhaar','AADH-0005',NULL),
  (5,'Passport','PASS-E0005',NULL),
  (6,'Aadhaar','AADH-0006',NULL),
  (6,'Passport','PASS-F0006',NULL),
  (7,'Aadhaar','AADH-0007',NULL),
  (8,'Aadhaar','AADH-0008',NULL),
  (9,'Aadhaar','AADH-0009',NULL),
  (10,'Aadhaar','AADH-0010',NULL);

-- 7. Education Certificates
INSERT INTO "education_certificates"("user_id","school_name","course_name","certificate_details","certificate_id") VALUES
  (1,'Central School','Senior Secondary','CBSE 12th Certificate','SSC-A1'),
  (2,'Pharma Institute','Diploma in Pharmacy','State Pharmacy Diploma','PHARMA-B2'),
  (3,'City School','Secondary School','10th Marksheet','SEC-C3'),
  (4,'Tech Institute','Lab Technician Course','Lab Tech Certificate','LABT-D4'),
  (5,'Medical College','MBBS','MBBS Degree Certificate','MBBS-E5'),
  (6,'Medical University','MD (Medicine)','MD Degree Certificate','MD-F6');

-- 8. Bank Accounts
INSERT INTO "bank_details"("user_id","bank_ac_holder_name","bank_ac_number","bank_name","bank_IFSC_code","bank_branch") VALUES
  (1,'Worker A','ICICI0001001','ICICI Bank','ICIC0000100','Mumbai Main'),
  (2,'Worker B','HDFC0002002','HDFC Bank','HDFC0000200','Mumbai Central'),
  (3,'Worker C','AXIS0003003','Axis Bank','UTIB0000300','Pune Camp'),
  (4,'Worker D','SBI0004004','SBI','SBIN0000400','Delhi Connaught'),
  (5,'Worker E','SBI0005005','SBI','SBIN0000500','Jaipur Junction'),
  (6,'Worker F','ICICI0006006','ICICI Bank','ICIC0000600','Lucknow Chowk');

-- 9. Staff (IDs will auto = 1..4; created_by references these IDs)
INSERT INTO "staff"("user_id","entity_id","role","join_date","salary","rating","review","cause","created_by") VALUES
  (1,1,'receptionist','2025-01-10',25000,5,'Excellent handling','recruitment',NULL),
  (2,2,'pharmacist','2025-01-15',45000,4,'Experienced pharmacist','recruitment',1),
  (3,2,'technician','2025-02-01',20000,3,'Pharmacy helper','recruitment',2),
  (4,3,'technician','2025-02-05',30000,4,'Lab technician','recruitment',1);

-- 10. Doctors (IDs auto = 1,2) created_by staff 1
INSERT INTO "doctors"("user_id","entity_id","reg_no","specialty","consultation_fees","entity_commission","created_by") VALUES
  (5,1,'REG-MBBS-2025-001','General Medicine',500,20,1),
  (6,1,'REG-MD-2025-002','Internal Medicine',1000,25,1);

-- 11. Doctor Time Slots (IDs auto = 1..4)
INSERT INTO "doctor_time_slots"("doctor_id","chamber_no","day","time_slot_start","time_slot_end","appointments_per_slot") VALUES
  (1,'C1','mon',540,660,4),
  (1,'C1','wed',540,660,4),
  (2,'C2','tue',840,960,4),
  (2,'C2','thu',840,960,4);

-- 12. Patients (IDs auto = 1..3) created_by staff 1
INSERT INTO "patients"("user_id","clinic_id","created_by") VALUES
  (7,1,1),
  (8,1,1),
  (9,1,1);

-- 13. Appointments (6) (slot ids: 2=doc1 wed,4=doc2 thu,3=doc2 tue)
INSERT INTO "appointments"("patient_id","appointment_date","doctor_time_slot_id","created_by") VALUES
  (1,'2025-10-08',2,1),
  (2,'2025-10-09',4,1),
  (3,'2025-10-14',3,1),
  (1,'2025-10-15',2,1),
  (2,'2025-10-16',4,1),
  (3,'2025-10-22',2,1);

-- 14. Prescriptions (IDs auto 1..6) NOTE: doctor_id must NOT be NULL
INSERT INTO "prescriptions"("patient_id","doctor_id","prescription","note") VALUES
  (1,1,NULL,'Fever & body ache'),
  (2,2,NULL,'Allergic rhinitis & reflux'),
  (3,2,NULL,'Hypertension review'),
  (1,1,NULL,'Fever follow-up (external purchase)'),
  (2,2,NULL,'Allergy maintenance'),
  (3,1,NULL,'Hypertension + lipid monitoring');

-- 15. Products (explicit IDs 1..30)
INSERT INTO "products"("id","name","tax_rate","schedule","category","company_id","description","picture","created_by") VALUES
  (1,'P650',12,'not-scheduled','Analgesic',7,'Paracetamol 650 mg',NULL,2),
  (2,'Calpol 500',12,'not-scheduled','Analgesic',7,'Paracetamol 500 mg',NULL,2),
  (3,'Cofstop-A',12,'not-scheduled','Cough/Cold',8,'Cough suppressant A',NULL,2),
  (4,'Cofstop-Z',12,'not-scheduled','Cough/Cold',8,'Cough suppressant Z',NULL,2),
  (5,'A to Z Tab',12,'not-scheduled','Multivitamin',9,'Multivitamin tablets',NULL,2),
  (6,'No Worm',5,'not-scheduled','Anthelmintic',9,'Deworming tablet',NULL,2),
  (7,'Amoxicillin 500',12,'scheduled','Antibiotic',7,'Amoxicillin 500 mg',NULL,2),
  (8,'Azithromycin 500',12,'scheduled','Antibiotic',7,'Azithromycin 500 mg',NULL,2),
  (9,'Paracetamol 650',12,'not-scheduled','Analgesic',7,'Paracetamol 650 mg (alt brand)',NULL,2),
  (10,'Cetirizine 10',5,'not-scheduled','Antihistamine',8,'Cetirizine 10 mg',NULL,2),
  (11,'Pantoprazole 40',12,'not-scheduled','Antacid',8,'Pantoprazole 40 mg',NULL,2),
  (12,'Omeprazole 20',12,'not-scheduled','Antacid',8,'Omeprazole 20 mg',NULL,2),
  (13,'Metformin 500',5,'scheduled','Antidiabetic',9,'Metformin HCL 500 mg',NULL,2),
  (14,'Atorvastatin 10',12,'scheduled','Cardiac',9,'Atorvastatin 10 mg',NULL,2),
  (15,'Losartan 50',12,'scheduled','Cardiac',10,'Losartan Potassium 50 mg',NULL,2),
  (16,'Amlodipine 5',12,'scheduled','Cardiac',10,'Amlodipine 5 mg',NULL,2),
  (17,'Ibuprofen 400',12,'not-scheduled','Analgesic',10,'Ibuprofen 400 mg',NULL,2),
  (18,'Dolo 650',12,'not-scheduled','Analgesic',10,'Paracetamol 650 mg (Dolo)',NULL,2),
  (19,'ORS Powder',5,'not-scheduled','Electrolyte',11,'Oral rehydration salts',NULL,2),
  (20,'Vitamin C 500',12,'not-scheduled','Supplement',11,'Vitamin C 500 mg',NULL,2),
  (21,'Zincovit',12,'not-scheduled','Supplement',11,'Zinc + Multivitamin',NULL,2),
  (22,'Digene',12,'not-scheduled','Antacid',7,'Antacid chewable',NULL,2),
  (23,'Becosules',12,'not-scheduled','Vitamin B Complex',7,'B-Complex capsules',NULL,2),
  (24,'Betadine Gargle',12,'not-scheduled','Antiseptic',8,'Povidone-iodine gargle',NULL,2),
  (25,'Insulin 30/70',12,'scheduled-H','Antidiabetic',9,'Premix insulin',NULL,2),
  (26,'Multivitamin Syrup',12,'not-scheduled','Supplement',9,'Pediatric multivitamin',NULL,2),
  (27,'Cough Syrup Ex',12,'not-scheduled','Cough/Cold',10,'Expectorant syrup',NULL,2),
  (28,'Antacid Suspension',12,'not-scheduled','Antacid',10,'Aluminium hydroxide + Mag',NULL,2),
  (29,'Levocetirizine 5',5,'not-scheduled','Antihistamine',11,'Levocetirizine 5 mg',NULL,2),
  (30,'Calcium+D3',12,'not-scheduled','Supplement',11,'Calcium with Vitamin D3',NULL,2);

-- 16. Compositions
INSERT INTO "compositions"("product_id","composition_name") VALUES
 (1,'Paracetamol 650 mg'),(2,'Paracetamol 500 mg'),(3,'Dextromethorphan Combo'),(4,'Dextromethorphan + Zinc'),
 (5,'Multivitamin + Minerals'),(6,'Albendazole'),(7,'Amoxicillin 500 mg'),(8,'Azithromycin 500 mg'),
 (9,'Paracetamol 650 mg'),(10,'Cetirizine 10 mg'),(11,'Pantoprazole 40 mg'),(12,'Omeprazole 20 mg'),
 (13,'Metformin 500 mg'),(14,'Atorvastatin 10 mg'),(15,'Losartan 50 mg'),(16,'Amlodipine 5 mg'),
 (17,'Ibuprofen 400 mg'),(18,'Paracetamol 650 mg'),(19,'ORS Salts'),(20,'Vitamin C 500 mg'),
 (21,'Zinc + Multivitamins'),(22,'Antacid Combination'),(23,'B-Complex Vitamins'),(24,'Povidone-Iodine 2%'),
 (25,'Insulin 30/70'),(26,'Multivitamin Syrup'),(27,'Guaifenesin Combo'),(28,'Antacid Suspension'),
 (29,'Levocetirizine 5 mg'),(30,'Calcium Carbonate + D3');

-- 17. Prescribed Products
INSERT INTO "prescribed_products"("prescription_id","product_id") VALUES
  (1,1),(1,10),(1,20),
  (2,29),(2,11),(2,22),
  (3,15),(3,16),(3,13),
  (4,1),(4,18),
  (5,29),(5,23),
  (6,15),(6,14),(6,25);

-- 18. Tests (IDs 1..20 created_by staff 4)
INSERT INTO "tests"("id","name","description","created_by") VALUES
  (1,'CBC','Complete Blood Count',4),
  (2,'Lipid Profile','Cholesterol panel',4),
  (3,'LFT','Liver Function Tests',4),
  (4,'RFT','Renal Function Tests',4),
  (5,'Fasting Blood Sugar','FBS glucose',4),
  (6,'PP Blood Sugar','Post-prandial glucose',4),
  (7,'HbA1c','Glycated hemoglobin',4),
  (8,'Thyroid Panel','TSH T3 T4',4),
  (9,'Vitamin D','25-OH Vitamin D',4),
  (10,'Serum Calcium','Calcium level',4),
  (11,'Chest X-Ray PA','Chest radiograph PA view',4),
  (12,'Abdominal Ultrasound','Ultrasound abdomen',4),
  (13,'MRI Brain','MRI brain',4),
  (14,'CT Abdomen','CT abdomen',4),
  (15,'Stool Routine','Stool routine microscopy',4),
  (16,'Sputum Culture','Respiratory sputum culture',4),
  (17,'Urine Routine','Urine analysis',4),
  (18,'ECG','Electrocardiogram',4),
  (19,'Vitamin B12','Serum B12 level',4),
  (20,'X-Ray Knee AP','Knee AP radiograph',4);

-- 19. Prescribed Tests
INSERT INTO "prescribed_tests"("prescription_id","test_id") VALUES
  (1,1),(1,5),
  (2,1),(2,11),
  (3,2),(3,18),
  (4,1),(4,9),
  (5,8),(5,10),
  (6,2),(6,7);

-- 20. Purchase Headers (IDs 1..3) pharmacy=2, distributors 4/5/6, created_by staff 2
INSERT INTO "purchase_headers"("id","pharmacy_id","distributor_id","invoice_no","invoice_date","created_by") VALUES
  (1,2,4,'INV-2025-001','2025-09-25',2),
  (2,2,5,'INV-2025-002','2025-09-26',2),
  (3,2,6,'INV-2025-003','2025-09-27',2);

-- 21. Purchase Lines (all 30 products) created_by staff 2
INSERT INTO "purchase_lines"("header_id","line_no","product_id","batch_no","exp_date","rate","mrp","quantity","created_by") VALUES
  (1,1,1,'BATCH-P1-A','2026-06-30',15.00,20.00,100,2),
  (1,2,2,'BATCH-P2-A','2026-05-31',10.00,15.00,80,2),
  (1,3,3,'BATCH-P3-A','2026-07-31',30.00,45.00,60,2),
  (1,4,4,'BATCH-P4-A','2026-07-31',32.00,48.00,60,2),
  (1,5,5,'BATCH-P5-A','2027-01-31',40.00,60.00,120,2),
  (1,6,6,'BATCH-P6-A','2027-02-28',5.00,8.00,150,2),
  (1,7,7,'BATCH-P7-A','2026-04-30',55.00,75.00,70,2),
  (1,8,8,'BATCH-P8-A','2026-04-30',70.00,95.00,70,2),
  (1,9,9,'BATCH-P9-A','2026-06-30',14.00,19.00,90,2),
  (1,10,10,'BATCH-P10-A','2026-08-31',3.00,6.00,110,2),
  (2,1,11,'BATCH-P11-B','2026-09-30',28.00,42.00,100,2),
  (2,2,12,'BATCH-P12-B','2026-09-30',22.00,35.00,100,2),
  (2,3,13,'BATCH-P13-B','2026-03-31',18.00,30.00,120,2),
  (2,4,14,'BATCH-P14-B','2026-05-31',25.00,40.00,120,2),
  (2,5,15,'BATCH-P15-B','2026-05-31',40.00,60.00,120,2),
  (2,6,16,'BATCH-P16-B','2026-05-31',35.00,55.00,120,2),
  (2,7,17,'BATCH-P17-B','2026-07-31',12.00,20.00,150,2),
  (2,8,18,'BATCH-P18-B','2026-06-30',16.00,25.00,150,2),
  (2,9,19,'BATCH-P19-B','2027-01-31',8.00,12.00,200,2),
  (2,10,20,'BATCH-P20-B','2026-11-30',10.00,18.00,150,2),
  (3,1,21,'BATCH-P21-C','2026-12-31',22.00,35.00,140,2),
  (3,2,22,'BATCH-P22-C','2026-12-31',12.00,20.00,140,2),
  (3,3,23,'BATCH-P23-C','2026-10-31',25.00,38.00,140,2),
  (3,4,24,'BATCH-P24-C','2026-09-30',30.00,48.00,100,2),
  (3,5,25,'BATCH-P25-C','2026-03-31',150.00,190.00,60,2),
  (3,6,26,'BATCH-P26-C','2027-02-28',40.00,60.00,120,2),
  (3,7,27,'BATCH-P27-C','2026-05-31',55.00,80.00,80,2),
  (3,8,28,'BATCH-P28-C','2026-05-31',35.00,55.00,90,2),
  (3,9,29,'BATCH-P29-C','2026-06-30',5.00,9.00,160,2),
  (3,10,30,'BATCH-P30-C','2026-08-31',32.00,50.00,100,2);

-- 22. Sales (no subqueries) staff 2
INSERT INTO "sales"("pharmacy_id","prescription_id","buyer_user_id","product_id","batch_no","quantity","rate","mrp","sold_by") VALUES
  (2,1,NULL,1,'BATCH-P1-A',2,15.00,20.00,2),
  (2,1,NULL,10,'BATCH-P10-A',1,3.00,6.00,2),
  (2,2,NULL,11,'BATCH-P11-B',1,28.00,42.00,2),
  (2,2,NULL,29,'BATCH-P29-C',1,5.00,9.00,2),
  (2,3,NULL,15,'BATCH-P15-B',1,40.00,60.00,2),
  (2,NULL,10,5,'BATCH-P5-A',1,40.00,60.00,2);
-- No sales recorded for prescriptions 4,5,6 (external/future)
