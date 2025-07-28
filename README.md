# COVID-19 Global Trends and Vaccination Impact (2020-2024)


## Project Overview

This project involved conducting SQL-based analysis on a global COVID-19 dataset comprising over 400,000 records across 245 regions, countries and territories. The data was independently cleaned and analysed using SQL to uncover trends in reported cases, deaths and vaccinations.

An interactive Tableau dashboard was developed to visualise these trends at both the global level and for individual locations, offering insights into the disease's impact and assessing the effectiveness of vaccination protocols across countries and continents from January 2020 to August 2024.

The goal is to provide a clear and accessible breakdown of the pandemic's scale, the findings from which can offer guidance for informed decision-making, resource allocation, and the development of effective public health strategies.



## Objectives

The primary objectives of this analysis are to:

- Clean and integrate raw COVID-19 case, death, vaccination and population data into a consolidated dataset for analysis;

- Track and compare the total number of cases, deaths and vaccinations globally and by location to better understand its distribution and regional impact;

- Calculate key metrics such as case-fatality rate, cases/deaths per million and percentage of population vaccinated;

- Explore the efficacy of vaccine rollouts over time by assessing their relationship with trends in cases and deaths;

- Develop a clear and accessible visual dashboard for users to explore these trends interactively.



## Data Structure Overview

This project primarily used data compiled by Our World in Data, which consolidates COVID-19 statistics from the World Health Organisation (WHO), the United Nations (UN) and official government health departments. Three main datasets were used:

- *cases_and_deaths.csv* - Daily reported COVID-19 cases and deaths by location;
- *vaccinations.csv* - Daily vaccination totals by location;
- *population_2022.csv* - 2022 population figures for each country/territory.

These datasets were cleaned and consolidated into a single SQL table named `CovidData`, where each row represents a daily observation for a specific location within the time period of January 2020 to August 2024. This unified format allowed for consistent analysis of relevant pandemic metrics by date and location.

The constructed table consisted of the following fields:

| Field | Description |
| ------ | ------------- |
| `iso_code` | SO 3166-1 alpha-3 - three-letter country codes. OWID-defined regions contain prefix 'OWID_'. |
| `location` | Geographical location. |
| `date` | Date of observation. |
| `new_cases`, `weekly_cases`, `total_cases` | Daily new, weekly aggregated and total number of reported cases of COVID-19. |
| `new_deaths`, `weekly_deaths`, `total_deaths` | Daily new, weekly aggregated and total number of reported deaths attributed to COVID-19. |
| `daily_vaccinations_raw` | New vaccination doses administered (only calculated for consecutive days). |
| `daily_vaccinations`, `weekly_vaccinations`, `total_vaccinations` | Daily new (7-day smoothed), weekly aggregated and total vaccination doses administered. |
| `daily_people_vaccinated`, `weekly_people_vaccinated`, `people_vaccinated` | Daily new (7-day smoothed), weekly aggregated and total number of people who received their first vaccine dose. |
| `people_fully_vaccinated` | Total number of people who received all doses prescribed by the initial vaccination protocol. |
| `population` | Population values as of end of 2022. |

Cumulative and rolling values are tracked to support both point-in-time metrics and trend analysis, using aggregated weekly figures alongside daily numbers to smooth short-term volatility. This structured format allows for flexible querying and filtering, and forms the basis of both the SQL analysis and Tableau dashboard. 



## Executive Summary

As of August 2024, over 775 million COVID-19 cases and 7 million deaths have been reported globally. The United States recorded the highest totals, exceeding 100 million cases and 1 million deaths.

On a per capita basis, Cyprus experienced the highest case rate (over 700,000 per million) while Peru reported the highest death rate (approximately 6,500 per million). Conflict-affected countries such as Yemen reported the highest case-fatality rates, with limited healthcare capacity likely a factor.

China led in total vaccinations (nearly 3.5 billion), while Gibraltar reported the highest coverage relative to population, though values exceeding 100% suggest inclusion of non-citizens.

