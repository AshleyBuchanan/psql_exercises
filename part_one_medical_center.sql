DROP DATABASE IF EXISTS medical_center;

CREATE DATABASE medical_center;

\c medical_center

CREATE TABLE Doctors (
    doctor_id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    specialty TEXT
);

CREATE TABLE Patients (
    patient_id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    birthday DATE
);

CREATE TABLE Visits (
    visit_id SERIAL PRIMARY KEY,
    doctor_id INT REFERENCES Doctors(doctor_id),
    patient_id INT REFERENCES Patients(patient_id),
    visit_date TIMESTAMP,
    notes TEXT
);

CREATE TABLE Diseases (
    disease_id SERIAL PRIMARY KEY,
    name TEXT,
    description TEXT
);

CREATE TABLE Diagnoses (
    visit_id INT REFERENCES Visits(visit_id) ON DELETE CASCADE,
    disease_id INT REFERENCES Diseases(disease_id),
    PRIMARY KEY (visit_id, disease_id)
);

-- Data to test with --
-- Insert doctors -- 
INSERT INTO Doctors (first_name, last_name, specialty) VALUES
('Emily', 'Carter', 'Cardiology'),
('Raj', 'Patel', 'Dermatology'),
('Liam', 'Nguyen', 'Neurology');

-- Insert patients --
INSERT INTO Patients (first_name, last_name, birthday) VALUES
('Ava', 'Thompson', '1990-04-12'),
('Noah', 'Johnson', '1985-09-30'),
('Sophia', 'Martinez', '1978-01-22'),
('Ethan', 'Davis', '2001-07-15'),
('Mia', 'Brown', '1995-12-08');

-- Insert diseases --
INSERT INTO Diseases (name, description) VALUES
('Hypertension', 'High blood pressure that can lead to heart problems.'),
('Eczema', 'A skin condition causing inflammation and irritation.'),
('Migraine', 'Severe recurring headaches often accompanied by nausea.'),
('Diabetes', 'A metabolic disease that causes high blood sugar.'),
('Anxiety Disorder', 'Chronic anxiety and tension affecting daily life.');

-- Insert visits --
INSERT INTO Visits (doctor_id, patient_id, visit_date, notes) VALUES
(1, 1, '2025-10-01 09:00:00', 'Routine checkup.'),
(1, 2, '2025-10-02 10:30:00', 'Blood pressure follow-up.'),
(2, 3, '2025-10-03 11:15:00', 'Skin rash on arms.'),
(3, 1, '2025-10-04 14:00:00', 'Recurring headaches reported.'),
(1, 4, '2025-10-05 09:45:00', 'First-time visit for evaluation.'),
(2, 5, '2025-10-06 10:00:00', 'Follow-up for eczema treatment.'),
(3, 2, '2025-10-07 13:00:00', 'Severe migraine episode.'),
(1, 3, '2025-10-08 15:30:00', 'Discussed long-term medication options.');

-- Insert diagnoses --
INSERT INTO Diagnoses (visit_id, disease_id) VALUES
(1, 1), -- Ava Thompson - Hypertension
(2, 1), -- Noah Johnson - Hypertension
(3, 2), -- Sophia Martinez - Eczema
(4, 3), -- Ava Thompson - Migraine
(5, 4), -- Ethan Davis - Diabetes
(6, 2), -- Mia Brown - Eczema
(7, 3), -- Noah Johnson - Migraine
(8, 5); -- Sophia Martinez - Anxiety Disorder


-- Queries --
SELECT *
FROM visits
ORDER BY visit_date;

SELECT *
FROM visits v
ORDER BY v.visit_date;

SELECT *
FROM visits v
    JOIN doctors d ON v.doctor_id = d.doctor_id
    JOIN patients p ON v.patient_id = p.patient_id
ORDER BY v.visit_date;

SELECT 
    d.first_name || ' ' || d.last_name AS doctor,       -- <-- concatenate names --
    p.first_name || ' ' || p.last_name AS patient,      -- <--     "         "   --
    v.visit_date,
    v.notes
FROM visits v
    JOIN doctors d ON v.doctor_id = d.doctor_id
    JOIN patients p ON v.patient_id = p.patient_id
ORDER BY doctor, v.visit_date;                          -- <-- we could easily order by doctor, then visit date, too. --

SELECT 
    d.first_name || ' ' || d.last_name AS doctor,      
    p.first_name || ' ' || p.last_name AS patient,      
    v.visit_date,
    dis.name AS diagnoses,                                      -- <-- add a field for the disease (intentionally renamed to diagnoses) --
    v.notes
FROM visits v
    JOIN doctors d ON v.doctor_id = d.doctor_id
    JOIN patients p ON v.patient_id = p.patient_id
    LEFT JOIN diagnoses diag ON v.visit_id = diag.visit_id          -- <-- join visit_id with diagnoses visit_id --
    LEFT JOIN diseases dis ON diag.disease_id = dis.disease_id      -- <-- join diagnoses disease_id with disease_id -- 
ORDER BY doctor, v.visit_date;                         
