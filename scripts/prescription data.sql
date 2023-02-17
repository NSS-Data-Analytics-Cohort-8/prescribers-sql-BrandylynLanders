-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT prescriber.npi, SUM(prescription.total_claim_count) AS total_claims
FROM prescriber 
INNER JOIN prescription
ON prescriber.npi=prescription.npi
INNER JOIN drug
ON prescription.drug_name=drug.drug_name
GROUP BY prescriber.npi
ORDER BY total_claims DESC
LIMIT 25;
--Answer 1881634483	110646

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT 
	prescriber.npi, 
	prescriber.nppes_provider_first_name, 
	prescriber.nppes_provider_last_org_name,
	prescriber.specialty_description,
	SUM(prescription.total_claim_count) AS total_claims
FROM prescriber 
INNER JOIN prescription --I tried using all the JOIN commands and only found different results when I used outerjoin on both
ON prescriber.npi=prescription.npi
INNER JOIN drug
ON prescription.drug_name=drug.drug_name
GROUP BY prescriber.npi, 
	prescriber.nppes_provider_first_name, 
	prescriber.nppes_provider_last_org_name,
	prescriber.specialty_description
ORDER BY total_claims DESC
LIMIT 25;
--ANSWER (RUN TO SEE TABLE) #1 IS 1881634483	"BRUCE"	"PENDLEY"	"Family Practice"	110646

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT 
	prescriber.specialty_description,
	SUM(prescription.total_claim_count) AS total_claims
FROM prescriber 
INNER JOIN prescription 
ON prescriber.npi=prescription.npi
INNER JOIN drug
ON prescription.drug_name=drug.drug_name
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC
LIMIT 25;
--ANSWER FAMILY PRACTICE

--     b. Which specialty had the most total number of claims for opioids?
SELECT 
	prescriber.specialty_description,
	drug.opioid_drug_flag,
	drug.long_acting_opioid_drug_flag,
	SUM(prescription.total_claim_count) AS total_claims
FROM prescriber 
INNER JOIN prescription 
ON prescriber.npi=prescription.npi
INNER JOIN drug
ON prescription.drug_name=drug.drug_name
WHERE opioid_drug_flag='Y' OR
	drug.long_acting_opioid_drug_flag='Y'
GROUP BY prescriber.specialty_description, drug.opioid_drug_flag, drug.long_acting_opioid_drug_flag
ORDER BY total_claims DESC
LIMIT 25;
--ANSWER NURSE PRACTICIONER
--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--3. 
--a. Which drug (generic_name) had the highest total drug cost?
SELECT SUM(prescription.total_drug_cost)AS total_cost, drug.generic_name
FROM prescriber 
INNER JOIN prescription 
ON prescriber.npi=prescription.npi
INNER JOIN drug
ON prescription.drug_name=drug.drug_name
GROUP BY drug.generic_name
ORDER BY total_cost DESC
LIMIT 25;
--ANSWER 104264066.35	"INSULIN GLARGINE,HUM.REC.ANLOG"

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT drug.generic_name, 
	ROUND(SUM(prescription.total_drug_cost/prescription.total_day_supply),2)AS cost_per_day
FROM prescriber 
INNER JOIN prescription 
ON prescriber.npi=prescription.npi
INNER JOIN drug
ON prescription.drug_name=drug.drug_name
GROUP BY drug.generic_name
ORDER BY cost_per_day DESC
LIMIT 25;
--ANSWER "LEDIPASVIR/SOFOSBUVIR"	88270.87

-- 4. 
--a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT DISTINCT drug.drug_name,
	CASE WHEN drug.opioid_drug_flag='Y' THEN 'opioid'
	WHEN drug.antibiotic_drug_flag='Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type
FROM prescriber 
INNER JOIN prescription 
ON prescriber.npi=prescription.npi
INNER JOIN drug
ON prescription.drug_name=drug.drug_name
ORDER BY drug_type;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT DISTINCT drug.drug_name,
	CASE WHEN drug.opioid_drug_flag='Y' THEN 'opioid'
	WHEN drug.antibiotic_drug_flag='Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type,
	SUM(prescription.total_drug_cost)AS total_cost
FROM prescriber 
INNER JOIN prescription 
ON prescriber.npi=prescription.npi
INNER JOIN drug
ON prescription.drug_name=drug.drug_name
GROUP BY drug.drug_name, drug_type
ORDER BY drug_type, total_cost DESC;
-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT *
FROM prescriber 
INNER JOIN prescription 
ON prescriber.npi=prescription.npi
INNER JOIN drug
ON prescription.drug_name=drug.drug_name
LIMIT 25;
--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT *
FROM prescriber 
INNER JOIN prescription 
ON prescriber.npi=prescription.npi
INNER JOIN drug
ON prescription.drug_name=drug.drug_name
LIMIT 25;
--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