Vaccine rollout impacts varied significantly. In Morocco, both cases and deaths declined by over 80% in the 120 days following, indicating a strong response. Conversely, countries such as Uruguay experienced sharp increases of over 500% in cases and 850% in deaths, potentially due to variant-driven surges, delayed rollouts or policy relaxation.

An interactive Tableau dashboard was developed to allow further exploration of trends by location, metric and timeframe. This can be accessed here: [tableau dashboard](https://public.tableau.com/views/CovidDashboard_17470590080560/Dashboard?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)



## Key Insights

As of August 2024:

### Global Overview

- **775,935,057 cases** and **7,060,988 deaths** reported globally, giving a **0.91% case-fatality rate**.

- **4,998,912,044 people vaccinated** (received at least one dose), covering **62.66% of the global population**.

### Regional Differences

- **Asia** reported the highest number of **total cases (301,499,099)**, **vaccinations (9,104,304,615)** and **people vaccinated (3,689,438,947)**, mainly led by populous countries such as China and India;

- **South America** achieved the highest vaccination coverage at **85.95% of population vaccinated**, but still experienced one of the highest **case-fatality rates of 1.97%**, likely due to healthcare system strain and under-resourced regions.

- **Africa**, with the lowest vaccination coverage at **38.90% of population vaccinated**, also reported significantly lower total cases and deaths per million than the others, while still having one of the highest **case-fatality rates of 1.97%** - possibly a reflection of limited reporting infrastructure.

- **Oceania** maintained the lowest **case-fatality rate of 0.22%**, despite high case numbers in countries like Australia and New Zealand.

### Country-level Highlights

- Highest Total Cases: The United States (103,436,829), China (99,373,219) and India (45,041,748) reported the highest total cases, likely due to having the three largest populations;

- Highest Total Cases per Million: Cyprus (777,237), Brunei (774,435) and San Marino (750,727) has the highest case rater per million, reflecting high transmission relative to the population size of these smaller nations;

- Highest Total Deaths: The United States (1,193,165), Brazil (702,116) and India (533,623) reported the highest number of total deaths;

- Highest Total Deaths per Million: Peru (6490), Bulgaria (5706) and Bosnia and Herzegovina (5069) had the highest total deaths per million;

- Highest Case-Fatality Rate (minimum 10,000 cases): Yemen (18.07%), Sudan (7.89%) and Syria (5.51%) recorded the highest case-fatality rates, likely due to underreporting and strained healthcare systems from conflict or lack of resources;

- Highest Total Vaccinations: China (3,491,077,000), India (2,206,868,000) and the United States (676,728,782) administered the most vaccine doses, again likely due to having enough resources and the largest populations;

- Highest Total People Vaccinated: China (1,310,292,000), India (1,027,438,924) and the United States (270,227,181) also recorded the highest numbers of people receiving at least one dose;

- Highest Percent Population Vaccinated: Gibraltar (129.07%), Tokelau (116.38%) and Qatar (105.83%) had the highest coverage rates and all exceeded 100% vaccination. This reflects how their data includes non-citizens.

### Vaccination Rollout Impact

To assess the impact COVID-19 vaccine rollouts, the new cases and deaths of each location were aggregated across **120 days before and after their first recorded vaccine dose**. These figures were then standardised to per million metrics for equitable comparisons. The percentage change of these metrics was calculated to evaluate the observed impact of vaccine rollouts.

To ensure meaningful insights:

- Only locations with populations above 1,000,000 were included to reduce noise from under-resourced micro-states;
- Locations must have recorded at least 5,000 cases per million prior to vaccination, to focus the analysis on countries with significant viral spread relative to size.

### Strong Impact

These countries demonstrated substantial reductions in both cases and deaths per million after vaccination began. All saw declines greater than 50% in both metrics, and case-fatality rates remaining relatively stable with variance of less than 0.45%:

| Location |	Case Fatality Change |	Cases per million Change |	Deaths per million Change |
| -------- | --------------------- | ------------------------- | -------------------------- |
| Morocco | 	0.20%	| -85.44%	| -83.72% |
| South Africa |	0.43%	| -68.35%	| -64.51% |
| Belgium	| 0.35%	| -60.87%	| -53.02% |

These results suggest a strong correlation between vaccine rollout and improved pandemic outcomes.

### Limited or Negative Impact

In contrast, the following countries experienced a significant increase in cases and deaths per million following the introduction of vaccines:

| Location |	Case Fatality Change |	Cases per million Change |	Deaths per million Change |
| -------- | --------------------- | ------------------------- | -------------------------- |
| Uruguay |	0.52% |	542.16%	| 857.65% |
| Cuba |	0.24% |	518.29%	| 752.06% |
| Estonia	| 0.34%	| 280.51%	| 486.99% |


These trends may reflect delayed vaccine effects, limited early coverage or other epidemiological  or behavioural factors (such as variant spread or policy relaxation) that masked or diminished the expected benefits of vaccination.



## Technical Details

The technical analysis involved the use of the following tools:
- **SQL** for data preparation, cleaning and analysis using techniques such as JOINs, CTEs, window functions and pivoting;
- **Tableau** for interactive dashboard design and visual storytelling;
- **MySQL** for database management;
- **Terminal** for importing the dataset from the online source.



## Caveats and Assumptions

### Data Quality and Reporting Limitations

- **Underreporting and inconsistencies:** Many countries applied different protocols for attributing deaths and faced reporting delays. As such, the reported figures likely undercount true cases and deaths. Daily data reflects reported values, not necessarily confirmed.
- **No tracking of unique cases:** Individuals may be recorded as cases multiple times, inflating totals and limiting insights into infection and recovery rates.
- **Gaps in vaccination data:** Some countries lacked consistent vaccine reporting. Smoothed metrics were used to estimate trends where daily data was missing, assuming a uniform rate of change.

### Metric and Methodological Assumptions

- **Case-fatality as a proxy:** Used to infer disease severity, but it is a limited measure, as it only reflects confirmed cases rather than true infections. Infection fatality rate would offer greater accuracy but requires comprehensive testing data.
- **Per-million standardisation:** Metrics were normalised to per million population to enable fair comparisons, though this does not account for age structures, comorbidities or healthcare quality. 
- **120-day vaccine window:** A fixed period was used to evaluate pre- and post- rollout trends. While this assumes a sufficient lag time, it does not capture delayed effects or interference from new variants.
- **First dose signalled start of impact:** The date of the first recorded vaccine dose was used to mark the start of the rollout, but real-world impact depends on broader uptake and dosing intervals.

### Analytical Scope Decisions

- **Data consolidation:** A unified dataset was created to streamline analysis and improve readability, replacing earlier multi-table approaches that required multiple complex JOINs.
- **Exclusions for clarity:** Countries with populations under 1 million or fewer than 5,000 cumulative cases per million were excluded to minimise noise and focus on materially affected locations.
- **Testing metrics omitted:** Infection rates based on testing volume were not analysed due to inconsistent data availability and to intentionally limit project scope. This remains a strong candidate for future expansion.
- **First-dose focus:** Impact was assessed only for the first recorded vaccine dose; analysis of second doses and boosters was omitted from the scope, but also offers a clear opportunity for future expansion.

### Interpreting Outcomes

- **Inconclusive post-vaccine increases:** Increases in cases and deaths post-rollout may reflect unrelated factors such as new variants, relaxed restrictions or limited early coverage, rather than vaccine inefficacy. 
- **Uncontrolled external influences:** Broader public health policies, behavioural shifts and deployment timing during surges were not directly accounted for but likely influenced trends.
- **Immune protection lag:** The analysis assumes vaccine efficacy immediately upon first dose, but real-word immunity builds over time with additional doses, which may delay observable effects.



## Data Source

**COVID-19 Data:** [Our World in Data GitHub Repo](https://github.com/owid/covid-19-data)
